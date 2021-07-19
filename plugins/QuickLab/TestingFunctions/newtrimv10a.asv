
clc
clear all
files = dir('*.set');
fdtfiles = dir('*.fdt');

fileINPUT = pwd;
cd ..
fileOUTPUT = pwd;
cd (fileINPUT);

numberOfEventsLeft = 60;
seconds = 4; %%%number of seconds to be left behind first event
t = datestr(datetime('now','TimeZone','local','Format','dMMMy-HH.mm'));

eeglab;
parfor i=1:length(files)
    [EEG] = pop_loadset('filename',{files(i).name});
    try
        %collect EVENTS and LATENCY in an array
    dins = cat(1,string(char(EEG.event.type)));
    latency = cat(1,EEG.event.latency);
    
    EEG.etc.events = cat(2,dins, latency);
    EEG.etc.events2 = flip(EEG.etc.events);
    counting = 0;
    %strcmp(EEG.etc.events(:,1),'DIN ')
    if length(EEG.etc.events2) >= 60
        for j=1:length(EEG.etc.events2)
            if contains(EEG.etc.events2(j,1),'DIN')
                counting = counting + 1;
            end
            if counting == 60
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
    catch
        ep = strfind(EEG.filename,'_E');
        EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4),'RRORtrim.set')], 'filepath',  fileOUTPUT ); %save set
    end
    EEG = pop_delset(EEG,1);
end



