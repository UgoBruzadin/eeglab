function [ FullFileList ] = GetAllDirFiles(DataFolder, extList)
% Author: Thokare Nitin D., modified by Ugo Bruzadin Nunes
%
if nargin < 1
    DataFolder = pwd;
end

if nargin < 1
    extList = [];
end

ext_size = size(extList,2);

DirContents=dir(DataFolder);

FullFileList=[];
if ~isunix
    NameSeperator='\';
else isunix
    NameSeperator='/';
end

% Here 'peg' is written for .jpeg and 'iff' is written for .tiff

if isempty(extList)
    for i=1:numel(DirContents)
        if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
            if(DirContents(i).isdir)
                extension=DirContents(i).name;
                if(numel(find(strcmpi(extension,extList)))~=0)
                    FullFileList=cat(1,FullFileList,DirContents(i));
                end
            else
                getlist=GetAllDirFiles([DataFolder,NameSeperator,DirContents(i).name], extList);
                FullFileList=cat(1,FullFileList,getlist);
            end
        end
    end
else
    for i=1:numel(DirContents)
        if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
            if(~DirContents(i).isdir)
                if size(DirContents(i).name,2) > ext_size
                    extension = DirContents(i).name(end-ext_size+1:end);
                    if(numel(find(strcmpi(extension,extList)))~=0)
                        FullFileList=cat(1,FullFileList,DirContents(i));
                    end
                end
            else
                getlist=GetAllDirFiles([DataFolder,NameSeperator,DirContents(i).name], extList);
                FullFileList=cat(1,FullFileList,getlist);
            end
        end
    end
end
