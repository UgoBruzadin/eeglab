function EEG = quick_rerefavg(EEG)

if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

% EEG = pop_reref( EEG, [],'keepref','on');

EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}));

end