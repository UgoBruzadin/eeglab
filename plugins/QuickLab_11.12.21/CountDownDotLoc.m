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

final_files = dir('*bssICA.set');


%totalstarted = 0;
% 
% for i = 1:totalFilesInFolder
%     
%     LocationOfFileStrings = strfind(AllFilesFoldersName,allStartedFiles(i).name(1:end-4));
%     %LocationOfFileStrings = contains(AllFilesFoldersName,strcat(allStartedFiles(i).name(1:end-4),'*','bssICA*.set'));
%     NumberOfCountedFiles = length(LocationOfFileStrings);
%     
%     if NumberOfCountedFiles > 1
%         totalstarted = totalstarted + 1;
%     end
% 
% end

totalstarted = size(final_files,1);
totalleft = totalFilesInFolder-totalstarted; 

% total
% totalstarted
% totalstarted/total*100

pie(axis,[totalleft,totalstarted],{num2str(totalleft),num2str(totalstarted)})

% pie([total-totalstarted,totalstarted])