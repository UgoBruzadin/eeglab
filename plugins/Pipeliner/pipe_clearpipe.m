% author: Thokare Nitin D., modified by Ugo Bruzadin nunes on 8/7/2019
% using a script made by author Thokare Nitin D.
% found on the web.

function pipe_clearpipe(foldername,extlist)
            if nargin < 1
                %foldername = uigetdir;
                foldername = pwd;
            end
            if nargin < 2
                foldername = uigetdir;
                extList={'fdt','set','edf','raw','jpg','.sc','sph','wts','xls','asv','mat'};
            end
            %foldername = pwd;
            FileList = pipe_getfiles.getjustnames(foldername, extList);
            FullFileList = pipe_getfiles.getfullnames(foldername, extList);
            
            if numel(FileList)~=0
                
                t = [datetime('now')];
                
                DateString = datestr(t);
                newOld = strcat('\OLD', DateString);
                newOld = strrep(newOld,' ','-');
                newOld = strrep(newOld,':','-');
                try mkdir (foldername, newOld)
                catch
                end
                DumpFolder = strcat(foldername, newOld, '\');
                
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