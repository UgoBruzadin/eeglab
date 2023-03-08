function [notstarted, notfinished] = DotLoc_Left_over_files()


Ep63 = dir('*T63.set');
Ep60 = dir('*T60.set');
allStartedFiles = cat(1,Ep63,Ep60);



totalFilesInFolder = length(allStartedFiles);

AllFilesFolder = dir('*.set');
AllFilesFoldersName = [AllFilesFolder.name];

% finalized files
%final_files = dir('*bssICA.set');

final_files = dir('*HM9*Ep6*ICA.set');

final_files2 = dir('*DONE*.set');

final_files3 = dir('*FIN*.set');
totalcompleted = cat(1,final_files,final_files3);
totalcompleted = cat(1,totalcompleted,final_files2);

totalstarted = 0;

notstarted = allStartedFiles;

%notstarted.name = sort(notstarted.name);

for i = 1:totalFilesInFolder
    
    LocationOfFileStrings = strfind(AllFilesFoldersName,allStartedFiles(i).name(1:end-4));
    %LocationOfFileStrings = contains(AllFilesFoldersName,strcat(allStartedFiles(i).name(1:end-4),'*','bssICA*.set'));
    NumberOfCountedFiles = length(LocationOfFileStrings);
    
    if NumberOfCountedFiles > 1
        notstarted(i-totalstarted) = [];
        totalstarted = totalstarted + 1;
    end
end

notfinished = allStartedFiles;
%notfinished = sort(notfinished);

allcompletedfiles = [totalcompleted.name];
totalfinished = 0;


for i = 1:length(allStartedFiles)
    
    LocationOfFileStrings = strfind(allcompletedfiles,allStartedFiles(i).name(1:end-4));
    %LocationOfFileStrings = contains(AllFilesFoldersName,strcat(allStartedFiles(i).name(1:end-4),'*','bssICA*.set'));
    NumberOfCountedFiles = length(LocationOfFileStrings);
    
    if NumberOfCountedFiles > 0
        notfinished(i-totalfinished) = [];
        totalfinished = totalfinished + 1;
    end
end




totalstarted = totalstarted - totalfinished;
%totalfinished = size(totalcompleted,1);
totalleft = totalFilesInFolder-totalstarted-totalfinished; 