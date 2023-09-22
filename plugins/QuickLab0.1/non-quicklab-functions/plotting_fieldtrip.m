figure;
elec = ft_read_sens('HCGSN128Renamed.sfp', 'senstype', 'eeg')

elec = ft_plot_sens(elec,'style','*b')
hold on
ft_plot_headmodel(vol);

hold on
ft_plot_mri(mri);
