function [ FullFileList ] = GetAllDirFiles(DataFolder, extList)
    % Author: Thokare Nitin D., modified by Ugo Bruzadin Nunes
    %
    if nargin < 1
        DataFolder = uigetdir;
    end

    if nargin < 1 || isempty(extList) 
        extList = {'fdt','set','edf','raw','jpg','.sc','sph','wts','lsx','xls'};
    end

    DirContents=dir(DataFolder);
    FullFileList=[];
    if ~isunix
        NameSeperator='\';
    else isunix
        NameSeperator='/';
    end
    
    % Here 'peg' is written for .jpeg and 'iff' is written for .tiff
    for i=1:numel(DirContents)
        if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
            if(~DirContents(i).isdir)
                extension=DirContents(i).name(end-2:end);
                if(numel(find(strcmpi(extension,extList)))~=0)
                    FullFileList=cat(1,FullFileList,DirContents(i));
                end
            else
                getlist=GetAllDirFiles([DataFolder,NameSeperator,DirContents(i).name], extList);
                FullFileList=cat(1,FullFileList,getlist);
            end
        end
    end
end