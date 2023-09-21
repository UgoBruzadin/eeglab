%Generate sourcemodel and leadfields (common for all data)

    cfg = [];
    cfg.headmodel = vol;
    cfg.elec = elec_aligned;
    cfg.grid.resolution = 6;   % use a 3-D grid with a 6mm resolution
    cfg.grid.unit       = 'mm';
    cfg.channel = 1:32;

    grid = ft_prepare_leadfield(cfg);

%Load the data

%Calculate the channel covariance matrix for all exposures
        cfg = [];
        cfg.covariance = 'yes';
        cfg.covariancewindow = 'all';
        cfg.keeptrials  = 'yes';
        timelock_allexp = ft_timelockanalysis(cfg, data_filt);

%Calculate the channel covariance matric for each exposure separate
        timelock=cell(length(exposures));
        for j=1:length(exposures)
            cfg = [];
            cfg.covariance = 'yes';
            cfg.covariancewindow = 'all';
            cfg.trials = find(ismember(trialinfo, exposures{j}));
            cfg.keeptrials  = 'yes';
            timelock{j} = ft_timelockanalysis(cfg, data_filt);
        end

%General source localisation
        cfg = [];
        cfg.headmodel = vol;
        cfg.elec = elec_aligned;
        cfg.grid = grid;
        cfg.method = 'lcmv';
        cfg.lcmv.fixedori = 'yes';  %Project onto largest variance orientation
        cfg.lcmv.keepfilter = 'yes'; %Keep the beamformer weights
        cfg.lcmv.lambda = '5%'; %Regularise a little
        source_allexp = ft_sourceanalysis(cfg, timelock_allexp);

% source localisation for each exposure separate using combined filter
        cfg = [];
        cfg.headmodel = vol;
        cfg.elec = elec_aligned;
        cfg.grid = grid;
        cfg.grid.filter = source_allexp.avg.filter; % use the common filter computed in the previous step!
        cfg.method = 'lcmv';
        cfg.lcmv.fixedori = 'yes';  %Project onto largest variance orientation
        cfg.lcmv.lambda = '5%'; %Regularise a little
        cfg.rawtrial    = 'yes';      % project each single trial through the filter.
        cfg.keeptrials  = 'yes';

        parc_sources=cell(length(exposures),1);
        for j=1:length(exposures)
            source = ft_sourceanalysis(cfg, timelock{j});
            source = ft_datatype_source(source);

            cfg = [];
            cfg.parameter = 'all';
            source_int = ft_sourceinterpolate(cfg, source, atlas);

            cfg = [];
            cfg.method       = 'max';
            parc_sources{j}=ft_sourceparcellate(cfg, source_int, atlas);
        end

%I hope my code for source parcellation helps to solve your problem.

%Regards,

%Xavier
