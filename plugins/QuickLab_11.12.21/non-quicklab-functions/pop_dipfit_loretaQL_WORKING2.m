%% 
% pop_dipfit_loreta() - localize ICA components using eLoreta
% 
% Usage: >> EEGOUT = pop_dipfit_gridsearch( EEGIN ); % pop up interactive window 
% >> EEGOUT = pop_dipfit_gridsearch( EEGIN, comps );
% 
% Inputs: EEGIN - input dataset comps - [integer array] component indices
% 
% Outputs: EEGOUT output dataset
% 
% Authors: Arnaud Delorme, SCCN, La Jolla 2018
% 
% More help: type help ft_sourceanalysis and help ft_sourceplot for parameters 
% to use these functions.

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

function [EEG,com,EEGlor,elec,headmodel,vol,mri,fftdata,source,sourcemodel,source_int] = pop_dipfit_loretaQL(EEG, select, range, frequencies, varargin)

if nargin < 1
    help pop_dipfit_loreta;
    return;
end

if ~plugin_askinstall('Fieldtrip-lite', 'ft_dipolefitting'), return; end;

FIELDTRIPDIR = 'C:\\GitHub\\eeglab\\plugins\\dipfit5.1\';

coord_transform = [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213];

EEG = pop_dipfit_settings( EEG, 'hdmfile','C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_vol.mat','mrifile','C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_mri.mat','chanfile','C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\elec\\standard_1005.elc','coordformat','MNI','coord_transform',[] ,'chansel',[1:92] );
%EEG = pop_leadfield(EEG, 'sourcemodel','C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\LORETA-Talairach-BAs.mat','sourcemodel2mni',[],'downsample',1);
% 
% EEGOUT = pop_dipfit_settingsQL( EEG, 'hdmfile',...
%     'C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile',...
%     'C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_mri.mat','chanfile',...
%     'C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\elec\\standard_1005.elc',...    
%     'coord_transform',...
%     [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213]);
%    shiftx  shifty   shiftz  pitch    roll      yaw     scalex  scaley  scalez

% [tmpelecs, tmptransf] = coregister(userdat.chanlocs, current.chanfile, 'mesh', current.hdmfile, ...
%                     'transform', str2num(tmptransf), 'chaninfo1', userdat.chaninfo, 'helpmsg', 'on');
%             
%EEGOUT.chanlocs(2:4,:) = EEGOUT.dipfit.newchanpos.pnt;
%[OUTEEG.dipfit.newchanpos,coord_transform] = coregister(EEG.chanlocs, OUTEEG.dipfit.chanfile, 'transform',coord_transform,'manual','off');    
%[0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213] );

%EEGspread = [];
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
                { 'style' 'edit'        'string'  '''method'', ''ortho''' } };
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

atlas = ft_read_atlas('ROI_MNI_V4.nii');
%% compute spectral params (only need to be done once to get the right structures)

% make eeglab data into fieldtrip
fftEEGdata = eeglab2fieldtrip(EEG, 'preprocessing', 'none');

%perform channel transformation

%transform = [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213]; 
% this one was too low?

transform = [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213];
transform = transform.*[1         1       1      1+pi/2        1               1       1       1       1];
%transformmat = dat.transform;

elec1    = fftEEGdata.elec;
electransf.pnt = [];
if size(transform,1) > 1
    electransf.pnt = transform*[ elec1.pnt ones(size(elec1.pnt,1),1) ]';
else
    electransf.pnt = traditionaldipfit(transform)*[ elec1.elecpos ones(size(elec1.elecpos,1),1) ]';
end
electransf.pnt   = electransf.pnt(1:3,:)';
%electransf.pnt   = electransf.pnt/10;
electransf.label = elec1.label;

fftEEGdata.elec.pnt = electransf.pnt;
fftEEGdata.elec.elecpos = electransf.pnt;
% segment MRI?
if ~exist('segmentedmri.mat')
    cfg           = [];
    cfg.output    = 'brain';
    segmentedmri  = ft_volumesegment(cfg, mri);
    save segmentedmri segmentedmri
else
    segmentedmri = ft_read_mri('segmentedmri.mat');
end

% prepare headmodel singleshell

if ~exist('vol.mat')
    cfg = [];
    cfg.method='singleshell';
    vol = ft_prepare_headmodel(cfg, segmentedmri);
    save vol vol
else
    vol = ft_read_mri('vol.mat');
end

% plot headmodel and electrodes
%vol = ft_convert_units(vol, 'cm');
%sens = ft_read_sens('Subject01.ds', 'senstype', 'meg');
%sens = ft_read_sens('HCGSN128Renamed.sfp', 'senstype', 'eeg');

figure
ft_plot_sens(electransf, 'style', '*b');

hold on
ft_plot_headmodel(vol);

%EEG_PC_data = eeglab2fieldtrip(EEG.icaact(11,:,:), 'preprocessing', 'none');

cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'fourier';
cfg.tapsmofrq = 10;
cfg.foilim    = range;
cfg.pad = 'nextpow2';
cfg.gpu = 'yes';
fftdata = ft_freqanalysis(cfg, fftEEGdata);
elec = fftdata.elec;
%freqPre = rmfield(freqPre,'labelcmb');

if ~isfield(EEG,'lor')
    EEG.lor = struct();
end 

EEG.fftdata = fftdata;
%% Read headmodel

p = fileparts(which('eeglab'));
% if ~isfield(EEG.lor,'HM')
     headmodel = load('-mat', EEG.dipfit.hdmfile);
     headmodel = headmodel.vol;
%     EEG.lor.HM = headmodel;
% else
%     headmodel  = vol;
% end

%% load MRI and plot

%if ~isfield(EEG.lor,'mri')
    mri = load('-mat', EEG.dipfit.mrifile);
    mri = ft_volumereslice([], mri.mri);
    EEG.lor.mri = mri;

    cfg = [];
    cfg.method = 'ortho';
    %ft_sourceplot(cfg, mri)
%else 
   % mri = EEG.lor.mri;
%end
% source localization

figure
ft_plot_sens(fftdata.elec, 'style', '*b');

hold on
ft_plot_headmodel(headmodel);


%% prepare leadfield matrix

%if ~isfield(EEG.lor,'grid')
    cfg                 = [];
    cfg.elec            = fftdata.elec;
    cfg.headmodel       = headmodel;
    cfg.reducerank      = 2;
    cfg.grid.resolution = 10;   % use a 3-D grid with a 1 cm resolution
    cfg.grid.unit       = 'mm';
    cfg.channel         = { 'all' };
    cfg.parallel = 'yes';
    cfg.solver = 'cg';

    [sourcemodel] = ft_prepare_leadfield(cfg);
    EEG.lor.grid = sourcemodel;
% else 
%     grid = EEG.lor.grid;
% end

counter = 0;

numfreq = size(frequencies,2);
% if numfreq > 1
%     EEGlor(1:numfreq) = deal(EEG);
% else
     EEGlor = EEG;
% end

%vol = load('-mat', EEG.dipfit.hdmfile);

%for i = 1:numfreq
    
    atlas = ft_read_atlas('ROI_MNI_V4.nii');

    %freq = frequencies(i);
    
    %cfg              = struct(g.ft_sourceanalysis_params{:});
    cfg.elec = elec;
    cfg.keepcsd       = 'yes';
    cfg.frequency    = frequencies;
    cfg.sourcemodel  = sourcemodel;
    cfg.headmodel    = headmodel;
   % cfg.sourcemodel = EEG.dipfit.sourcemodel; % NEWLY ADDED
    cfg.method       = 'eloreta';
    cfg.atlas        = atlas;
    cfg.roi          = atlas.tissuelabel;
    cfg.eloreta.projectnoise = 'yes';
    cfg.eloreta.lambda   = 5;
    cfg.gpu           = 'yes';
    
    source = ft_sourceanalysis(cfg, fftdata);
    
    %EEGlor.lor.cfg(numfreq) = cfg;
    %EEGlor.lor.freq(numfreq) = fftdata;
    %EEGlor.lor.source(numfreq) = source;
    
%% load MRI and INTERPOLATE

    cfg2                 = [];
    cfg2.downsample      = 2;
    cfg2.parameter       = 'avg.pow';
    source.oridimord = 'pos';
    source.momdimord = 'pos';
    
    source_int        = ft_sourceinterpolate(cfg2, source, mri);
    %EEGlor.lor.source_int(numfreq) = source_int;

%% plot
    cfg2                 = [];    
%cfg2                 = struct(g.ft_sourceplot_params{:});
    cfg2.method          = 'ortho';
    cfg2.funparameter    = 'pow';
    %cfg2.flipori = 'yes';
    %cfg2.atlas = ft_read_atlas('ROI_MNI_V4.nii'); % not working, arrays
    %cfg2.atlas        = atlas;
    % are of different sizes! error:
    % The axes are 150 mm long in each direction
    % The diameter of the sphere at the origin is 10 mm
    ft_sourceplot(cfg2,source_int);
    ft_sourceplot(cfg2,source);
    textsc(sprintf('eLoreta source localization of %d frequency power',freq), 'title');

%     cfg = [];
%     cfg.nonlinear = 'no';
%     sourceDiffIntNorm = ft_volumenormalise(cfg, sourcePostInt_nocon);
%      
%     cfg3 = [];
%     cfg3.method        = 'ortho';
%     cfg3.funparameter  = 'pow';
%     cfg3.maskparameter = 'pow';
%     cfg3.funcolorlim   = [0.0 1.2];
%     cfg3.opacitylim    = [0.0 1.2];
%     cfg3.opacitymap    = 'rampup';
%     cfg3.atlas = ft_read_atlas('ROI_MNI_V4.nii');
%     ft_sourceplot(cfg3, sourcePostInt);
%     
%end


%     ft_sourceplot(cfg3, sourceDiffIntNorm);
%end
% % 
%  for j=1:size(EEGspread,2)
%      freq = frequencies(j);
%      cfg2            = [];
%      cfg2.downsample = 2;
%      cfg2.parameter = 'avg.pow';
%      sourcePost_nocon.oridimord = 'pos';
%      sourcePost_nocon.momdimord = 'pos';
%      EEGspread(j).lor.source_int2(freq)  = ft_sourceinterpolate(cfg2, EEGspread(j).lor.source_int(freq) , mri);
%      
%      cfg2              = struct(g.ft_sourceplot_params{:});
%      cfg2.funparameter = 'pow';
%      ft_sourceplot(cfg2,EEGspread(j).lor.source_int(freq));
%  end

%ft_sourceplot(cfg2,sourcePostInt_nocon_int);
%% history

disp('Done');
com = sprintf('pop_dipfit_loretaQL(EEG, %s);', vararg2str( { select, range, frequencies, varargin}));