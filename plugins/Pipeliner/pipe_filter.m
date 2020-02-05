function [EEG, acronym] = pipe_filter(commands,EEG) %should work
    %store filter somewhere
    %content = cell2mat(content);
    EEG = pop_eegfiltnew(EEG, 'locutoff',cell2array(commands(1)),'plotfreqz', 0);
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'hicutoff',cell2array(commands(2)),'plotfreqz', 0);
    acronym = char(strcat('FI',num2char(cell2array(commands(1))),'-',num2char(cell2array(commands(2)))));
end