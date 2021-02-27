function [EEG, acronym] = pipe_notchfilter(EEG)
    EEG = eeg_checkset( EEG );
    twoamps = [2002, 2008, 2010, 2024, 9104, 9109, 9140, 9143, 9243, 9209];
    threeamps = [1109, 1121, 1143];
    if ~ismember(str2num(EEG.setname(1:4)),threeamps) && str2num(EEG.setname(1:4)) <= 2000 ||  ismember(str2num(EEG.setname(1:4)), twoamps) %200 amps
        EEG = pop_eegfiltnew(EEG, 'locutoff',40,'hicutoff',44,'revfilt',1,'plotfreqz',1);
        EEG = eeg_checkset( EEG );
        EEG = pop_eegfiltnew(EEG, 'locutoff',59,'hicutoff',61,'revfilt',1,'plotfreqz',1);
        acronym = 'NF4460'
    else
        EEG = eeg_checkset( EEG );
        EEG = pop_eegfiltnew(EEG, 'locutoff',47,'hicutoff',53,'revfilt',1,'plotfreqz',1);
        EEG = eeg_checkset( EEG );
        EEG = pop_eegfiltnew(EEG, 'locutoff',59,'hicutoff',61,'revfilt',1,'plotfreqz',1);
        acronym = 'NF4760'
    end
end