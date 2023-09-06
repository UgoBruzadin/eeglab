

function RenameAllFiles(thisextension,thisaddition,thisfolder)

[ FullFileList ] = GetAllDirFiles(pwd, thisextension);

for i=1:size(FullFileList,1)
    if nargin < 1 || isempty(thisfolder)
        thisfolder = FullFileList(i).folder;
    end
    movefile(strcat(FullFileList(i).folder,'\',FullFileList(i).name), [thisfolder,'\', FullFileList(i).name,thisaddition]);
end

%can make it keep in folder structure, need to do that.