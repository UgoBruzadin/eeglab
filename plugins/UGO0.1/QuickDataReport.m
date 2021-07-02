function QuickDataReport()

fileList = dir('*.set');
fileInputPath = pwd;

%TemporaryTable = {};
FinalTable = cell(length(fileList),7);% this is an empty matrix for the final Matrix

%parfor i = 1:length(fileList) %runs this loop /for/ as many .dat filels in the current folder
parfor i = 1:length(fileList) %runs this loop /for/ as many .dat filels in the current folder

    [EEG] =  pop_loadset(fileList(i).name, fileInputPath,  'all','all','all','all','auto'); %loads files
    %TemporaryTable = {EEG.filename,EEG.chanlocs(1).ref,EEG.ref(1),EEG.nbchan,EEG.srate,EEG.trials,EEG.xmax};
    if isfield(EEG,'event') && ~isempty(EEG.event)
        events = cat(1,string(char(EEG.event.type)));
    else
        events = '_';
    end
    uniqueEvents = unique(events);
    %NOT SURE IF THIS WORKS
    %uniqueEvents = strjoin(unique(events));
    %finalevents(1:1322) = string();
%     for i=1:length(uniqueEvents)
%         B = A{i,:}
%         if size(B,1) > 1
%             finalevents(i) = strjoin(B)
%         else
%             finalevents(i) = B;
%         end
%     end
    %TemporaryTable = {EEG.filename,EEG.chanlocs(1).ref,EEG.nbchan,EEG.srate,EEG.trials,strcat(uniqueEvents),EEG.xmax};
    FinalTable(i,:) = {EEG.filename,EEG.chanlocs(1).ref,EEG.nbchan,EEG.srate,EEG.trials,strcat(uniqueEvents),EEG.xmax}; % the function cat adds the table from file #(i) to the FinalTable matrix
    EEG = pop_delset(EEG,1);
end %ends loop

save('FilesAndReferences.mat','FinalTable'); %saves the table in .mat format
writecell(FinalTable,'FilesAndReferences.xls');

end