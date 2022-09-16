%--- script made by Ugo Nunes
% on 08/05/2021
% generates FFTs but also save FFTs to the file

fileINPUT = pwd;
%cd ..
fileOUTPUT = pwd;
%cd(fileINPUT);

files = dir('*.set');

oldSuffix = 'In';
newSuffix = 'I';

%eeglab;
for i=1:length(files) 
    %EEG = pop_loadset( files(i).name, fileINPUT);
    foldersname = files(i).folder;
    filename = files(i).name;
    
    oldSufPos = [];
    oldSufPos = strfind(filename,oldSuffix);
    
    if ~isempty(oldSufPos)
    oldSize = size(oldSuffix,2);
    
    newSufPos = strfind(filename,newSuffix);
    newSize = size(newSuffix,2);

    newfilename = [strcat(filename(1:oldSufPos-1),newSuffix,filename(oldSufPos+oldSize:end))];
   
    filename = strcat(foldersname, files(i).name);
    movefile(files(i).name, newfilename);
    %system("rename" +  filename + newfilename ); % didn't work
    %EEG = pop_saveset(EEG, 'filename', [strcat(fullname(1:6),'dl',dotlocnum,'HA255N',nfilter,'T',fullname(BE+2:end))], 'filepath',  fileOUTPUT ); %save set
    end
end