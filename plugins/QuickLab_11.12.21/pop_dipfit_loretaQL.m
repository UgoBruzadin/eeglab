% pop_dipfit_loreta() - localize ICA components using eLoreta
%
% Usage:
%  >> EEGOUT = pop_dipfit_gridsearch( EEGIN ); % pop up interactive window
%  >> EEGOUT = pop_dipfit_gridsearch( EEGIN, comps );
%
% Inputs:
%   EEGIN     - input dataset
%   comps     - [integer array] component indices
%
% Outputs:
%   EEGOUT      output dataset
%
% Authors: Arnaud Delorme, SCCN, La Jolla 2018
%
% More help: type help ft_sourceanalysis and help ft_sourceplot for 
%            parameters to use these functions.

% Copyright (C) 2018 Arnaud Delorme
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [EEG,com] = pop_dipfit_loretaQL(EEG, select, range, frequencies, varargin)

if nargin < 1
    help pop_dipfit_loreta;
    return;
end

if ~plugin_askinstall('Fieldtrip-lite', 'ft_dipolefitting'), return; end;

EEG = pop_par_dipfit_settings( EEG, 'hdmfile','C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\standard_mri.mat','chanfile','C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213] ,'chansel',[1:EEG.nbchan] );

EEGOUT = EEG;
com = '';

if ~isfield(EEG, 'chanlocs')
    error('No electrodes present');
end

if ~isfield(EEG, 'icawinv')
    error('No ICA components to fit');
end
        
if ~isfield(EEG, 'dipfit')
    error('General dipole fit settings not specified');
end

if ~isfield(EEG.dipfit, 'vol') && ~isfield(EEG.dipfit, 'hdmfile')
    end
if ~isfield(EEG.dipfit, 'coordformat') || ~strcmpi(EEG.dipfit.coordformat, 'MNI')
    error('For this function, you must use the template BEM model MNI in dipole fit settings');
end

dipfitdefs;
if nargin < 2
     uilist = { { 'style' 'text'        'string'  [ 'Enter indices of components ' 10 '(one figure generated per component)'] } ...
                { 'style' 'edit'        'string'  '1' } ...
                { 'style' 'text'        'string'  'ft_sourceanalysis parameters' } ...
                { 'style' 'edit'        'string'  '''method'', ''eloreta''' } ...
                { 'style' 'text'        'string'  'ft_sourceplot parameters' } ...
                { 'style' 'edit'        'string'  '''method'', ''slice''' } };
     optiongui = { 'geometry', { 1 1 1 1 1 1 }, 'geomvert', [2 1 1 1 1 1], 'uilist', uilist, 'helpcom', 'pophelp(''pop_dipfit_loreta'')', ...
                  'title', 'Localization of ICA components using eLoreta -- pop_dipfit_loreta()' };
	[result] = inputgui( optiongui{:});
    
    if isempty(result)
        % user pressed cancel
        return
    end
    
    % decode parameters
    select = eval( [ '[' result{1} ']' ]);
    try, params1 = eval( [ '{' result{2} '}' ]); catch, error('ft_sourceanalysis parameters badly formated'); end
    try, params2 = eval( [ '{' result{3} '}' ]); catch, error('ft_sourceplot parameters badly formated'); end
    options = { 'ft_sourceanalysis_params' params1 'ft_sourceplot_params' params2 };
else
    options = varargin;
end

if ~isempty(setdiff(select, [1:size(EEG.icaweights,1)]))
    error('Some component indices out of range');
end

g = finputcheck(options, { 'ft_sourceanalysis_params'  'cell'    {}         { 'method' 'eloreta' };
                           'ft_sourceplot_params'      'cell'    []         { 'method' 'slice' } }, 'pop_dipfit_loreta');
if isstr(g), error(g); end;


if nargin < 3
    range = [2 40];
end

if nargin < 4
    frequencies = 18;
end


%% compute spectral params (only need to be done once to get the right structures)
dataPre = eeglab2fieldtrip(EEG, 'preprocessing', 'none');
cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'powandcsd';
cfg.tapsmofrq = 10;
cfg.foilim    = range;
cfg.pad = 'nextpow2';
freqPre = ft_freqanalysis(cfg, dataPre);
%freqPre = rmfield(freqPre,'labelcmb');
if ~isfield(EEG,'lor')
    EEG.lor = struct();
end 

%% read headmodel
p = fileparts(which('eeglab'));
if ~isfield(EEG.lor,'HM')
    headmodel = load('-mat', EEG.dipfit.hdmfile);
    headmodel = headmodel.vol;
    EEG.lor.HM = headmodel;
else
    headmodel  = EEG.lor.HM;
end
%% prepare leadfield matrix

if ~isfield(EEG.lor,'grid')
    cfg                 = [];
    cfg.elec            = freqPre.elec;
    cfg.headmodel       = headmodel;
    cfg.reducerank      = 2;
    cfg.grid.resolution = 10;   % use a 3-D grid with a 1 cm resolution
    cfg.grid.unit       = 'mm';
    cfg.channel         = { 'all' };
    [grid] = ft_prepare_leadfield(cfg);
    EEG.lor.grid = grid;
else 
    grid = EEG.lor.grid;
end

%% load MRI and plot
if ~isfield(EEG.lor,'mri')
    mri = load('-mat', EEG.dipfit.mrifile);
    mri = ft_volumereslice([], mri.mri);
    EEG.lor.mri = mri;
else 
    mri = EEG.lor.mri;
end
% source localization

counter = 0;
for freq = frequencies
    counter = counter + 1;
    cfg              = struct(g.ft_sourceanalysis_params{:});
    cfg.frequency    = freq;
    cfg.grid         = grid;
    cfg.headmodel    = headmodel;
    cfg.dics.projectnoise = 'yes';
    cfg.dics.lambda       = 5;

%for iSelect = select(:)'
    %freqPre.powspctrm = EEG.icawinv(:,iSelect).*EEG.icawinv(:,iSelect);
    %freqPre.crsspctrm = EEG.icawinv(:,iSelect)*EEG.icawinv(:,iSelect)';
    
    %freqPre.powspctrm = EEG.icawinv(:,:).*EEG.icawinv(:,:);
    %freqPre.crsspctrm = EEG.icawinv(:,:)*EEG.icawinv(:,:)';    
    
    %freqPre.powspctrm = EEG.data(:,:);
    %freqPre.crsspctrm = EEG.data(:,:)';    
    
    sourcePost_nocon = ft_sourceanalysis(cfg, freqPre);
    
    EEG.lor.cfg(counter) = cfg;
    EEG.lor.freq(counter) = freqPre;
    EEG.lor.source(counter) = sourcePost_nocon;

%     %% load MRI and plot
%     mri = load('-mat', EEG.dipfit.mrifile);
%     mri = ft_volumereslice([], mri.mri);
    
    cfg2            = [];
    cfg2.downsample = 2;
    cfg2.parameter = 'avg.pow';
    sourcePost_nocon.oridimord = 'pos';
    sourcePost_nocon.momdimord = 'pos';
    sourcePostInt_nocon  = ft_sourceinterpolate(cfg2, sourcePost_nocon , mri);
    
    EEG.lor.source_int(counter) = sourcePostInt_nocon;
    open
    cfg2              = struct(g.ft_sourceplot_params{:});
    cfg2.funparameter = 'pow';
    
%    cfg2.atlas = ft_read_atlas('ROI_MNI_V7.nii'); % not working
    
    ft_sourceplot(cfg2,sourcePostInt_nocon);
    textsc(sprintf('eLoreta source localization of %d frequency power',freq), 'title');

%     cfg = [];
%     cfg.nonlinear = 'no';
%     sourceDiffIntNorm = ft_volumenormalise(cfg, sourcePostInt_nocon);
% %     
%     cfg3 = [];
%     cfg3.method        = 'ortho';
%     cfg3.funparameter  = 'pow';
%     cfg3.maskparameter = 'pow';
%     cfg3.funcolorlim   = [0.0 1.2];
%     cfg3.opacitylim    = [0.0 1.2];
%     cfg3.opacitymap    = 'rampup';
%     cfg3.atlas = ft_read_atlas('ROI_MNI_V7.nii');
%     ft_sourceplot(cfg3, sourcePostInt_nocon);
%     
end
%     ft_sourceplot(cfg3, sourceDiffIntNorm);
%end

%% history
disp('Done');
com = sprintf('pop_dipfit_loretaQL(EEG, %s);', vararg2str( { select, range, frequencies, varargin}));
