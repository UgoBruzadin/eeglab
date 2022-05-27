function [EEG,com] = quick_dotloc(EEG)

[EEG,com] = quick_HM94(EEG);

[EEG,com] = quick_epoch(EEG,0.600,2.648);

[EEG,com] = quick_bss2(EEG);

[EEG,com] = quick_PCA(EEG);

[EEG] = pop_saveset(EEG, 'filename', [strcat( EEG.filename(1:end-4),'Hm92Ep6bssICA','.set')],'filepath',EEG.filepath);

eeglab redraw
end