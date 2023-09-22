function EEG = renamefiles(EEG)

A = EEG.filename;

dotlocnum = A(14);
nfilter = A(34:35);
BE = strfind(A,'BE');

EEG = pop_saveset(EEG, 'filename', [strcat(A(1:6),'dl_',dotlocnum,'HA255_N',nfilter,'Tr',A(BE+1:end))], 'filepath',  pwd ); %save set

end