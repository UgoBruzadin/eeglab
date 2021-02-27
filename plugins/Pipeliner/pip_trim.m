function [acronym, EEG] = pipe_trim(content, EEG)
try
    originalTotalPoints = EEG.pnts;
    beginning = content(1); 
    ending = content(2);
    upperEvent = 1;
    lowerEvent = 1;
    
    if length(EEG.event) < 5
        acronym = 'noEventNoTrim';
        break
    else
        nameOfFirstEvent = EEG.event(1).type;
        nameOfLastEvent = EEG.event(end).type;
        timeOfFirstEventBins = EEG.event(1).latency; %in bins
        timeOfLastEventBins = EEG.event(end).latency; %in bins
        
        if nameOfFirstEvent == 'epoc' || 'boundary'
            nameOfFirstEvent = EEG.event(1+upperEvent).type;
            timeOfFirstEventBins = EEG.event(1+upperEvent).latency; %in bins
        end

        if nameOfLastEvent == 'epoc' || 'boundary'
            nameOfLastEvent = EEG.event(end-1).type;
            timeOfLastEventBins = EEG.event(end-1).latency; %in bins
        end
    end
    
    totalFatTrimmedBeg = 0;
    totalFatTrimmedEnd = 0;
    timeCutoffBeg = (timeOfFirstEventBins-(beginning*EEG.srate));
    timeCutoffEnd = (timeOfLastEventBins-(ending*EEG.srate));
    
    %rejecting beggining to first event minus 7 seconds, and last event plus 7 seconds to end of file.
    if  ~(timeCutoffEnd >= EEG.pnts)
        EEG = eeg_eegrej( EEG, [timeCutoffEnd EEG.pnts]);
        totalFatTrimmedEnd = originalTotalPoints - timeCutoffEnd;
    else
        totalFatTrimmedEnd = 0;
    end
    
    if ~(timeCutoffBeg <= 0)
        EEG = eeg_eegrej( EEG, [0 timeCutoffBeg]);
        totalFatTrimmedBeg = timeCutoffBeg;
    else
        totalFatTrimmedBeg = 0;
    end
    
    acronym = 'Tr'
    %Creating Report Table
catch
    acronym = 'trError'
    EEG = EEG;
end
end
