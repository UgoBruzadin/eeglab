
function MoveAllFiles(thisextension,thisfolder)

[ FullFileList ] = GetAllDirFiles(pwd, thisextension);

for i=1:size(FullFileList,1)
    movefile(strcat(FullFileList(i).folder,'\',FullFileList(i).name), [thisfolder,'\', FullFileList(i).name]);
end

%can make it keep in folder structure, need to do that.