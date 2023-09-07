

% from https://mailman.science.ru.nl/pipermail/fieldtrip/2015-May/035078.html
cfg = [];
lay = ft_prepare_layout(cfg,fftdata);

cfg = [];
cfg.layout = lay;
ft_layoutplot(cfg);


% from https://natmeg.se/MEEG_course2018/preprocess_MRI_data2.html
mri_coordsys = ft_determine_coordsys(mri); 

% from pop_dipfit_settings
    comp = eeglab2fieldtrip(OUTEEG, 'componentanalysis', 'dipfit');
    if ~isempty(OUTEEG.dipfit.coord_transform)
        % Rational: we change the MRI transformation matrix to match
        % the final sensor space based on the provided transformation
        % matrix (usually computed using fiducials)

        transform_mat = OUTEEG.dipfit.coord_transform;
        if isfield(OUTEEG.chaninfo, 'originalnosedir')
            if strcmpi(OUTEEG.chaninfo.originalnosedir, '+Y')
                transform_mat(6) = transform_mat(6)+pi/2;
                OUTEEG.dipfit.coord_transform = [0 0 0 0 0 0 1 1 1];
                OUTEEG.dipfit.coord_transform(6) = OUTEEG.dipfit.coord_transform(6)-pi/2;
            end
        end
        tra = traditionaldipfit( transform_mat );
        tra = pinv(tra);

        % change MRI coordinate system
        mri = OUTEEG.dipfit.mrifile;
        mri.transform = tra * mri.transform;
        mri.coordsys  = comp.grad.coordsys; % target coordinate system
        mri.unit      = comp.grad.unit;
        OUTEEG.dipfit.mrifile = mri;

        % change head model coordinate system
        hdm = OUTEEG.dipfit.hdmfile;
        hdm.bnd(end).pos = tra * [ hdm.bnd(end).pos ones(length(hdm.bnd(end).pos),1)]';
        hdm.bnd(end).pos = hdm.bnd(end).pos(1:3,:)';
        hdm.unit = comp.grad.unit;
        
        % fiduacial coordinate system
        elec = readlocs(OUTEEG.dipfit.chanfile);
        for iChan = 1:length(elec)
            elecTmp = tra * [elec(iChan).X elec(iChan).Y elec(iChan).Z 1]';
            [elec(iChan).X, elec(iChan).Y, elec(iChan).Z] = deal(elecTmp(1),elecTmp(2),elecTmp(3));
        end
        OUTEEG.dipfit.chanfile = elec;
        
        OUTEEG.dipfit.hdmfile = hdm;
    end