function EEG = quick_epoch(EEG,time1,time2)

if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

if nargin < 2
    time1 = 1;
end
if nargin < 3
    EEG = eeg_regepochs(EEG,'recurrence',time1);
else
    EEG = pop_par_epoch( EEG, { EEG.events(2).type }, [time1 time2], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
end
    
%EEG = pop_par_epoch( EEG, { UniqueEventNames }, [time1 time2], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');

end