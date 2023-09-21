function EEG = quick_epochdotloc(EEG,UniqueEventNames,time1,time2)

if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

if nargin < 4
    time2 = 2.448;
end
if nargin < 3
    time1 = 0.400;
end
if nargin < 2
    %get unique event names
    EventNames = strings(1,size(EEG.event,2));
    for i=1:size(EEG.event,2)
        EventNames(i) = EEG.event(i).type;
    end
    UniqueEventNames = unique(EventNames);
end

EEG = pop_par_epoch( EEG, { UniqueEventNames }, [time1 time2], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');

end