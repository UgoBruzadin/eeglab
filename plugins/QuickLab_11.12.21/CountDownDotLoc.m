function CountDownDotLoc(axis)

if nargin < 1
    axisPanel = findobj('Tag','PieChart');
    axis = findobj('Tag','pie_chart');
end

%axis = axes(axis, 'Tag','pie_chart','Position', [0 0 1 1]);

Ep63 = dir('*EP63.set');
Ep60 = dir('*EP60.set');
allStartedFiles = cat(1,Ep63,Ep60);
totalFilesInFolder = length(allStartedFiles);

AllFilesFolder = dir('*.set');
AllFilesFoldersName = [AllFilesFolder.name];

% finalized files
%final_files = dir('*bssICA.set');
final_files = dir('*HM9*Ep6*ICA.set');
% preprocessed files & filnalized files
%final_files = dir('*ICA.set');

totalstarted = 0;

for i = 1:totalFilesInFolder
    
    LocationOfFileStrings = strfind(AllFilesFoldersName,allStartedFiles(i).name(1:end-4));
    %LocationOfFileStrings = contains(AllFilesFoldersName,strcat(allStartedFiles(i).name(1:end-4),'*','bssICA*.set'));
    NumberOfCountedFiles = length(LocationOfFileStrings);
    
    if NumberOfCountedFiles > 1
        totalstarted = totalstarted + 1;
    end

end

totalstarted = totalstarted - size(final_files,1);
totalfinished = size(final_files,1);
totalleft = totalFilesInFolder-totalstarted-totalfinished; 

% total
% totalstarted
% totalstarted/total*100

pie(axis,[totalleft,totalstarted,totalfinished],{num2str(totalleft),num2str(totalstarted),num2str(totalfinished)})
%pie(axis,[totalleft,totalstarted],{num2str(totalleft),num2str(totalstarted)})

% pie([total-totalstarted,totalstarted])