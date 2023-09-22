
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
    
    %% interpolates ATLAS to MRI %removed
%     cfg = [];
%     cfg.interpmethod = 'nearest';
%     cfg.parameter = 'anatomy';
%     cfg.downsample      = 2;
%     atlas_int = ft_sourceinterpolate(cfg,atlas,mri);

%     ft_sourceplot(cfg,atlas_int); %plots atlas

%% loads EEGLAB

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
        ftEEG.elec.pnt = electransf.pnt;
        ftEEG.elec.elecpos = electransf.pnt;


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

        %% create leadfield
              
        cfg                 = [];
        cfg.elec            = dataFreq.elec;
        cfg.headmodel       = headmodel;
        %cfg.reducerank      = 2;
        cfg.resolution = 5;   % use a 3-D grid with a X mm resolution
        cfg.sourcemodel.unit       = 'mm';
        cfg.channel         = { 'all' };
        cfg.parallel = 'yes';
        cfg.solver = 'cg';

        if leadfield.cfg.resolution ~= cfg.resolution  
            [leadfield] = ft_prepare_leadfield(cfg);
            save leadfield leadfield
        end

        %% Perform eLORETA
        
        headmodel = load('-mat', 'leadfield.mat');
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
        cfg.projectnoise = 'yes';
        cfg.eloreta.lambda   = .5;
        cfg.gpu           = 'yes';
        
        source = ft_sourceanalysis(cfg, dataFreq);
        source.coordsys = 'mni';
        %parsave([file1(i).name(1:end-4),'_source.mat'],source,'-v7.3')

        % FOR DEBUGGING PURPOSES
        %source = load([file1(i).name(1:end-4),'_source.mat']);
        %try source = source.source; catch; end

        %% INTERPOLATE source to MRI

        cfg                 = [];
        %cfg.downsample      = 2;
        cfg.parameter       = 'pow';
        cfg.interpmethod = 'nearest';
        cfg.coordsys     = 'mni';
        %cfg.downsample      = 2;
        source.dimord = 'pos';
        source.oridimord = 'pos';
        source.momdimord = 'pos';
        source.powdimord = 'pos_freq';
        %cfg.downsample      = downsample;


        source_int = par_ft_sourceinterpolate(cfg,source,atlas);
        %source_int = load([file1(i).name(1:end-4),'_source_int.mat']);
        %try source_int = source_int.source_int; catch; end
        
        parsave([EEG.filename(1:end-4),'_source_int.mat'],source_int,'-v7.3')

        %% interpolate source into interpolated atlas and save figure

        cfg                 = [];
        cfg.method          = 'ortho';
        cfg.funparameter    = 'pow';
        cfg.powdimord = 'pos_freq';
        cfg.location = 'max';
        cfg.atlas        = atlas;
        ft_sourceplot(cfg,source_int);

        cfg.funparameter    = 'pow_z';
        source_int.pow_z = nanzscore(source_int.pow,0,1);
        ft_sourceplot(cfg,source_int);
