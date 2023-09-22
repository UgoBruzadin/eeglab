function [ FullFolderList ] = GetAllDirFolders(DataFolder,foldersize)
% Author: Thokare Nitin D., modified by Ugo Bruzadin Nunes
%
if nargin < 1
    DataFolder = pwd;
end

if nargin < 2 
    foldersize = [];
end

DirContents=dir(DataFolder);

FullFolderList=[];

if ~isunix
    NameSeparator='\';
else isunix
    NameSeparator='/';
end

% Here 'peg' is written for .jpeg and 'iff' is written for .tiff

for i=1:numel(DirContents)
    if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
        if(DirContents(i).isdir)
            if ~isempty(foldersize)
                if length(DirContents(i).name) ~= foldersize
                    DirContents(i).name
                    getlist=GetAllDirFolders([DataFolder,NameSeparator,DirContents(i).name],foldersize);
                    FullFolderList=cat(1,FullFolderList,getlist);
                else
                    FullFolderList=cat(1,FullFolderList,DirContents(i));
                    getlist=GetAllDirFolders([DataFolder,NameSeparator,DirContents(i).name],foldersize);
                    FullFolderList=cat(1,FullFolderList,getlist);
                end
            else
                FullFolderList=cat(1,FullFolderList,DirContents(i));
                getlist=GetAllDirFolders([DataFolder,NameSeparator,DirContents(i).name],foldersize);
                FullFolderList=cat(1,FullFolderList,getlist);
            end
        end
    end
end

end
