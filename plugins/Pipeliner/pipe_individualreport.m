function [tempTable] = pipe_individualreport(filename,EEG)
    tempTable = {filename,EEG.nbchan,EEG.chanlocs(1).ref,EEG.srate,EEG.trials,length(EEG.event),EEG.xmax,size(EEG.icaweights,1)};

    if ~isempty(EEG.icaweights) & ~isempty(EEG.etc.ic_classification.ICLabel.classifications) %this picks up the iclabel classifications if any
        for k=1:length(EEG.etc.ic_classification.ICLabel.classifications)
            [max_num,max_idx] = max(EEG.etc.ic_classification.ICLabel.classifications(k,:));
            tempTable{end+1} = cell2mat((EEG.etc.ic_classification.ICLabel.classes(max_idx)));
            tempTable{end+1} = round(max_num*100,3);
        end
        for l=1:(128-length(EEG.etc.ic_classification.ICLabel.classifications))
            tempTable{end+1} = '';
            tempTable{end+1} = 0;
        end
    end
end