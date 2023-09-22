clc
clear;

files = dir('*.set');
[ files ] = GetAllDirFiles(pwd, 'set');

eeglab;

parfor i=1:length(files)
    
    cd(files(i).folder);
    EEG = pop_loadset(files(i).name,files(i).folder);
    [EEG] = eeglab2sloreta( EEG,'1:6',[]);

end