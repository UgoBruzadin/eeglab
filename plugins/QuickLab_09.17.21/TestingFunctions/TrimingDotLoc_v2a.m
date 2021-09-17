
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
numberOfEventsLeft = 60;
seconds = 6; %%%number of seconds to be left behind first event
t = datestr(datetime('now','TimeZone','local','Format','dMMMy-HH.mm'));

eeglab;
for i=1:length(files)
    [EEG] = pop_loadset('filename',{files(i).name});
    TRIMMED = 0;
    % ---  decides max number of events. DotLoc2 have upto 64, 1 upto 61
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
        
        % --- collect EVENTS and LATENCY in an array
        events = cat(1,string(char(EEG.event.type)));
        latency = cat(1,EEG.event.latency);
        % --- making an array with the events and latencies
        EEG.etc.events = cat(2,events, latency);
        % --- creates empty arrays to save time time
        cutTime = seconds*EEG.srate;
        lastDin = [];
        trimTime = [];
        boundaries = [];
        epocs = [];
        % gets all occurences of 'epoc'
        epocs = find(strcmp(EEG.etc.events(:,1),'epoc'));
        % if there are any occurences of 'epoc'
        if ~isempty(epocs)
            % if the occurences are higher than 1
            if length(epocs) > 1
                lastDin = str2double(EEG.etc.events(epocs(end)+1,2));
                trimTime = lastDin-(seconds*EEG.srate);
                if lastDin-(seconds*EEG.srate) > 0
                    EEG = eeg_eegrej( EEG, [0 trimTime]);
                    TRIMMED = 1;
                end
            else
                EEG = eeg_eegrej( EEG, [0 EEG.etc.events(epocs(1)+1,2)-(seconds*250)]);
                TRIMMED = 1;
            end
        else
            %countdins
            C = count(EEG.etc.events(:,1),'DIN ');
            C = count(EEG.etc.events(:,1),'DIN1');
        %is number of dins > 61/64
            %is 64th DIN/DIN1 > seconds*EEG.srate;
                %trim at at 64th DIN/DIN1 + cutTime & 1st DIN - cutTime
        end
        %elseif first/last DIN/DIN1 > seconds*EEG.srate
            %trim at last DIN/DIN1 - cutTime and first DIN
        %end
        %delete boundaries.
        
        
                for j=1:length(EEG.etc.events2)
                    if contains(EEG.etc.events2(j,1),'DIN') || contains(EEG.etc.events2(j,1),'DIN1')
                        counting = counting + 1;
                    end
                    if counting == maxNumEvents
                        timeCutoffBeg = str2double(EEG.etc.events2(j,2));
                        EEG = eeg_eegrej( EEG, [0 timeCutoffBeg-1000]);
                    end
                end
                ep = strfind(EEG.filename,'_E');
                EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4),num2str(counting),'.set')], 'filepath',  fileOUTPUT ); %save set
            else
                ep = strfind(EEG.filename,'_E');
                EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4),num2str(length(EEG.etc.events2)),'.set')], 'filepath',  fileOUTPUT ); %save set
            end
            
            EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4),'UNKNOWNERROR.set')], 'filepath',  fileOUTPUTError ); %save set
        end
        
        boundaries = find(strcmp(EEG.etc.events(:,1),'boundary'));
        if ~isempty(boundaries)
            EEG = pop_editeventvals(EEG,'delete',boundaries(j));
        end
    end
    EEG = pop_delset(EEG,1);
end



