% Author: Ugo Bruzadin Nunes
% SIUC
% email: ugobruzadin at gmail dot com
% Dec 2019/Jan2020

classdef autopipeliner
    methods(Static)
          
        function forks(commands,batches,batchFolder)
            OGfolder = batchFolder; %saves the first batch folder
            folderCounter = 0; %starts the number of processes ran on the files
            for i=1:length(commands)
                cd(OGfolder); %go to OG folder
                files = dir('*.set'); %get director of OG file folder
                batchName = char(strcat('Batch_',num2str(i))); %names batch to "Batch"+number of the batch
                [batchFolder] = autopipeliner.createBatchFolder(OGfolder,files,batchName); %created batch folder
                fprintf('generating batch folders'); %prints this sentence
                fileFolder = batchFolder;
                for j=length(commands)
                    folderCounter = folderCounter + 1;%adds one folder to the counter
                    %starts the pipeline
                    [fileFolder] = autopipeliner.Function(commands(i),batchFolder,fileFolder,folderCounter);
                end
            end
            autopipeliner.batches(batches,fileFolder,folderCounter);
        end
        
        function batches(batches,batchFolder,folderCounter) %store all batches to be done
            if nargin < 3
                folderCounter = 0;
            end
            fileFolder = batchFolder;
            OGfolder = batchFolder;
            for i=1:length(batches)
                cd(OGfolder);
                files = dir('*.set');
                %folderCounter = folderCounter + 1;
                batchName = char(strcat('Batch_',num2str(folderCounter))); %names batch to "Batch"+number of the batch
                [batchFolder] = autopipeliner.createBatchFolder(OGfolder,files,batchName); %created batch folder
                fprintf('generating batch folders'); %prints this sentence
                nextbatch = table2array(batches(i));
                [batchFolder, folderCounter] = autopipeliner.pipeIn(nextbatch,batchFolder,folderCounter); %start the pipeline
            end
        end
                
        function [fileFolder, folderCounter] = pipeIn(commands,batchFolder,folderCounter) %store the functions to be rolled in this batch
            if nargin < 3
                folderCounter = 0;
            end
            
            %commands = table2array(commands); %gets the array of commands to be pipelined
            %folderCounter = 0; %start a counter of folders/commands to be run
            fileFolder = batchFolder; %begins with the files inside the main batch folder
            for i=1:length(commands) %for loop, loops the number of commands
                folderCounter = folderCounter + 1;%adds one folder to the counter
                %starts the pipeline
                [fileFolder] = autopipeliner.Function(batchFolder,commands(i),fileFolder,folderCounter);
            end
        end
        
        function [filePOST] = Function(batchPath,commands,filePath,counter) %magic function, runs the code asked!
            %type = string, the function to be called
            %content = [], arrayof  the extra information to that function
            commands = table2array(commands);
            autopipeliner.clean(); %wipe the memory
            t = datetime('now','TimeZone','local','Format','dMMMy-HH.mm'); %gets the datetime
            fname = strcat(mfilename,'.'); %get the name of this function for future use, adds a dot to it
            
            cd(filePath); %moves the the last path where files were
            %tic; %start a timer
            folderLetter = char(counter+64); %names the folder!
            folderNameDate = strcat(folderLetter,'-',char(commands(1)),'-',char(t));
            
            [files, filePRE, filePOST] = autopipeliner.createfolders(filePath,batchPath,folderNameDate); %creates a folder for the pipeline
            cd(filePRE);
            
            for i=1:length(files)
                %load EEG
                EEG = pop_loadset(files(i).name, filePRE,  'all','all','all','all','auto');
                EEG = eeg_checkset(EEG);
                %call the function = can be susbtituted for a script in the future
                action = str2func(strcat(fname,char(commands(1)))); %this call a function inside this function with the name asked for!
                if length(commands) > 1
                    [EEG, acronym] = action(commands(2:end), EEG); %this is where the function runs the asked code!
                else
                    [EEG, acronym] = action(EEG); %this is where the function runs the asked code!
                end

                [individualReport] = pipe_individualreport(files(i).name,EEG);
                %[individualReport] = autopipeliner.tempReport(files(i).name,EEG);%changedneedsfixing
                %saving files & report
                EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4), [acronym], '.set')], 'filepath',filePOST);
                writetable(cell2table(individualReport),strcat(files(i).name(1:end-4),'_report.xlsx')); %saves the table in .mat format
                autopipeliner.fft(files(i),EEG);
                autopipeliner.componentFigures(files(i),EEG) %fixed and added 2/3/2020
                EEG = pop_delset(EEG,1); %fixed and added 2/3/2020
            end
            %makes report
            autopipeliner.report(folderNameDate); %fixed and added 2/3/2020
            %------
            %cleaning the folder from binica trash
            autopipeliner.emptyTrash(); %deletes binica's leftover trash
            %sends text to me
            autopipeliner.txt(strcat('processing of ', folderNameDate,' is over')); %fixed and added 2/3/2020
        end
        
        %functions without EEG
        
        %         function makeHeader(EEG) %undercontruction
        %             ExcelSheetHeader = {'name','process','type', 'numchans','ref','srate','trials','events','xmax','components'};
        %             components = 0;
        %             if ~isempty(EEG.icaweights) & ~isempty(EEG.etc.ic_classification.ICLabel.classifications)
        %                 for j=1:128
        %                         components = components + 1;
        %                     ExcelSheetHeader{end+1} = [strcat('component ',string(components))];
        %                     ExcelSheetHeader{end+1} = '%';
        %                 end
        %             end
        %         end
        
        function report(folderNameDate)
            pipe_finalreport(folderNameDate);
        end
        
        function emptyTrash()
            trash = dir('bin*');
            for i=1:length(trash)
                delete (trash(i).name)
            end
        end %%%works
        
        function [acronym] = makeAcronym(type,content)
            acronym = string(type(1:2));
            for i=1:length(content)
                acronym = strcat(acronym,string(content(i)));%getAcronym(action)
            end
            acronym = char(acronym);
        end %not being utilized
        
        function clean() %works
            clc;         % clear command window
            clear all;
            evalin('base','clear all');  % clear base workspace as well
            close all;   % close all figures
        end
        
        function [files, filePRE, filePOST] = createfolders(filePath,batchPath,folderName) %work!!!
            %------ create the folders where the pipeline will run
            %------ filePRE = strcat(basefolder,'\', type, '\pre'); %copies files
            %------ one can I turn it off)
            cd(batchPath) % - goes to batches's folder
            mkdir (folderName); % creates new folder
            mkdir (folderName,  'pre'); %created nwe pre folder inside
            cd(filePath); %goes to last file location
            fdtfiles = dir('*.fdt'); %gets fdt files
            files = dir('*.set'); %gets set files
            %------
            filePRE = strcat(batchPath,'\', folderName, '\pre');
            filePOST = strcat(batchPath,'\',folderName);
            %------
            parfor i=1:length(files)
                copyfile(files(i).name, filePRE)
                copyfile(fdtfiles(i).name, filePRE);
            end
        end
        
        function [batchFolder] = createBatchFolder(path,files,folderName) %works!!!
            %------ create the folders where the pipeline will run
            %------ filePRE = strcat(basefolder,'\', type, '\pre'); %copies files
            %------ one can I turn it off)
            
            basefolder = path;
            mkdir (folderName)
            fdtfiles = dir('*.fdt');
            batchFolder = strcat(basefolder,'\', folderName);
            %if savecopy
            parfor i=1:length(files)
                copyfile(files(i).name, batchFolder)
                copyfile(fdtfiles(i).name, batchFolder);
            end
            %end
        end
        
        function txt(content) %works
            number = '6183034686@vtext.com';
            email = 'ugobnunes@hotmail.com';
            %who = {number, email};
            who = {number};
            mail = 'ugoslab@gmail.com'; %Your GMail email address
            setpref('Internet','SMTP_Server','smtp.gmail.com');
            setpref('Internet','E_mail',mail); %sending email = mail
            setpref('Internet','SMTP_Username',mail); %username = mail
            setpref('Internet','SMTP_Password','1cabininthewoods2'); %password
            props = java.lang.System.getProperties;
            props.setProperty('mail.smtp.auth','true');
            props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
            props.setProperty('mail.smtp.socketFactory.port','465');
            
            % Send the email.  Note that the first input is the address you are sending the email to
            sendmail(who,'Automatic Matlab Report',content);
            %fprintf('text successfully sent to %s and %s\n', email, number);
            fprintf('text successfully sent to %s \n', number);
        end
        
        %Functions that do EEG
        
        function [EEG, acronym] = ica(components, EEG) %works
            [EEG, acronym] = pipe_ica(components, EEG); %works
        end
        
        function [EEG, acronym] = iclabel(cuts,EEG) %iclabel({'all',.9},EEG)
            [EEG, acronym] = pipe_iclabel(cuts,EEG);
        end
        
        %stopped trying to make the loops explain the vriance...!
        
        function [EEG, acronym] = icloop(cut, EEG)
            [EEG, acronym] = pipe_icloop(cut, EEG);
        end
        
        function [EEG, PercentBrainAccountedFor_Total] = getVarianceExplained(content,EEG)
            %getVarianceEmplained(components,EEG)
            temporaryList = {};
            finalList = [];
            EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
            
            chanorcomp = size(EEG.icaweights,1);
            for j=1:chanorcomp
                icaacttmp = EEG.icaact(j, :, :);
                maxsamp = 1e6;
                n_samp = min(maxsamp, EEG.pnts*EEG.trials);
                try
                    samp_ind = randperm(EEG.pnts*EEG.trials, n_samp);
                catch
                    samp_ind = randperm(EEG.pnts*EEG.trials);
                    samp_ind = samp_ind(1:n_samp);
                end
                if ~isempty(EEG.icachansind)
                    icachansind = EEG.icachansind;
                else
                    icachansind = 1:EEG.nbchan;
                end
                datavar = mean(var(EEG.data(icachansind, samp_ind), [], 2));
                projvar = mean(var(EEG.data(icachansind, samp_ind) - ...
                    EEG.icawinv(:, j) * icaacttmp(1, samp_ind), [], 2));
                pvafval = 100 *(1 - projvar/ datavar);
                pvaf = num2str(pvafval, '%3.1f');
                temporaryList = {pvaf};
                finalList = cat(1, finalList, temporaryList);
            end
            
            PercentBrainAccountedFor_Total = 0;
            for a =1:content % This will only count the first X components
                PercentBrainAccountedFor_Comp = EEG.etc.ic_classification.ICLabel.classifications(a,1)*str2double((finalList{a,1}));
                PercentBrainAccountedFor_Total = PercentBrainAccountedFor_Total + PercentBrainAccountedFor_Comp;
            end
        end
        
        %making the report table!!!
        
        function [tempTable] = tempReport(filename,EEG)
            [tempTable] = pipe_individualreport(filename,EEG);
        end
        
        function [tablefilled] = fillTable(table)
            %if tables are uneven, fill the table until all rows are even
        end
        
        %         function [finalTable] = report(files, EEG) %untested
        %             %finalTable = {'name','ref','numchans','srate','trials','event','xmax'};
        %             nameOfEvents = {};
        %
        %             tempCompTable = {[files.name],EEG.chanlocs(1).ref,EEG.nbchan,EEG.srate,EEG.trials,length(EEG.event),EEG.xmax};
        %
        %             sheet = 1;
        %             writetable(Tab1,filename,'sheet',sheet,'Range','A1')
        %             sheet = 2;
        %             writetable(Tab2,filename,'sheet',sheet,'Range','A1')
        %
        %         end
        
        %         function report(EEG) %untested
        %             TemporaryTable = {EEG.filename,EEG.chanlocs(1).ref,EEG.ref(1),EEG.nbchan,EEG.srate,EEG.trials,EEG.xmax};
        %             FinalTable = cat(1,FinalTable,TemporaryTable); % the function cat adds the table from file #(i) to the FinalTable matrix
        %         end
        
        function [EEG, acronym] = filter(commands,EEG) %should work
            [EEG, acronym] = pipe_filter(commands,EEG);
        end
        
        function [EEG, acronym] = notchfilter(EEG)
            [EEG, acronym] = pipe_notchfilter(EEG);
        end
        
        function [EEG, acronym] = rereference(command,EEG) %untested
            switch command
                case 'LE' | 'le' | 'Le'
                    EEG = pop_reref( EEG, [],'refloc',struct('labels',{'LE'},'type',{''},'theta',{[]},'radius',{[]},'X',{[]},'Y',{[]},'Z',{[]},'sph_theta',{[]},'sph_phi',{[]},'sph_radius',{[]},'urchan',{[]},'ref',{''},'datachan',{0},'sph_theta_besa',{[]},'sph_phi_besa',{[]}));
                case 'CZ' | 'cz' | 'Cz'
                    EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}));
                case 'AVG' | 'av' | 'Avg' | 'AV'
                    EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'type',{''},'theta',{[]},'radius',{[]},'X',{[]},'Y',{[]},'Z',{[]},'sph_theta',{[]},'sph_phi',{[]},'sph_radius',{[]},'urchan',{[]},'ref',{''},'datachan',{0},'sph_theta_besa',{[]},'sph_phi_besa',{[]}));
            end
            acronym = 'RF';
        end
        
        function [EEG, acronym] = headmodel(EEG) %untested
            %ADD: autodetect which headmodels data needs
            %ADD: select headmodel file
            EEG = pop_chanedit(EEG, 'load',{'G:\\Matlab_Batch_v6.0a-129Chan-N5_DL\\C-00-InsertHeadModel\\Pre\\HCGSN128Renamed.sfp' 'filetype' 'autodetect'});
            EEG = eeg_checkset( EEG );
            EEG = pop_chanedit(EEG, 'append',131,'changefield',{132 'labels' 'Cz'},'changefield',{132 'theta' '0'},'changefield',{132 'radius' '0'},'changefield',{132 'X' '0'},'changefield',{132 'Y' '0'},'changefield',{132 'sph_theta' '0'},'changefield',{132 'sph_phi' '0'},'changefield',{132 'sph_radius' '0'},'changefield',{132 'Z' '8.7919'});
            EEG = eeg_checkset( EEG );
            EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{''},'urchan',{[]},'datachan',{0}));
            acronym = 'HM';
        end
        
        function [EEG, acronym] = trim(content, EEG) %not started yet
            % trims the data at upper seconds lower seconds
        end
        
        function [EEG, acronym] = cleanline(commands,EEG) %can do 50hz, 60hz, 70, and so on! %should work
            for i=1:length(commands)
                EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan(1,1)] ,'computepower',1,'linefreqs',commands(i),'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',4,'winstep',1);
            end
            acronym = 'CL';
        end
        
        function [EEG, acronym] = interpolate(EEG) %should works
            %if ref is not cz, rereference
            if EEG.chanlocs(1).ref ~= 'Cz'
                EEG = pop_reref( EEG, Cz); %will need to be modified to other headmodels
            end
            EEG = eeg_checkset(EEG);
            originalEEG = EEG; % copy EEG before clean_raw
            EEG = clean_artifacts(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
            EEG.Channels_Removed = setdiff({originalEEG.chanlocs.labels},{EEG.chanlocs.labels}, 'stable');  % Make a
            EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
            %EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}));
            acronym = 'IN';%gotta add the interpolated channels
        end
        
        function [EEG, acronym] = epoch(content, EEG) %content must be 1.array of names of epochs, 2. first cut and 3. second cut, both in seconds
            [EEG, acronym] = pipe_epoch(content, EEG);
        end
        
        function [EEG, acronym] = epochRejection(content, EEG) %content must be 1.array of names of epochs, 2. first cut and 3. second cut, both in seconds
            [EEG, acronym] = pipe_epochrej(content, EEG);
        end
        
        function [EEG, acronym] = baseline(commands, EEG) %baseline asks for two numbers %untested
            EEG = pop_rmbase( EEG, [commands(1) commands(2)]);
            acronym = 'BL'; %make for variable baseline later
        end
        
        %figuregenerators!
        function fft(files,EEG) %works; by ugo 2/3/2020 7:15pm
            pipe_fft(files,EEG);
        end
        
        function componentFigures(files,EEG) %maybe fixed by ugo 2/3/2020 7:15pm
            pipe_icfigures(files,EEG);
        end
    end
end