
EEGOUT = pop_dipfit_settingsQL( EEG, 'hdmfile',...
    'C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile',...
    'C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\standard_mri.mat','chanfile',...
    'C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\elec\\standard_1005.elc',...    
    'coord_transform',...
    [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213],...
    'model','standardBEM');


% get eletrodes
elec = ft_read_sens('HCGSN128Renamed.sfp', 'senstype', 'eeg');

transform = [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696+pi/2 11.7138 12.7933 12.213];

%transformmat = dat.transform;

elec1    = elec;
electransf.pnt = [];
if size(transform,1) > 1
    electransf.pnt = transform*[ elec1.pnt ones(size(elec1.pnt,1),1) ]';
else
    electransf.pnt = traditionaldipfit(transform)*[ elec1.elecpos ones(size(elec1.elecpos,1),1) ]';
end
electransf.pnt   = electransf.pnt(1:3,:)';
electransf.pnt   = electransf.pnt/10;
electransf.label = elec1.label;

elec.chanpos = electransf.pnt;

%elec = ft_convert_units(elec,'mm');

% align/plot MRI
cfg = [];
cfg.method = 'fiducial';
mri = ft_read_mri('C:\\GitHub\\eeglab\\plugins\\dipfit5.1\\standard_BEM\\standard_mri.mat');
mri.coordsys = 'ctf';
%mri_realigned = ft_volumerealign(cfg, mri);
cfg.viewmode = 'surface';
cfg.fiducial.nas = elec.elecpos(1,:); %position of nasion
cfg.fiducial.lpa    = elec.elecpos(2,:); %, position of LPA
cfg.fiducial.rpa    = elec.elecpos(3,:); %, position of RPA
%mri_realigned = ft_volumerealign(cfg, mri);

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
ft_plot_sens(elec, 'style', '*b');

hold on
ft_plot_headmodel(vol);

% align/plot electrodes
%cfg = [];
%cfg.method = 'interactive';
%cfg.method = 'interactive';
%cfg.template = ft_read_sens('C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\elec\\standard_1005.elc');
% cfg.target.pos(1,:) = elec.elecpos(1,:);     % location of the nose
% cfg.target.pos(2,:) = elec.elecpos(2,:);     % location of the left ear
% cfg.target.pos(3,:) = elec.elecpos(3,:);     % location of the right ear
% cfg.target.label    = {'FidNz', 'FidT9', 'FidT10'};
%cfg.mri = mri;
%elec_realigned = ft_electroderealign(cfg, elec);


%cfg.viewmode = 'surface';
%cfg.fiducial.nas = elec.elecpos(1,:); %position of nasion
%cfg.fiducial.lpa    = elec.elecpos(2,:); %, position of LPA
%cfg.fiducial.rpa    = elec.elecpos(3,:); %, position of RPA
%mri_realigned = ft_volumerealign(cfg, vol);
%mri_realigned = ft_volumerealign(cfg, mri);
%hold on;

