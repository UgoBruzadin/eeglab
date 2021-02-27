% author: Ugo Bruzadin nunes on 8/7/2019
% using a script made by author Thokare Nitin D.
% found on the web.

function pip_ClearPipeline()

    clc
    clear all
    extList={'fdt','set','edf','raw','jpg','.sc','sph','wts','xls','asv','mat'};
    ThisFolder = pwd;
    FileList = ReadJustNames(ThisFolder, extList);
    FullFileList = ReadFileNames(ThisFolder, extList);

    if numel(FileList)~=0

        t = [datetime('now')];

        DateString = datestr(t);
        newOld = strcat('\OLD', DateString);
        newOld = strrep(newOld,' ','-');
        newOld = strrep(newOld,':','-');
        try mkdir (ThisFolder, newOld)
        catch
        end
        DumpFolder = strcat(ThisFolder, newOld, '\');

        save('OriginalListOfFiles.mat','FullFileList'); %saves the table in .mat format
        writecell(FullFileList,'OriginalListOfFiles.xls'); %this line makes the .mat table into .xls; can be changed to any format (.csv, .txt, .dat, etc)
        for i=1:numel(FileList)
            TF = contains(FullFileList(i).name,'OLD')
            if TF == 0
                DumpedFile = strcat(DumpFolder, FileList{i});
                if(strcmpi(DumpedFile,FullFileList{i})==0)
                    movefile (FullFileList{i}, DumpedFile);
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ FullFileList ] = ReadFileNames(DataFolder, extList)
    % Author: Thokare Nitin D., modified by Ugo Bruzadin Nunes
    %
    if nargin < 1
        DataFolder = uigetdir;
    end
    DirContents=dir(DataFolder);
    FullFileList=[];
    if ~isunix
        NameSeperator='\';
    else isunix
        NameSeperator='/';
    end
    if nargin < 2
        DataFolder = uigetdir;
    end
    extList={'fdt','set','edf','raw','jpg','.sc','sph','wts'};
    % Here 'peg' is written for .jpeg and 'iff' is written for .tiff
    for i=1:numel(DirContents)
        if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
            if(~DirContents(i).isdir)
                extension=DirContents(i).name(end-2:end);
                if(numel(find(strcmpi(extension,extList)))~=0)
                    FullFileList=cat(1,FullFileList,{[DataFolder,NameSeperator,DirContents(i).name]});
                end
            else
                getlist=ReadFileNames([DataFolder,NameSeperator,DirContents(i).name], extList);
                FullFileList=cat(1,FullFileList,getlist);
            end
        end
    end
end

function [ FullFileList ] = pip_readjustnames(DataFolder, extList)
    % Author: Thokare Nitin D., modified by Ugo Bruzadin Nunes
    %
    if nargin < 1
        DataFolder = uigetdir;
    end
    DirContents=dir(DataFolder);
    FullFileList=[];
    if ~isunix
        NameSeperator='\';
    else isunix
        NameSeperator='/';
    end
    extList={'fdt','set','edf','raw','jpg','.sc','sph','wts','lsx','xls'};
    % Here 'peg' is written for .jpeg and 'iff' is written for .tiff
    for i=1:numel(DirContents)
        if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
            if(~DirContents(i).isdir)
                extension=DirContents(i).name(end-2:end);
                if(numel(find(strcmpi(extension,extList)))~=0)
                    FullFileList=cat(1,FullFileList,{[DirContents(i).name]});
                end
            else
                getlist=ReadJustNames([DataFolder,NameSeperator,DirContents(i).name], extList);
                FullFileList=cat(1,FullFileList,getlist);
            end
        end
    end
end