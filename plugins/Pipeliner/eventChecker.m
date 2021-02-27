clc
clear all
files = dir('*.set');

fileINPUT = pwd;
% cd ..
% fileOUTPUT = pwd;
% cd (fileINPUT);

TemporaryTable = {};
FinalTable = {};% this is an empty matrix for the final Matrix

for i = 1:length(files) %runs this loop /for/ as many .dat filels in the current folder
    EEG =  pop_loadset(files(i).name, fileINPUT,  'all','all','all','all','auto'); %loads files
    allEvents = [];
    uniqueEvents = [];
    eventNumbers = "";
    eventNames = "";
    try
        allEvents = cat(1,string(char(EEG.event.type)));
        uniqueEvents = unique(allEvents);
        for i=1:length(uniqueEvents)
            eventNames = strcat(eventNames,(uniqueEvents(i)));
            eventNumbers = strcat(eventNumbers,string(sum(count(allEvents,uniqueEvents(i)))),'_');
        end
    catch
        eventNames = 'FAIL';
        eventNumbers = 'FAIL';
    end
    TemporaryTable = {EEG.filename,EEG.chanlocs(1).ref,EEG.ref(1), EEG.nbchan,EEG.srate,EEG.trials,EEG.xmax,eventNames,eventNumbers};
    FinalTable = cat(1,FinalTable,TemporaryTable); % the function cat adds the table from file #(i) to the FinalTable matrix
end %ends loop

%save('FilesAndReferences.mat','FinalTable'); %saves the table in .mat format
writecell(FinalTable,'FilesAndReferences.xls');