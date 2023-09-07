% add FieldTrip toolbox to MATLAB path
addpath /path/to/fieldtrip

% load list of EEG files in .set format using EEGLAB
eeglab % start EEGLAB
filelist = {'example_subject1.set', 'example_subject2.set', 'example_subject3.set'};
nfiles = length(filelist);

% load and process each EEG dataset using FieldTrip
for i = 1:nfiles
    EEG = pop_loadset('filename', filelist{i}, 'filepath', '/path/to/dataset/folder');
    ftdata = eeglab2fieldtrip(EEG, 'preprocessing', 'none');
    
    % append data from each subject into a single FieldTrip structure
    if i == 1
        alldata = ftdata;
    else
        alldata = ft_appenddata([], alldata, ftdata);
    end
end

% load data for each participant
data_files = {'subj1.set', 'subj2.set', 'subj3.set'}; % replace with your filenames
nsubxj = length(data_files);

for subj = 1:nsubj
    
    % read in EEG data
    cfg = [];
    cfg.dataset = data_files{subj};
    eeg_data = ft_preprocessing(cfg);
    
    % create individual scalp surface
    cfg = [];
    cfg.method = 'singlesphere';
    cfg.numvertices = 1000;
    cfg.elec = eeg_data.elec;
    mesh = ft_prepare_mesh(cfg, eeg_data);
    
    % create head model
    cfg = [];
    cfg.method = 'singleshell';
    cfg.conductivity = [0.33 0.0041 0.33]; % tissue conductivity values
    cfg.tissue = {'scalp', 'skull', 'brain'};
    cfg.headmodel = 'custom';
    cfg.headshape = mesh;
    vol = ft_prepare_headmodel(cfg);
    
    % calculate spectral power using multitaper method
    cfg = [];
    cfg.output = 'pow';
    cfg.method = 'mtmfft';
    cfg.foi = 1:30;
    cfg.tapsmofrq = 2;
    cfg.keeptrials = 'yes';
    freq_data = ft_freqanalysis(cfg, eeg_data);
    
    % calculate eLORETA source activity
    cfg = [];
    cfg.method = 'eloreta';
    cfg.grid = vol;
    cfg.eloreta.keepfilter = 'yes';
    cfg.eloreta.normalize = 'yes';
    cfg.eloreta.lambda = 1e-5;
    cfg.eloreta.projectnoise = 'yes';
    source_data = ft_sourceanalysis(cfg, freq_data);
    
    % save eLORETA source activity to file
    save(sprintf('source_data_subj%d.mat', subj), 'source_data');
    
end

% load in source data for each participant
source_files = cell(nsubj, 1);
for subj = 1:nsubj
    source_files{subj} = sprintf('source_data_subj%d.mat', subj);
end
source_data = ft_sourcegrandaverage([], source_files{:});

% plot results on a standard brain template
cfg = [];
cfg.parameter = 'pow';
cfg.interpmethod = 'nearest';
cfg.coordsys = 'mni';
cfg.atlas = 'aal';
ft_sourceplot(cfg, source_data);