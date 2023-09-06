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

frequencies = [3.5 30];

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

electransf.label = elec1.label;
ftEEG.elec.pnt = electransf.pnt;
ftEEG.elec.elecpos = electransf.pnt;

% segment MRI?

if ~isfield(EEG,'lor')
    EEG.lor = struct();
end

cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'fourier';
cfg.taper = 'boxcar';
cfg.pad = 'nextpow2';
cfg.gpu = 'yes';
dataFreq = ft_freqanalysis(cfg, ftEEG);
elec = dataFreq.elec;

EEG.lor.fftdata = dataFreq;

%% Read headmodel

p = fileparts(which('eeglab'));

headmodel = load('-mat', 'C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_vol.mat');
headmodel = headmodel.vol;

%% load MRI and plot

load('-mat', 'C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_mri.mat');
mri = ft_volumereslice([], mri);

mri.coordsys = 'mni';

%% Prepare leadfield matrix

if ~isfield(EEG.lor,'leadfield')

    cfg                 = [];
    cfg.elec            = dataFreq.elec;
    cfg.headmodel       = headmodel;
    cfg.resolution = 10;   % use a 3-D grid with a X cm resolution
    cfg.sourcemodel.unit       = 'mm';
    cfg.channel         = { 'all' };
    cfg.parallel = 'yes';
    cfg.solver = 'cg';

    [leadfield] = ft_prepare_leadfield(cfg);

    EEG.lor.leadfield = leadfield;

    save leadfield leadfield
else
    leadfield = EEG.lor.leadfield;
end
%% interpolate atlas into sourcemodel

freq = frequencies(1,:);
cfg = [];
cfg.elec = elec;
cfg.eloreta.keepcsd       = 'yes';
cfg.eloreta.keepmom = 'yes';
cfg.eloreta.keepfilter    = 'yes';
cfg.keepleadfield = 'yes';

cfg.frequency    = frequencies;
cfg.sourcemodel  = leadfield;
cfg.headmodel    = headmodel;
cfg.method       = 'eloreta';

cfg.eloreta.projectnoise = 'yes';
cfg.eloreta.lambda   = 5;
cfg.gpu           = 'yes';

source = ft_sourceanalysis(cfg, dataFreq);
source.coordsys = 'mni';


%% INTERPOLATE source to MRI

cfg                 = [];
%cfg.downsample      = 2;
cfg.parameter       = 'pow';
cfg.interpmethod = 'nearest';
cfg.coordsys     = 'mni';
cfg.downsample      = 2;
source.dimord = 'pos_freq';
source.oridimord = 'pos';
source.momdimord = 'pos';
source.powdimord = 'pos_freq';

n_pos = size(source.avg.pow, 1);
n_freq = length(source.freq);
source.avg.pow = reshape(source.avg.pow, [n_pos, n_freq, 1]);

source.dimord = 'pos_freq_time';
source.oridimord = 'pos';
source.momdimord = 'pos';
source.powdimord = 'pos_freq_time';

cfg = [];
cfg.parameter = 'pow';
cfg.interpmethod = 'nearest';
cfg.coordsys = 'mni';
cfg.downsample = 2;
%source_int = ft_sourceinterpolate(cfg, source, mri);

parfor i=1:length(source.freq)
    individual_source = source;
    individual_source.avg.pow = source.avg.pow(:,i);
    source_ints(i)        = ft_sourceinterpolate(cfg, individual_source, mri);
end

source_int = source_ints(1);
for i=2:length(source.freq)
    source_int.pow = cat(2,source_int.pow,source_ints(i).pow);
end
source_int.powdimord = 'pos_freq';

%% interpolate atlas and plot

cfg                 = [];
cfg.method          = 'ortho';
cfg.funparameter    = 'pow';
cfg.powdimord = 'pos_freq';
ft_sourceplot(cfg,source_int);

% load hm from dipfit
hm = load('-mat','head_modelColin27_5003_Standard-10-5-Cap339.mat');

% Make it into a fieldtrip atlas
ft_atlas = struct();
ft_atlas.coordsys = 'mni';
ft_atlas.tissue = hm.atlas.colorTable;
ft_atlas.tissuelabel = hm.atlas.label;
%ft_atlas.dim = hm.cortex.dim; % Assuming that the cortex structure contains the dimensions of the atlas

% Calculate the positions of the atlas voxels
%[pos_x, pos_y, pos_z] = ind2sub(ft_atlas.dim, 1:prod(ft_atlas.dim));
%pos_vox = [pos_x(:), pos_y(:), pos_z(:)];

% Transform the positions to MNI space
%pos_mni = hm.cortex.transform * [pos_vox, ones(size(pos_vox, 1), 1)]';
%ft_atlas.pos = pos_mni(1:3, :)';

% atlas = ft_read_atlas('ROI_MNI_V4.nii');
% atlas.coordsys = 'mni';
% atlas.anatomy = atlas.tissue;
% atlas.anatomylabel = atlas.tissuelabel;

cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter = 'anatomy';

atlas_int = ft_sourceinterpolate(cfg,ft_atlas,source);

cfg                 = [];
cfg.method          = 'ortho';
cfg.funparameter    = 'pow';

cfg.atlas        = atlas_int;

ft_sourceplot(cfg,source);

cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter = 'anatomy';
atlas_int_mri = ft_sourceinterpolate(cfg,atlas,source_int);


disp('Done');
