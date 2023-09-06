clc
clear all

%fileList = dir('*.set')

[ fileList ] = GetAllDirFiles(pwd, 'set');

fileInputPath = pwd;

TemporaryTable = {};
FinalTable = cell(length(fileList),7);% this is an empty matrix for the final Matrix

parfor i = 1:length(fileList) %runs this loop /for/ as many .dat filels in the current folder
    EEG =  pop_loadset(fileList(i).name, fileList(i).folder,  'all','all','all','all','auto'); %loads files
    %TemporaryTable = {EEG.filename,EEG.chanlocs(1).ref,EEG.ref(1),EEG.nbchan,EEG.srate,EEG.trials,EEG.xmax};
    %events = cat(1,string(char(EEG.event.type)));
    %uniqueEvents = unique(events);
    TemporaryTable = {EEG.setname,fileList(i).folder,EEG.chanlocs(1).ref,EEG.nbchan,EEG.srate,EEG.trials,EEG.xmax};
    FinalTable(i,:) = TemporaryTable; % the function cat adds the table from file #(i) to the FinalTable matrix
end %ends loop

save('FilesAndReferences.mat','FinalTable'); %saves the table in .mat format
writecell(FinalTable,'FilesAndReferences.xls');