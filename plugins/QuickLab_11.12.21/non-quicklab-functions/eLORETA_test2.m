function eLORETA_test2()

% add FieldTrip toolbox to MATLAB path
% addpath /path/to/fieldtrip
elec = readlocs('C:\GitHub\eeglab\sample_locs\92HMDotLoc.ced', 'filetype', 'autodetect');

% load list of EEG files in .set format using EEGLAB
%eeglab % start EEGLAB
filelist = dir('3350*DONE.set');
nfiles = length(filelist);

% load and process each EEG dataset using FieldTrip
% for i = 1:nfiles
     EEG = pop_loadset('filename', filelist(1).name);
     ftdata = eeglab2fieldtrip(EEG, 'preprocessing', 'none');
     ft_checkdata(ftdata);
%     
%     % append data from each subject into a single FieldTrip structure
%     if i == 1
         alldata = ftdata;
%     else
%         alldata = ft_appenddata([], alldata, ftdata);
%     end
% end
% 
% eloc = readlocs('DotLoc92HM.sfp');
% elec = eeglab2fieldtrip(struct('elec', eloc));

elec = EEG.chanlocs;
cfg = [];
cfg.method = 'bemcp';
cfg.elec = elec;
vol = ft_prepare_headmodel(cfg);

% Create the volume conduction model
cfg = [];
cfg.vol = vol;
cfg.grid.resolution = 1; % adjust the resolution as necessary
vol_sens = ft_prepare_vol_sens(cfg);

% Create the mesh
cfg = [];
cfg.method = 'isosurface';
cfg.numvertices = 10000; % adjust the number of vertices as necessary
cfg.reducepatch = 'yes';
mesh = ft_prepare_mesh(cfg, vol_sens);



% create individual scalp surface
cfg = [];
cfg.method = 'singlesphere';
cfg.radius = [0.88 0.92 1.0];
cfg.unit = 'mm';
cfg.numvertices = 1000;
cfg.elec = alldata.elec;
mesh = ft_prepare_mesh(cfg, alldata);

elec = alldata.elec;
cfg = [];
cfg.method = 'singlesphere';
cfg.radius = 8;
vol = ft_prepare_headmodel(struct('type', 'concentricspheres', 'radius', [0.88 0.92 1.0], 'conductivity', [0.33 0.014 0.33], 'method','singlesphere','elec', elec));

% 
% % create head model
cfg = [];
cfg.method = 'delauney';
cfg.conductivity = [0.33 0.0041 0.33]; % tissue conductivity values
cfg.tissue = {'scalp', 'skull', 'brain'};
cfg.headmodel = 'custom';
cfg.headshape = mesh;
vol = ft_prepare_headmodel(cfg);

% specify electrode positions
%elec = ft_read_sens('DotLoc92HM.sfp');

% prepare data for eLORETA
cfg = [];
cfg.method = 'eloreta';
cfg.grid = vol;
cfg.grid.resolution = 5; % set grid resolution to 5mm
cfg.elec = elec;
cfg.headmodel = vol;
cfg.eloreta.keepfilter = 'yes'; % save spatial filter weights
cfg.eloreta.lambda = 0.05; % regularization parameter
cfg.frequency = [8 12]; % specify frequency range of interest (e.g., alpha band)
source = ft_sourceanalysis(cfg, alldata);

% average source activity across all subjects
cfg = [];
cfg.parameter = 'pow';
cfg.operation = 'log10(x1)';
source_avg = ft_math(cfg, source);
source_avg = ft_sourcegrandaverage([], source_avg);

% plot source activity
cfg = [];
cfg.method = 'slice';
cfg.funparameter = 'pow';
cfg.maskparameter = cfg.funparameter;
cfg.opacitylim = [-2 2]; % set colorbar limits
cfg.slicerange = [-50 50]; % set z-axis slice range
ft_sourceplot(cfg, source_avg);