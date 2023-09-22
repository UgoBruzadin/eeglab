clc
clear

%file1 = getNewFiles(pwd,pwd,'*.jpg','*.set');

file1 = dir('*.set');
path1 = pwd;

mkdir('Error');
cd('./Error');
fileERROR = pwd;
cd ..

%range = [3.5 30];
frequencies = [3 30];
downsample = 2;
%frequencies = [8 12];

headmodel = load('-mat', 'C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_vol.mat');
headmodel = headmodel.vol;


%% read headmodel & MRI
leadfield = load('-mat', 'leadfield.mat');
leadfield = leadfield.leadfield;
    
    load('-mat', 'C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_mri.mat');
    mri = ft_volumereslice([], mri);
    %mri.mri.coordsys = 'mni';
    mri.coordsys = 'mni';
    %mri.unit = 'mm';

%% interpolate atlas to MRI

    atlas = ft_read_atlas('ROI_MNI_V4.nii');
    atlas.coordsys = 'mni';
    atlas.anatomy = atlas.tissue;
    atlas.anatomylabel = atlas.tissuelabel;
    
    cfg = [];
    cfg.interpmethod = 'nearest';
    cfg.parameter = 'anatomy';
    %cfg.downsample      = 2;
    mri_int = ft_sourceinterpolate(cfg,mri,atlas);
    %ft_sourceplot(cfg,atlas_int);


    cfg = [];
    cfg.interpmethod = 'nearest';
    cfg.parameter = 'anatomy';
    %cfg.downsample      = 2;
    atlas_int = ft_sourceinterpolate(cfg,atlas,mri_int);


% for debugging


% spmd
%     addpath(genpath('C:\GitHub\eeglab\plugins\spm12')); % Replace '/path/to/spm' with the actual path
% end
eeglab;
%i = 1;

%delete(gcp('nocreate'))
%parpool(6);

for i=1:length(file1)
    %eeglab;
    %addpath(genpath('C:\GitHub\eeglab\plugins\spm12'));
    try
    EEG = pop_loadset(file1(i).name, path1);
        %EEG = pop_eegfiltnew(EEG, 'locutoff',7.75,'hicutoff',12.25,'plotfreqz',0);

    if EEG.nbchan > 92
        [EEG,com] = quick_HM94(EEG);
    end

    if EEG.pnts > 512
        [EEG,com] = quick_epoch(EEG,0.600,2.648);
    end
    
    %remove 7 frontal channels
    if EEG.nbchan > 87
    chans = [1 7 12 17 20 26 90];
    try [EEG,com] = pop_select( EEG,'nochannel',[1 7 12 17 20 26 90]);
    catch
        for j = chans
            try pop_select( EEG,'nochannel',[j]);
            catch; end
        end
    end
    end
        %% compute spectral params (only need to be done once to get the right structures)

        %% make eeglab data into fieldtrip
        ftEEG = eeglab2fieldtrip(EEG, 'preprocessing', 'none');

        %% perform channel transformation
        
        transform = [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213]; % transformation
        transform = transform.*[1         1       1      1+pi/2        1               1       1       1       1]; % rotate head
        
        electransf = struct();
        elec1    = ftEEG.elec;
        electransf.pnt = [];

        if size(transform,1) > 1
            electransf.pnt = transform*[ elec1.pnt ones(size(elec1.pnt,1),1) ]';
        else
            electransf.pnt = traditionaldipfit(transform)*[ elec1.elecpos ones(size(elec1.elecpos,1),1) ]';
        end
        electransf.pnt   = electransf.pnt(1:3,:)';
        %electransf.pnt   = electransf.pnt/10; NEEDEDD TO PLOT THE ELECTRODES CORRECTLY IN ONE MODEL

        %electransf.label = elec1.label;
        ftEEG.elec.pnt = electransf.pnt;
        ftEEG.elec.elecpos = electransf.pnt;

        %% run FFT

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
        %parsave([file1(i).name(1:end-4),'_dataFreq.mat'],dataFreq,'-v7.3')
        %EEG.lor.fftdata = dataFreq;
        
        %load headmodel
        

        %% create leadfield

        headmodel = load('-mat', 'leadfield.mat');
        %headmodel = load('-mat', 'C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_vol.mat');
        %headmodel = headmodel.vol;

%         cfg                 = [];
%         cfg.elec            = dataFreq.elec;
%         cfg.headmodel       = headmodel;
%         %cfg.reducerank      = 2;
%         cfg.resolution = 4;   % use a 3-D grid with a X cm resolution
%         cfg.sourcemodel.unit       = 'mm';
%         cfg.channel         = { 'all' };
%         cfg.parallel = 'yes';
%         cfg.solver = 'cg';
% 
%         [leadfield] = ft_prepare_leadfield(cfg);
% 
%         save leadfield leadfield

        %% Run eLORETA

        %freq = frequencies(1,:);

        cfg = [];
        cfg.elec = elec;
        cfg.eloreta.keepcsd       = 'yes';
        cfg.eloreta.keepmom = 'yes';
        cfg.eloreta.keepfilter    = 'yes';
        cfg.keepleadfield = 'yes';

        cfg.normalize = 'yes';
        cfg.frequency    = frequencies;
        cfg.sourcemodel  = leadfield;
        cfg.headmodel    = headmodel;
        % cfg.sourcemodel = EEG.dipfit.sourcemodel; % NEWLY ADDED
        cfg.method       = 'eloreta';
        %cfg.atlas        = source_model_atlas;
        %cfg.roi          = atlas.tissuelabel;
        cfg.eloreta.projectnoise = 'yes';
        cfg.eloreta.lambda   = .5;
        cfg.gpu           = 'yes';
        
        source = ft_sourceanalysis(cfg, dataFreq);
        source.coordsys = 'mni';
        %parsave([file1(i).name(1:end-4),'_source.mat'],source,'-v7.3')

        % FOR DEBUGGING PURPOSES
        %source = load([file1(i).name(1:end-4),'_source.mat']);
        %try source = source.source; catch; end

        %% INTERPOLATE source to ATLAS (not MRI anymore)

        cfg                 = [];
        cfg.parameter       = 'pow';
        cfg.interpmethod = 'nearest';
        cfg.coordsys     = 'mni';
        source.dimord = 'pos_freq';
        source.oridimord = 'pos';
        source.momdimord = 'pos';
        source.powdimord = 'pos_freq';
        %cfg.downsample      = downsample;
        %cfg.parameter = 'tissue';
        
        source_int = par_ft_sourceinterpolate(cfg,source,atlas);

        %source_int = load([file1(i).name(1:end-4),'_source_int.mat']);
        %try source_int = source_int.source_int; catch; end
        
        %parsave([file1(i).name(1:end-4),'_source_int.mat'],source_int,'-v7.3')

        %% interpolate source into interpolated atlas and save figure

        cfg                 = [];
        cfg.method          = 'ortho';
        cfg.funparameter    = 'pow_z';
        cfg.powdimord = 'pos_freq';
        cfg.location = 'max';
        cfg.atlas        = atlas_int;
        

        source_int.pow_z = nanzscore(source_int.pow,0,1);
        ft_sourceplot(cfg,source_int);

        bands = [4 8;8 12;12 30];        
        band_label = ['theta';'alpha';'beta '];

        for ii = 1:size(bands,1)
            cfg.frequency = [bands(ii,1) bands(ii,2)];
            cfg.avgoverfreq = 'yes';
            ft_sourceplot(cfg,source_int);
            textsc(sprintf(file1(i).name, ' eLoreta csd at ',band_label(ii,:)), 'title');
            saveas(gcf,[file1(i).name(1:end-4),band_label(ii,:),'_LOR.jpg']);
            close gcf
        end

    catch
        movefile(file1(i).name, fileERROR)
        close all
    end
end

    %% OLD SHIT

    %     cfg.atlas        = atlas_int;
    %     %cfg.roi          = atlas_int.tissuelabel;
    %     %cfg2.maskparameter = cfg2.funparameter;
    %     %cfg2.opacitymap = 'rampup';
    %     %cfg2.location = 'peak';
    %     %cfg2.flipori = 'yes';

    %     %textsc(sprintf('eLoreta source localization of %d frequency power',freq), 'title');
    %     ft_sourceplot(cfg,source);
    %     textsc(sprintf('eLoreta source localization of %d frequency power',freq), 'title');

    %TESTING THIS WORKS!
    % atlas = ft_read_atlas('ROI_MNI_V4.nii');
    % atlas.coordsys = 'mni';
    % atlas.anatomy = atlas.tissue;
    % atlas.anatomylabel = atlas.tissuelabel;
    %
    % cfg = [];
    % cfg.interpmethod = 'nearest';
    % cfg.parameter = 'anatomy';
    % atlas_int = ft_sourceinterpolate(cfg,atlas,mri);
    % ft_sourceplot(cfg,atlas_int);
    %
    % %EEG.lor.atlas_int = atlas_int;
    %
    % cfg                 = [];
    % cfg.method          = 'ortho';
    % cfg.funparameter    = 'pow';
    % %cfg.avgoverfreq = 'yes';
    % cfg.atlas        = atlas_int;
    % %cfg.roi = atlas_int.anatomylabel(1:10);
    % ft_sourceplot(cfg,source_int);

    %THIS DOESN'T!
    %atlas = ft_read_atlas('ROI_MNI_V4.nii');
    %atlas.coordsys = 'mni';
    %     cfg = [];
    %     cfg.interpmethod = 'nearest';
    %     cfg.parameter = 'anatomy';
    %     atlas_int_mri = ft_sourceinterpolate(cfg,atlas,source_int);

    %EEG.lor.atlas_int_int = atlas_int;

    %     cfg                 = [];
    %     cfg.method          = 'ortho';
    %     cfg.funparameter    = 'pow';
    %     cfg.maskparameter = cfg.funparameter;
    %     cfg.atlas        = atlas_int_mri;
    %     cfg.roi = cfg.atlas.anatomylabel(1:12);
    %     %cfg.avgoverfreq = 'yes' = plots 1 freq only
    %     ft_sourceplot(cfg,source_int);
    %cfg.atlas        = atlas_int_int;
    %try ft_sourceplot(cfg,source_int); catch; end

    %     % CEN
    %     SPL = cfg.atlas.anatomylabel(59:60);
    %     dlPFC = cfg.atlas.anatomylabel(3:4); %May need adjustments
    %     % SN
    %     ACC = cfg.atlas.anatomylabel(31:32);
    %     INS = cfg.atlas.anatomylabel(29:30);
    %     % DMN
    %     mPFC = cfg.atlas.anatomylabel(7:8); %May need adjustments
    %     PCC = cfg.atlas.anatomylabel(35:36);
    %
    %     cfg.roi = cat(2,dlPFC,SPL,PCC,INS,mPFC,ACC);
    %     ft_sourceplot(cfg,source_int);


    %
    %     cfg = [];
    % cfg.parameter = 'pow';
    % cfg.roi = cat(2,dlPFC,SPL,PCC,INS,mPFC,ACC);
    % cfg.statistics = 'mean';
    % cfg.method = 'montecarlo'; % or 'stats'
    % cfg.design = '' % gotta make the
    % cfg.avgoverroi = 'no';
    % cfg.hemisphere = 'combined';
    % stats = ft_sourcestatistics(cfg, source_int);
%
% %end

%% history
function source_int = par_ft_sourceinterpolate(cfg,source,atlas_int)
isworker = getCurrentWorker();
    
currentFunction = 'par_ft_sourceinterpolate';
fprintf('Currently running: %s\n', currentFunction);% Print the name of the currently running function

source_ints = repmat(struct('sources',[]), length(source.freq), 1);
        if ~isempty(isworker)
        for j=1:size(source_ints,1)
            individual_source = source;
            individual_source.avg.pow = source.avg.pow(:,j);
            source_ints(j).sources      = ft_sourceinterpolate(cfg, individual_source, atlas_int);
        end
        else
        parfor j=1:size(source_ints,1)
            individual_source = source;
            individual_source.avg.pow = source.avg.pow(:,j);
            source_ints(j).sources      = ft_sourceinterpolate(cfg, individual_source, atlas_int);
        end    
        end

        source_int = source_ints(1).sources;
        for k=2:length(source.freq)
            source_int.pow = cat(2,source_int.pow,source_ints(k).sources.pow);
        end
        source_int.powdimord = 'pos_freq';
end

function parsave(name, variable, flag)

  string = inputname(2);
  if strcmp(string,'dataFreq')
      dataFreq = variable;
      save(name, 'dataFreq', flag)
  elseif strcmp(string,'source')
      source = variable;
      save(name, 'source', flag)
  elseif strcmp(string,'source_int')
      source_int = variable;
      save(name, 'source_int', flag)
  end
end

%disp('Done');
%com = sprintf('pop_dipfit_loretaQL(EEG, %s);', vararg2str( { select, range, frequencies, varargin}));