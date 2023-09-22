function CountDownDotLoc(axis)

if nargin < 1
    axisPanel = findobj('Tag','PieChart');
    axis = findobj('Tag','pie_chart');
end

% if ~isempty(axis)
%     delete(axis);
% end
% 
% axis = axes(axis, 'Tag','pie_chart','Position', [0 0 1 1]);

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

final_files4 = dir('*Fin.set');

%final_files4 = dir('*Hm9*Ep6*ICA.set');

totalcompleted = cat(1,final_files,final_files3);
totalcompleted = cat(1,totalcompleted,final_files2);
totalcompleted = cat(1,totalcompleted,final_files4);

totalstarted = 0;

leftoverfiles_started = allStartedFiles;

for i = 1:totalFilesInFolder
    
    LocationOfFileStrings = strfind(AllFilesFoldersName,allStartedFiles(i).name(1:end-4));
    %LocationOfFileStrings = contains(AllFilesFoldersName,strcat(allStartedFiles(i).name(1:end-4),'*','bssICA*.set'));
    NumberOfCountedFiles = length(LocationOfFileStrings);
    
    if NumberOfCountedFiles > 1
        leftoverfiles_started(i-totalstarted) = [];
        totalstarted = totalstarted + 1;
    end
end

leftoverfiles_completed = allStartedFiles;
allcompletedfiles = [totalcompleted.name];
totalfinished = 0;


for i = 1:length(allStartedFiles)
    
    LocationOfFileStrings = strfind(allcompletedfiles,allStartedFiles(i).name(1:end-4));
    %LocationOfFileStrings = contains(AllFilesFoldersName,strcat(allStartedFiles(i).name(1:end-4),'*','bssICA*.set'));
    NumberOfCountedFiles = length(LocationOfFileStrings);
    
    if NumberOfCountedFiles > 0
        leftoverfiles_completed(i-totalfinished) = [];
        totalfinished = totalfinished + 1;
    end
end

totalstarted = totalstarted - totalfinished;
%totalfinished = size(totalcompleted,1);
totalleft = totalFilesInFolder-totalstarted-totalfinished; 

% total
% totalstarted
% totalstarted/total*100

OLDPIEtext = findobj(gcf,'type','text');
OLDPIEpatch = findobj(gcf,'type','patch');
if ~isempty(OLDPIEtext)
    delete(OLDPIEtext);
    delete(OLDPIEpatch);
end

PIE = pie(axis,[totalleft,totalstarted,totalfinished],{num2str(totalleft),num2str(totalstarted),num2str(totalfinished)});
%pie(axis,[totalleft,totalstarted],{num2str(totalleft),num2str(totalstarted)})

% pie([total-totalstarted,totalstarted])