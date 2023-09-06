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

function [EEG,com,dataFreq,elec,headmodel,mri,leadfield,source,source_int] = pop_dipfit_loretaQL(EEG, select, range, frequencies, varargin)

if nargin < 1
    help pop_dipfit_loreta;
    return;
end

if ~plugin_askinstall('Fieldtrip-lite', 'ft_dipolefitting'), return; end;

FIELDTRIPDIR = 'C:\\GitHub\\eeglab\\plugins\\dipfit5.1\';

coord_transform = [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213];

EEG = pop_dipfit_settings( EEG, 'hdmfile','C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_vol.mat','mrifile','C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_mri.mat','chanfile','C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\elec\\standard_1005.elc','coordformat','MNI','coord_transform',[] ,'chansel',[1:92] );

if nargin < 3
    range = [2 40];
end

if nargin < 4
    frequencies = 18;
end


%% compute spectral params (only need to be done once to get the right structures)

%% make eeglab data into fieldtrip
ftdata = eeglab2fieldtrip(EEG, 'preprocessing', 'none');

%% perform channel transformation

filelist = dir('*.set');

for i = 1:length(filelist)
    EEG = pop_loadset('filename', filelist(i).name);
    
    EEG = pop_dipfit_settings( EEG, 'hdmfile','C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_vol.mat','mrifile','C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_mri.mat','chanfile','C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\elec\\standard_1005.elc','coordformat','MNI','coord_transform',[] ,'chansel',[1:92] );

    ftdata = eeglab2fieldtrip(EEG, 'preprocessing', 'none');
    
    transform = [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213]; % transformation
    transform = transform.*[1         1       1      1+pi/2        1               1       1       1       1]; % rotate head

    elec1    = ftdata.elec;
    electransf.pnt = [];
    if size(transform,1) > 1
        electransf.pnt = transform*[ elec1.pnt ones(size(elec1.pnt,1),1) ]';
    else
        electransf.pnt = traditionaldipfit(transform)*[ elec1.elecpos ones(size(elec1.elecpos,1),1) ]';
    end
    electransf.pnt   = electransf.pnt(1:3,:)';
    %electransf.pnt   = electransf.pnt/10; NEEDEDD TO PLOT THE ELECTRODES CORRECTLY IN ONE MODEL

    electransf.label = elec1.label;
    ftdata.elec.pnt = electransf.pnt;
    ftdata.elec.elecpos = electransf.pnt;

    % append data from each subject into a single FieldTrip structure
    if i == 1
        alldata = ftdata;
    else
        alldata = ft_appenddata([], alldata, ftdata);
    end

    %% Perform FFT

    if ~isfield(EEG,'lor')
        EEG.lor = struct();
    end

    cfg = [];
    cfg.method    = 'mtmfft';
    cfg.output    = 'fourier';
    %cfg.tapsmofrq = 10;
    %cfg.foilim    = range;
    cfg.taper = 'boxcar';
    cfg.pad = 'nextpow2';
    cfg.gpu = 'yes';
    dataFreq = ft_freqanalysis(cfg, ftdata);
    elec = dataFreq.elec;

    EEG.lor.fftdata = dataFreq;

end


%% Read headmodel

%p = fileparts(which('eeglab'));

headmodel = load('-mat', EEG.dipfit.hdmfile);
headmodel = headmodel.vol;

%% load MRI and plot

mri = load('-mat', EEG.dipfit.mrifile);
mri = ft_volumereslice([], mri.mri);
mri.mri.coordsys = 'mni';
mri.coordsys = 'mni';
%EEG.lor.mri = mri;

% cfg = [];
% cfg.method = 'ortho';

%% TEST PLOT HEADMODEL AND ELECTRODES

%figure
%ft_plot_sens(fftdata.elec, 'style', '*b');

%hold on
%ft_plot_headmodel(headmodel);

%% Prepare leadfield matrix

%if ~isfield(EEG.lor,'grid')

cfg                 = [];
cfg.elec            = dataFreq.elec;
cfg.headmodel       = headmodel;
%cfg.reducerank      = 2;
cfg.resolution = 5;   % use a 3-D grid with a X cm resolution
cfg.sourcemodel.unit       = 'mm';
cfg.channel         = { 'all' };
cfg.parallel = 'yes';
cfg.solver = 'cg';

[leadfield] = ft_prepare_leadfield(cfg);

EEG.lor.leadfield = leadfield;

save leadfield leadfield
   
%% interpolate atlas into sourcemodel


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
    cfg.keepleadfield = 'yes'; 
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
    cfg.eloreta.lambda   = 0.5;
    cfg.gpu           = 'yes';

    source = ft_sourceanalysis(cfg, dataFreq);
    source.coordsys = 'mni';

    %EEG.lor.source = struct();
    %EEG.lor.source(i) = source;
    
%% INTERPOLATE source to MRI

    cfg                 = [];
    cfg.downsample      = 2;
    cfg.parameter       = 'avg.pow';
    source.oridimord = 'pos';
    source.momdimord = 'pos';
    source_int        = ft_sourceinterpolate(cfg, source, mri);
    
    %EEG.lor.source = struct();
    %EEG.lor.source_int(i) = source_int;

%% interpolate atlas and plot

     cfg                 = [];    
%     %cfg2                 = struct(g.ft_sourceplot_params{:});
     cfg.method          = 'ortho';
     cfg.funparameter    = 'pow';
     cfg.atlas        = atlas_int;
     %cfg.roi          = atlas_int.tissuelabel;
     cfg.maskparameter = cfg2.funparameter;
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
    cfg.parameter = 'all';
    atlas_int = ft_sourceinterpolate(cfg,atlas,source);
    EEG.lor.atlas_int(i) = atlas_int;
    cfg                 = [];
    %cfg2                 = struct(g.ft_sourceplot_params{:});
    cfg.method          = 'ortho';
    cfg.funparameter    = 'pow';
    cfg.avgoverfreq = 'yes';
    cfg.atlas        = atlas_int;
    ft_sourceplot(cfg,source);

    %THIS DOESN'T!
    atlas = ft_read_atlas('ROI_MNI_V4.nii');
    atlas.coordsys = 'mni';
    cfg = [];
    cfg.interpmethod = 'nearest';
    cfg.parameter = 'all';
    atlas_int_int = ft_sourceinterpolate(cfg,atlas,source_int);
    EEG.lor.atlas_int_int(i) = atlas_int;
    cfg                 = [];
    %cfg2                 = struct(g.ft_sourceplot_params{:});
    cfg.method          = 'ortho';
    cfg.funparameter    = 'pow';
    %cfg.atlas        = atlas_int_int;
    %ft_sourceplot(cfg,source_int);
    %cfg.atlas        = atlas_int_int;
    %try ft_sourceplot(cfg,source_int); catch; end

end

%% history

disp('Done');
com = sprintf('pop_dipfit_loretaQL(EEG, %s);', vararg2str( { select, range, frequencies, varargin}));