
clc
clear all
files = dir('*.set');
fdtfiles = dir('*.fdt');

fileINPUT = pwd;
cd ..
fileOUTPUT = pwd;

mkdir('Error');
cd('./Error');
fileOUTPUTError = pwd;

cd (fileINPUT);

seconds = 6; %%%number of seconds to be left behind first event
t = datestr(datetime('now','TimeZone','local','Format','dMMMy-HH.mm'));

eeglab;
for i=1:length(files)
    [EEG] = pop_loadset('filename',{files(i).name});
    ENDTRIMMED = 0;
    BEGTRIMMED = 0;
    % ---  decides max number of events. DotLoc2 have upto 64, 1 upto 61
    try
    if files(i).name(14) == 1
        maxNumEvents = 60;
    elseif files(i).name(14) == 2
        maxNumEvents = 63;
    else
        %break? save? crash error save somewhere else
    end
    if isempty(EEG.event)
        EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4),'NOEVENTS.set')], 'filepath',  fileOUTPUTError );
    else
    
        dins = cat(1,string(char(EEG.event.type)));
        latency = cat(1,EEG.event.latency);
        
        cutTime = seconds*EEG.srate;
        
        EEG.etc.events = cat(2,dins, latency);
        EEG.etc.events2 = flip(EEG.etc.events);
        counting = 0;
        
        %TRIM THE END FIRST
        for j=1:length(EEG.etc.events2)
            if contains(EEG.etc.events2(j,1),'DIN')
                timeCutoffEnd = str2double(EEG.etc.events2(j,2)) + cutTime; %PLUS BECAUSE IT'S THE END + 6 seconds
                if timeCutoffEnd < EEG.xmax*1000
                    EEG = eeg_eegrej( EEG, [0 timeCutoffEnd]);
                    ENDTRIMMED = 1;
                    break
                end
            end
        end
        
        %TRIM BEGGINING
    %strcmp(EEG.etc.events(:,1),'DIN ')
        dins = cat(1,string(char(EEG.event.type)));
        latency = cat(1,EEG.event.latency);
        
        cutTime = seconds*EEG.srate;
        
        EEG.etc.events = cat(2,dins, latency);
        EEG.etc.events2 = flip(EEG.etc.events);
        counting = 0;
        boundaries = [];
        epocs = [];
        CountDins = sum(count(EEG.etc.events(:,1),'DIN'))
    
        if CountDins < maxNumEvents
            maxNumEvents = CountDins;
        end
        for k=1:maxNumEvents
            if contains(EEG.etc.events2(k,1),'DIN')
                counting = counting + 1;
            end
            if counting == maxNumEvents
                timeCutoffBeg = str2double(EEG.etc.events2(k,2))-cutTime;
                if timeCutoffBeg > 0
                    EEG = eeg_eegrej( EEG, [0 timeCutoffBeg]);
                    BEGTRIMMED = 1;
                end
                break
            end
        end
    
        dins = cat(1,string(char(EEG.event.type)));
        latency = cat(1,EEG.event.latency);
        
        cutTime = seconds*EEG.srate;
        
        EEG.etc.events = cat(2,dins, latency);
        EEG.etc.events2 = flip(EEG.etc.events);
        % gets all occurences of 'epoc'
        epocs = find(strcmp(EEG.etc.events(:,1),'epoc'));
        % if there are any occurences of 'epoc'
        if ~isempty(epocs)
            firstDin = str2double(EEG.etc.events(epocs(end)+1,2));
            timeCutoffBeg = firstDin - newcutTime;
            if firstDin-(seconds*EEG.srate) > 0
                EEG = eeg_eegrej( EEG, [0 timeCutoffBeg]);
                BEGTRIMMED = 1;
            end
        else
        end
        if ~isempty(EEG.event)
            NumberOfEvents = num2str(size(EEG.event,2))
        else
            NumberOfEvents = '00';
        end
        if BEGTRIMMED == 1
            EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4),'_Tr',NumberOfEvents,'.set')], 'filepath',  fileOUTPUT ); %save set
        else
            EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4),'_nT',NumberOfEvents,'.set')], 'filepath',  fileOUTPUT ); %save set
        end
    end
    catch
        if ~isempty(EEG.event)
            NumberOfEvents = num2str(size(EEG.event,2))
        else
            NumberOfEvents = '00';
        end
            EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4),'_ER',NumberOfEvents,'.set')], 'filepath',  fileOUTPUT ); %save set
    end
    EEG = pop_delset(EEG,1);
end



