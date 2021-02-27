function [EEG, acronym] = pipe_pca(IC, EEG) %works
    if iscell(IC)
        IC = cell2mat(IC);
    end
    EEG = eeg_checkset(EEG);
    EEG = pop_runica(EEG,'extended', 1, 'pca', IC, 'verbose','off');
    EEG = eeg_checkset(EEG);
    EEG = pop_iclabel(EEG,'default');
    acronym = char(strcat('IC',num2str(IC)));
end