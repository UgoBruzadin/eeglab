% ensure that the electrode coordinates are in mm
elec = ft_convert_units(elec,'mm'); % should be the same unit as MRI

% these are expressed in the coordinate system of the electrode position capture device
Nas = elec.chanpos(strcmp(elec.label, 'FidNz'),:);
Lpa = elec.chanpos(strcmp(elec.label, 'FidT9'),:);
Rpa = elec.chanpos(strcmp(elec.label, 'FidT10'),:);

% determine the same marker locations in voxel coordinates, e.g., [57,127,15])
% find fiducials e.g., by using ft_sourceplot(cfg, mri) which plots a figure in which
% you can interactively select slices of the mri
% You can also use ft_volumerealign with cfg.interactive='yes' and obtain the fiducials from the output.cfg.fiducial
cfg = [];
cfg.method = surface;

ft_sourceplot(cfg, mri)

vox_Nas = mri.nasion;  % fiducials saved in mri structure
vox_Lpa = mri.left;
vox_Rpa = mri.right;

vox2head = mri.transform; % transformation matrix of individual MRI

% transform voxel indices to MRI head coordinates
head_Nas          = warp_apply(vox2head, vox_Nas, 'homogenous'); % nasion
head_Lpa          = warp_apply(vox2head, vox_Lpa, 'homogenous'); % Left preauricular
head_Rpa          = warp_apply(vox2head, vox_Rpa, 'homogenous'); % Right preauricular

elec_mri.chanpos = [
  head_Nas
  head_Lpa
  head_Rpa
  ];
elec_mri.label = {'nasion', 'left', 'right'};
elec_mri.unit  = 'mm';

% coregister the electrodes to the MRI using fiducials
cfg = [];
cfg.method   = 'fiducial';
cfg.template = elec_mri;
cfg.elec     = elec;
cfg.fiducial = {'nasion', 'left', 'right'};
elec_new = ft_electroderealign(cfg);

% interactively coregister the electrodes to the BEM head model
% this is a visual check and refinement step
cfg = [];
cfg.method    = 'interactive';
cfg.elec      = elec;
cfg.headshape = vol.bnd(1);
elec_new = ft_electroderealign(cfg);