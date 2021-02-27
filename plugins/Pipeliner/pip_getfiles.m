% author: Ugo Bruzadin nunes on 8/7/2019
% using a script made by author Thokare Nitin D.
% found on the web.
classdef pip_getfiles
    methods(Static)
        
        function files(foldername,extension)
            if nargin < 1
                %foldername = uigetdir;
                foldername = pwd;
            end
            if nargin < 2
                %foldername = uigetdir;
                foldername = pwd;
                extension={'fdt','set','edf','raw','jpg','.sc','sph','wts','xls','asv','mat'};
            end
            
            FileList = pip_getfiles.readjustnames(foldername, extension);
            FullFileList = pip_getfiles.readfilenames(foldername, extension);
            
            if numel(FileList)~=0
                
                t = [datetime('now')];
                
                DateString = datestr(t);
                newOld1 = strcat('\',upper(table2array(extension)), DateString);
                newOld2 = strrep(newOld1,' ','-');
                newOld2 = strrep(newOld2,':','-');
                try mkdir(strcat(foldername,table2array(newOld2)));
                catch
                end
                DumpFolder = strcat(foldername, newOld2, '\');
                mkdir (DumpFolder);
                %save('OriginalListOfFiles.mat','FullFileList'); %saves the table in .mat format
                writecell(FullFileList,strcat('list_of_',upper(table2array(extension)),'_',newOld2(2:end),'_files.xls')); %this line makes the .mat table into .xls; can be changed to any format (.csv, .txt, .dat, etc)
                for i=1:numel(FileList)
                    TF = contains(table2array(FullFileList(i)),newOld2);
                    if TF == 0
                        DumpedFile = strcat(DumpFolder, table2array(FileList(i)));
                        if(strcmpi(DumpedFile,FullFileList{i})==0)
                            movefile (FullFileList{i}, DumpedFile);
                        end
                    end
                end
            end
        end
        
        function ClearPipeline(foldername,extlist)
            if nargin < 1
                foldername = uigetdir;
            end
            if nargin < 2
                foldername = uigetdir;
                extList={'fdt','set','edf','raw','jpg','.sc','sph','wts','xls','asv','mat'};
            end
            ThisFolder = pwd;
            FileList = pip_getfiles.readjustnames(ThisFolder, extList);
            FullFileList = pip_getfiles.readfilenames(ThisFolder, extList);
            
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
        
        function [FullFileNamesList] = readfilenames(DataFolder, extList)
            % Author: Thokare Nitin D., modified by Ugo Bruzadin Nunes
            %
            if nargin < 1
                DataFolder = pwd;
                DataFolder = uigetdir;
            end
            DirContents=dir(DataFolder);
            FullFileNamesList=[];
            if ~isunix
                NameSeperator='\';
            else isunix
                NameSeperator='/';
            end
            if nargin < 2
                %DataFolder = uigetdir;
                extList={'fdt','set','edf','raw','jpg','.sc','sph','wts'};
            end
            
            % Here 'peg' is written for .jpeg and 'iff' is written for .tiff
            for i=1:numel(DirContents)
                if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
                    if(~DirContents(i).isdir)
                        extension=DirContents(i).name(end-2:end);
                        if(numel(find(strcmpi(extension,extList)))~=0)
                            FullFileNamesList=cat(1,FullFileNamesList,{[DataFolder,NameSeperator,DirContents(i).name]});
                        end
                    else
                        getlist = pip_getfiles.readfilenames([DataFolder,NameSeperator,DirContents(i).name], extList);
                        FullFileNamesList = cat(1,FullFileNamesList,getlist);
                    end
                end
            end
        end
        
        function [FullFileList] = readjustnames(DataFolder, extList)
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
            %extList={'fdt','set','edf','raw','jpg','.sc','sph','wts','lsx','xls'};
            % Here 'peg' is written for .jpeg and 'iff' is written for .tiff
            for i=1:numel(DirContents)
                if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
                    if(~DirContents(i).isdir)
                        extension=DirContents(i).name(end-2:end);
                        if(numel(find(strcmpi(extension,extList)))~=0)
                            FullFileList=cat(1,FullFileList,{[DirContents(i).name]});
                        end
                    else
                        getlist = pip_getfiles.readjustnames([DataFolder,NameSeperator,DirContents(i).name], extList);
                        FullFileList=cat(1,FullFileList,getlist);
                    end
                end
            end
        end
    end
end