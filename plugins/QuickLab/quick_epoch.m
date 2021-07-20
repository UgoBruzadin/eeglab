function EEG = quick_epoch(EEG,time)

if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

if nargin < 2
    time = 1;
end

EEG = eeg_regepochs(EEG,'recurrence',time);

%EEG = pop_par_epoch( EEG, { UniqueEventNames }, [time1 time2], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');

end