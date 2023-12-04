function [EEG,LASTCOM] = pop_export_ica(EEG)

weights = EEG.icaweights;
%sphere  = EEG.icasphere;

currentfolder = pwd;

cd(EEG.filepath)

save(['ICA_weights_',EEG.filename],"weights")
%save(['ICA_sphere_',EEG.filename],"sphere")

cd(currentfolder);

LASTCOM = '[EEG,LASTCOM] = pop_export_ica(EEG)';

