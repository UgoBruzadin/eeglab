function [EEG,com] = quick_epoch(EEG,time1,time2,eventname)

if isempty(EEG.data)
    [EEG,com] = pop_loadset();
    eeglab redraw
end

if nargin < 2
    time1 = 1;
end
if nargin < 3
    [EEG,com] = eeg_regepochs(EEG,'recurrence',time1);
else
    if nargin < 4
        eventname = EEG.event(2).type;
    end
    [EEG,com] = pop_par_epoch( EEG, { eventname }, [time1 time2], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
end
    
%EEG = pop_par_epoch( EEG, { UniqueEventNames }, [time1 time2], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');

end