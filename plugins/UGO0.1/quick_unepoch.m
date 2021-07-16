function EEG = quick_unepoch(EEG)

if EEG.trials > 1

EEG.data = reshape(EEG.data , EEG.nbchan, EEG.trials*EEG.pnts);
EEG.xmax = EEG.trials*EEG.pnts;
%if events
%for lenght of events
%delete all events with X
%         EventNames = strings(1,size(EEG.event,2));
%     for i=1:size(EEG.event,2)
%         EventNames(i) = EEG.event(i).type;
%     end
%     UniqueEventNames = unique(EventNames);
%EEG.event = [];EEG.urevent =[];
EEG.trials = 1;
EEG.times = 1:EEG.trials*EEG.pnts;
EEG.trials = 1;
else
    fprintf('Nothing done. File is already in continuous shape \r');
end
end