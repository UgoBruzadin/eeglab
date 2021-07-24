%--- script made by Ugo Nunes
% on 07/22/2021
% generates FFTs but also save FFTs to the file

clc
clear all


fileINPUT = pwd;
files = dir('*.set');

eeglab;
parfor i=1:length(files) 
    EEG = pop_loadset( files(i).name, fileINPUT);

    filter = EEG.filename(end-17:end-14)
    
    if filter == "LP18"
        EEG.low = 18
        EEG.high = 55;
    else
        EEG.low = 2
        EEG.high = 1
    end
    EEG = pop_saveset( EEG, 'savemode','resave');
end