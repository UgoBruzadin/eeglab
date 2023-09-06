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

function [EEG,com,dataFreq,elec,headmodel,vol,mri,leadfield,source,source_int] = pop_dipfit_loretaQL(EEG, select, range, frequencies, varargin)

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


%% compute spectral params (only need to be done once to get the right structures)

%% make eeglab data into fieldtrip
ftEEG = eeglab2fieldtrip(EEG, 'preprocessing', 'none');

%% perform channel transformation

transform = [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213]; % transformation
transform = transform.*[1         1       1      1+pi/2        1               1       1       1       1]; % rotate head

elec1    = ftEEG.elec;
electransf.pnt = [];
if size(transform,1) > 1
    electransf.pnt = transform*[ elec1.pnt ones(size(elec1.pnt,1),1) ]';
else
    electransf.pnt = traditionaldipfit(transform)*[ elec1.elecpos ones(size(elec1.elecpos,1),1) ]';
end
electransf.pnt   = electransf.pnt(1:3,:)';
%electransf.pnt   = electransf.pnt/10;
electransf.label = elec1.label;
ftEEG.elec.pnt = electransf.pnt;
ftEEG.elec.elecpos = electransf.pnt;

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

if ~isfield(EEG,'lor')
    EEG.lor = struct();
end 

% cfg = [];
% cfg.method    = 'mtmfft';
% cfg.output    = 'powandcsd';
% cfg.tapsmofrq = 10;
% cfg.foilim    = range;
% cfg.pad = 'nextpow2';
% cfg.gpu = 'yes';
% fftdata = ft_freqanalysis(cfg, fftEEGdata);
% elec = fftdata.elec;
% %fftdata = rmfield(fftdata,'labelcmb');
% 
% EEG.lor.fftdata = fftdata;

cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'fourier';
%cfg.tapsmofrq = 10;
%cfg.foilim    = range;
cfg.taper = 'boxcar';
cfg.pad = 'nextpow2';
cfg.gpu = 'yes';
dataFreq = ft_freqanalysis(cfg, ftEEG);
elec = dataFreq.elec;
%fftdata = rmfield(fftdata,'labelcmb');

EEG.lor.fftdata = dataFreq;


%% apply fix by Arno on https://github.com/fieldtrip/fieldtrip/issues/1454

% dataFreq.freq = [1:range(2)];
% dataFreq.fourierspctrm = permute(dataFreq.fourierspctrm, [3 2 1]);
% dataFreq.cumsumcnt = ones(1, size(dataFreq.fourierspctrm,1))*80;
% dataFreq.cumtapcnt = ones(1, size(dataFreq.fourierspctrm,1));
% try dataFreq = rmfield(dataFreq, 'trialinfo'); catch; end

%% Read headmodel

p = fileparts(which('eeglab'));

headmodel = load('-mat', EEG.dipfit.hdmfile);
headmodel = headmodel.vol;

%% load MRI and plot

mri = load('-mat', EEG.dipfit.mrifile);
mri = ft_volumereslice([], mri.mri);
mri.mri.coordsys = 'mni';
mri.coordsys = 'mni';
%EEG.lor.mri = mri;

cfg = [];
cfg.method = 'ortho';

%figure
%ft_plot_sens(fftdata.elec, 'style', '*b');

%hold on
%ft_plot_headmodel(headmodel);


%% prepare leadfield matrix

%if ~isfield(EEG.lor,'grid')

cfg                 = [];
cfg.elec            = dataFreq.elec;
cfg.headmodel       = headmodel;
%cfg.reducerank      = 2;
cfg.resolution = 5;   % use a 3-D grid with a 1 cm resolution
cfg.sourcemodel.unit       = 'mm';
cfg.channel         = { 'all' };
cfg.parallel = 'yes';
cfg.solver = 'cg';

[leadfield] = ft_prepare_leadfield(cfg);

EEG.lor.leadfield = leadfield;
   
%% interpolate atlas into sourcemodel

atlas = ft_read_atlas('ROI_MNI_V4.nii');
cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
atlas_int = ft_sourceinterpolate(cfg,atlas,leadfield);

counter = 0;

% if size(frequencies,1) > 1
%     numfreq = size(frequencies,1);
% else
%     numfreq = size(frequencies,2);
% end
numfreq = 1;

for i = 1:numfreq
    
%     if size(frequencies,1) > 1
         freq = frequencies(1,:);
%     else
%         freq = frequencies(i);
%     end
    
    %fftdata2 = fftdata;
    %[M,I] = min(abs(fftdata.freq - freq));
    %fftdata.freq = fftdata.freq(I);
    %fftdata.fourierspctrm = fftdata.fourierspctrm(:,:,I);
    
    %cfg              = struct(g.ft_sourceanalysis_params{:});
    cfg.elec = elec;
    cfg.eloreta.keepcsd       = 'yes';
    cfg.eloreta.keepmom = 'yes';
    cfg.eloreta.keepleadfield = 'yes'; 
    cfg.eloreta.keepfilter    = 'yes';
    cfg.normalize = 'yes';
    cfg.frequency    = freq;
    cfg.sourcemodel  = leadfield;
    cfg.headmodel    = headmodel;
   % cfg.sourcemodel = EEG.dipfit.sourcemodel; % NEWLY ADDED
    cfg.method       = 'eloreta';
    %cfg.atlas        = source_model_atlas;
    %cfg.roi          = atlas.tissuelabel;
    cfg.eloreta.projectnoise = 'yes';
    %cfg.eloreta.lambda   = 5;
    cfg.gpu           = 'yes';

    source = ft_sourceanalysis_par(cfg, dataFreq);
    source.coordsys = 'mni';
    %EEG.lor.source = struct();
    %EEG.lor.source(i) = source;
    
%% load MRI and INTERPOLATE

    cfg                 = [];
    cfg.downsample      = 2;
    cfg.parameter       = 'avg.pow';
    source.oridimord = 'pos';
    source.momdimord = 'pos';
    source_int        = ft_sourceinterpolate(cfg, source, mri);
    %EEG.lor.source_int(i) = source_int;

%% interpolate atlas and plot

%     atlas = ft_read_atlas('ROI_MNI_V4.nii');
%     atlas.coordsys = 'mni';
%     cfg = [];
%     cfg.interpmethod = 'nearest';
%     cfg.parameter = 'tissue';
%     atlas_int = ft_sourceinterpolate(cfg,atlas,source);
% 
     cfg                 = [];    
%     %cfg2                 = struct(g.ft_sourceplot_params{:});
     cfg.method          = 'ortho';
     cfg.funparameter    = 'pow';
%     cfg.atlas        = atlas_int;
%     %cfg.roi          = atlas_int.tissuelabel;
%     %cfg2.maskparameter = cfg2.funparameter;
%     %cfg2.opacitymap = 'rampup';
%     %cfg2.location = 'peak';
%     %cfg2.flipori = 'yes';
     ft_sourceplot(cfg,source_int);
%     %textsc(sprintf('eLoreta source localization of %d frequency power',freq), 'title');
%     ft_sourceplot(cfg,source);
%     textsc(sprintf('eLoreta source localization of %d frequency power',freq), 'title');
    
    %TESTING THIS WORKS!
    atlas = ft_read_atlas('ROI_MNI_V4.nii');
    atlas.coordsys = 'mni';

    cfg = [];
    cfg.interpmethod = 'nearest';
    cfg.parameter = 'tissue';
    atlas_int = ft_sourceinterpolate(cfg,atlas,source);
    EEG.lor.atlas_int(i) = atlas_int;
    cfg                 = [];
    %cfg2                 = struct(g.ft_sourceplot_params{:});
    cfg.method          = 'ortho';
    cfg.funparameter    = 'pow';
    cfg.atlas        = atlas_int;
    ft_sourceplot(cfg,source);

    %THIS DOESN'T!
    atlas = ft_read_atlas('ROI_MNI_V4.nii');
    atlas.coordsys = 'mni';
    cfg = [];
    cfg.interpmethod = 'nearest';
    cfg.parameter = 'tissue';
    atlas_int_int = ft_sourceinterpolate(cfg,atlas,source_int);
    EEG.lor.atlas_int_int(i) = atlas_int;
    cfg                 = [];
    %cfg2                 = struct(g.ft_sourceplot_params{:});
    cfg.method          = 'ortho';
    cfg.funparameter    = 'pow';
    %cfg.atlas        = atlas_int_int;
    ft_sourceplot(cfg,source_int);
    cfg.atlas        = atlas_int_int;
    %ft_sourceplot(cfg,source_int);


end

%% history

disp('Done');
com = sprintf('pop_dipfit_loretaQL(EEG, %s);', vararg2str( { select, range, frequencies, varargin}));