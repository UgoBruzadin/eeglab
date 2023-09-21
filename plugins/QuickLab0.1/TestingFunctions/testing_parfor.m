
clc
clear all


fileINPUT = pwd;
files = dir('*.set');

eeglab;

% p = parpool("local",12);
% spmd
%     labindex
% end

parfor i=1:length(files) 
    EEG = pop_loadset( files(i).name, fileINPUT);
    if rem(i/12) > 0 
        
        EEG = pop_par_runica(EEG,'icatype','binica', 'extended', 1, 'pca', IC2-1, 'verbose','off');
    else
        EEG = pop_par_runica(EEG,'icatype','cudaica', 'extended', 1, 'pca', IC2-1, 'verbose','off');
    end
end