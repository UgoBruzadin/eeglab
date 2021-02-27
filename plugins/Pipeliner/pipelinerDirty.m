% Author: Ugo Bruzadin Nunes
% SIUC
% email: pipelinerbruzadin@gmail.com
% Dec 2019

classdef pipeliner
    methods(Static)
        
        function batches(commands,path) %store all batches to be done
            for i=1:length(commands)
                files = dir('*.set')
                [batchFolder] = pipeliner.createfolders(path,files,char(string();
                pipeline.pipeIn(batchFolder,commands(i));
            end
        end
        
        function pipeIn(commands) %store the functions to be rolled in this batch
            for i=1:length(commands)
                pipeliner.Function(commands(i,1), commands(i,2),path)
            end
        end
        
        function Function(type,content,path) %magic function, runs the code asked!
            %type = string, the function to be called
            %content = [], arrayof  the extra information to that function
            pipeliner.clean(); %wipe the memory
            fname = strcat(mfilename,'.'); %get the name of this function for future use
            eeglab; %call eeglab, so this function is in directory
            %[files,path] = uigetfile({'*.set'},'Multiple File Selection','MultiSelect','on'); %%get UI information
            if isempty(path) %if ui is deactivated, gets the path from pwd
                path = pwd;
            end
            cd(path);
            %[Codes,path2] = uigetfile({'*.m'},'Multiple Scripts Selection','MultiSelect','on');
            %cd(path);
            %file = files;
            if ~isempty (files) %if ui is deactivated, gets files from pwd
                files = dir('*.set');
            end
            t = datetime('now','TimeZone','local','Format','dMMMy-HH-mm');
            nameDate = strcat(char(type),char(t))
            fileCounter = 1; %counts how many file shave been run; useful for later
            [filePRE, filePOST] = pipeliner.createfolders(path,files,nameDate); %creates a folder for the pipeline
            cd(filePRE);
            %finalReport = [];
            for i=1:length(files)
                [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                EEG =  pop_loadset(files(i).name, filePRE,  'all','all','all','all','auto');
                [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
                EEG = eeg_checkset(EEG);
                action = str2func(strcat(fname,type)); %this call a function inside this function with the name asked for!
                [acronym] = action(content, EEG); %this is where the function runs the asked code!
                EEG = eeg_checkset(EEG);
                %[acronym] = pipeliner.makeAcronym(type,content); %was
                %making static acronyms, now it's variable
                Acronym = type(1:2); %in case the acronym is not working, this makes an easy fix
                try EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4), '_', [acronym], '.set')], 'filepath',filePOST);
                catch EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4), '_', Acronym, '.set')], 'filepath',filePOST);
                end
                [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                
                [finalReport] = pipeliner.tempReport(fileCounter, files(i).name,type,content,EEG);
                %finalReport = cat(1,finalReport,temporaryTable);
                %Report_Name = acronym;
                xlswrite(Report_Name,finalReport);
                pipeliner.emptyTrash(); %deletes binica's leftover trash
                
                fileCounter = fileCounter + 1;
            end
            pipeliner.txt(strcat('processing of ', char(Report_Name), ' is over'))
        end
        
        %functions without EEG
        function emptyTrash()
            trash = dir('bin*');
            for i=1:length(trash)
                delete (trash(i).name)
            end
        end
        
        function [acronym] = makeAcronym(type,content)
            acronym = string(type(1:2));
            for i=1:length(content)
                acronym = strcat(acronym,string(content(i)));%getAcronym(action)
            end
            acronym = char(acronym);
        end
        
        function clean() %works
            clc;         % clear command window
            clear all;
            evalin('base','clear all');  % clear base workspace as well
            close all;   % close all figures
        end
        
        function [filePRE, filePOST] = createfolders(path,files,folderName) %untested
            % create the folders where the pipeline will run
            % filePRE = strcat(basefolder,'\', type, '\pre'); %copies files
            % one can I turn it off)
            
            basefolder = path;
            filePRE = basefolder; %made this line later!
            mkdir (folderName)
            mkdir (folderName,  'pre');
            fdtfiles = dir('*.fdt');
            filePRE = strcat(basefolder,'\', folderName, '\pre');
            filePOST = strcat(basefolder,'\',folderName);
            %if savecopy
            for i=1:length(files)
                copyfile(files(i).name, filePRE)
                copyfile(fdtfiles(i).name, filePRE);
            end
            %end
        end

        function [batchFolder] = createBatchFolders(path,files,folderName) %untested
            % create the folders where the pipeline will run
            % filePRE = strcat(basefolder,'\', type, '\pre'); %copies files
            % one can I turn it off)
            
            basefolder = path;
            mkdir (folderName)
            fdtfiles = dir('*.fdt');
            batchFolder = strcat(basefolder,'\', folderName);
            %if savecopy
            for i=1:length(files)
                copyfile(files(i).name, batchFolder)
                copyfile(fdtfiles(i).name, batchFolder);
            end
            %end
        end
        
        function txt(content) %works
            number = '6183034686@vtext.com';
            email = 'ugobnunes@hotmail.com';
            who = {number, email};
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
            fprintf('text successfully sent to %s and %s\n', email, number);
        end
        
        %Functions that do EEG
        
        function [acronym] = ica(content, EEG) %works
            EEG = pop_runica(EEG,'extended', 1, 'pca', content);
            acronym = char(strcat('IC',string(content)));
        end
        
        function [acronym] = iclabel(content,EEG) %iclabel({'all',.9},EEG)
            EEG = eeg_checkset(EEG);
            EEG = pop_iclabel(EEG,'default');
            EEG = eeg_checkset(EEG);
            flags = [... %this is a variable that contains all the flags for ica label
                NaN NaN;...%brain
                NaN NaN;...%muscle
                NaN NaN;...%eye
                NaN NaN;...%heart
                NaN NaN;...%line noise
                NaN NaN;...%channel noise
                NaN NaN;...%other
                ];
            if length(content) == 1
                for i=1:length(flags)
                    flags = [... %this is a variable that contains all the flags for ica label
                        NaN NaN;...%brain
                        1 content;...%muscle
                        1 content;...%eye
                        1 content;...%heart
                        1 content;...%line noise
                        1 content;...%channel noise
                        NaN NaN;...%other
                        ];
                end
            else
                for i=1:length(content)
                    flags(i+1,2) = content(i);
                end
                EEG = pop_icflag(EEG,flags); %???
            end
            mybadcomps = []; %not sure what it does. I think its a variable full of bad components to be rejected
            for j=1:length(EEG.reject.gcompreject) %this loop rejects all components
                if EEG.reject.gcompreject(1,j)> 0
                    mybadcomps(end+1) = j;
                end
            end
            EEG = pop_subcomp(EEG,mybadcomps,0);
            acronym = char(strcat('ICL',strcat(content)));
        end
        
        %stopped, trying to make the loops explain the vriance...!
        
        function [acronym] = icloop(content, EEG)
            % pipeliner.icloop([.8],EEG) or pipeliner.icloop(.8,EEG)
            if isempty(EEG.icaweights)
                EEG = pop_runica(EEG, 'extended',1,'interrupt','on','pca',content(end));
            end
            %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
            Loop = 0;
            EEG = pop_iclabel(EEG, 'default');
            EEG = pop_icflag(EEG, [NaN NaN;...
                content(1) 1;...
                content(1) 1;...
                content(1) 1;...
                content(1) 1;...
                content(1) 1;...
                NaN NaN]);
            mybadcomps = [];
            for j=1:length(EEG.reject.gcompreject)
                if EEG.reject.gcompreject(j)
                    mybadcomps(end+1) = j;
                    Loop = 1;
                end
            end
            EEG = pop_subcomp(EEG, mybadcomps, 0);
            %PCA reduction
            [IC,channelsss] = size(EEG.icaweights)
            if Loop > 0
                EEG = pop_runica(EEG,'pca', IC,'extended', 1);
            else
                IC=IC-1;
                EEG = pop_runica(EEG,'pca', IC,'extended', 1);
            end
            acronym = char(strcat('ICLoop',strcat(content)));
        end
        
        function [acronym] = explainedLoop(content, EEG) %%%not working yet
            %explainedLoop([numberOfComponents,percentExplained,percentGood],EEG)
            IC = size(EEG.icaweights,1);
            %Z = strfind(file1(i).name, 'C2');
            %Z = Z+1;
            if  IC > content(1)
                if content(2) > content(3)
                    acronym = char(strcat(content(2,'_BrGood')));
                else
                    IC = size(EEG.icaweights,1);
                    IC = IC - 1;
                    EEG = pop_runica(EEG, 'extended',1,'pca',IC);
                end
            else
                acronym = char(strcat('PerExp',string(content)));;
            end
        end
        
        function [PercentBrainAccountedFor_Total] = getVarianceExplained(content,EEG)
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
        
        function [finalTable] = tempReport(fileCounter,filename,content,type,EEG)
            %[table] = pipeliner.tempReport(1,EEG.filename, script, scriptcontent, EEG)
            if fileCounter == 1;
                ExcelSheetHeader = {'name','process','type', 'numchans','ref','srate','trials','events','xmax','components'};
                components = 0;
                if ~isempty(EEG.icaweights) & ~isempty(EEG.etc.ic_classification.ICLabel.classifications)
                    for j=1:128
                        components = components + 1;
                        ExcelSheetHeader{end+1} = [strcat('component ',string(components))];
                        ExcelSheetHeader{end+1} = '%';
                    end
                end
            end
            
            tempTable = {filename,content,strcat(type),EEG.nbchan,EEG.chanlocs(1).ref,EEG.srate,EEG.trials,length(EEG.event),EEG.xmax,length(EEG.icaweights)};
            
            if ~isempty(EEG.icaweights) & ~isempty(EEG.etc.ic_classification.ICLabel.classifications) %this picks up the iclabel classifications if any
                for k=1:length(EEG.etc.ic_classification.ICLabel.classifications)
                    [max_num,max_idx] = max(EEG.etc.ic_classification.ICLabel.classifications(k,:));
                    tempTable{end+1} = cell2mat((EEG.etc.ic_classification.ICLabel.classes(max_idx)));
                    tempTable{end+1} = round(max_num*100,4);
                end
                for l=1:(128-length(EEG.etc.ic_classification.ICLabel.classifications))
                    tempTable{end+1} = NaN;
                    tempTable{end+1} = NaN;
                end
            end
            finalTable = ExcelSheetHeader;
            finalTable = cat(1,finalTable,tempTable);
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
        
        function filter(content,EEG) %should work
            %store filter somewhere
            EEG = pop_eegfiltnew(EEG, 'locutoff',content(1),'plotfreqz', 0);
            EEG = eeg_checkset( EEG );
            EEG = pop_eegfiltnew(EEG, 'hicutoff',content(2),'plotfreqz', 0);
        end
        
        function [amps] = notchfilter(EEG)
            EEG = eeg_checkset( EEG );
            twoamps = [2002, 2008, 2010, 2024, 9104, 9109, 9140, 9143, 9243, 9209];
            threeamps = [1109, 1121, 1143];
            if ~ismember(str2num(EEG.setname(1:4)),threeamps) && str2num(EEG.setname(1:4)) <= 2000 ||  ismember(str2num(EEG.setname(1:4)), twoamps) %200 amps
                EEG = pop_eegfiltnew(EEG, 'locutoff',40,'hicutoff',44,'revfilt',1,'plotfreqz',1);
                EEG = eeg_checkset( EEG );
                EEG = pop_eegfiltnew(EEG, 'locutoff',59,'hicutoff',61,'revfilt',1,'plotfreqz',1);
                amps = 'NF4460'
            else
                EEG = eeg_checkset( EEG );
                EEG = pop_eegfiltnew(EEG, 'locutoff',47,'hicutoff',53,'revfilt',1,'plotfreqz',1);
                EEG = eeg_checkset( EEG );
                EEG = pop_eegfiltnew(EEG, 'locutoff',59,'hicutoff',61,'revfilt',1,'plotfreqz',1);
                amps = 'NF4760'
            end
        end
        
        function rereference(content,EEG) %untested
            switch content
                case 'LE' | 'le' | 'Le'
                    ALLEEG = pop_reref( EEG, [],'refloc',struct('labels',{'LE'},'type',{''},'theta',{[]},'radius',{[]},'X',{[]},'Y',{[]},'Z',{[]},'sph_theta',{[]},'sph_phi',{[]},'sph_radius',{[]},'urchan',{[]},'ref',{''},'datachan',{0},'sph_theta_besa',{[]},'sph_phi_besa',{[]}));
                case 'CZ' | 'cz' | 'Cz'
                    ALLEEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}));
                case 'AVG' | 'av' | 'Avg' | 'AV'
                    ALLEEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'type',{''},'theta',{[]},'radius',{[]},'X',{[]},'Y',{[]},'Z',{[]},'sph_theta',{[]},'sph_phi',{[]},'sph_radius',{[]},'urchan',{[]},'ref',{''},'datachan',{0},'sph_theta_besa',{[]},'sph_phi_besa',{[]}));
            end
        end
        
        function headmodel(content,EEG) %untested
            %ADD: autodetect which headmodels data needs
            %ADD: select headmodel file
            EEG = pop_chanedit(EEG, 'load',{'G:\\Matlab_Batch_v6.0a-129Chan-N5_DL\\C-00-InsertHeadModel\\Pre\\HCGSN128Renamed.sfp' 'filetype' 'autodetect'});
            EEG = eeg_checkset( EEG );
            EEG = pop_chanedit(EEG, 'append',131,'changefield',{132 'labels' 'Cz'},'changefield',{132 'theta' '0'},'changefield',{132 'radius' '0'},'changefield',{132 'X' '0'},'changefield',{132 'Y' '0'},'changefield',{132 'sph_theta' '0'},'changefield',{132 'sph_phi' '0'},'changefield',{132 'sph_radius' '0'},'changefield',{132 'Z' '8.7919'});
            EEG = eeg_checkset( EEG );
            EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{''},'urchan',{[]},'datachan',{0}));
            
        end
        
        function trim(content, EEG) %not started yet
            % trims the data at upper seconds lower seconds
        end
        
        function cleanline(content,EEG) %can do 50hz, 60hz, 70, and so on! %should work
            for i=1:length(content)
                EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan(1,1)] ,'computepower',1,'linefreqs',content{i},'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',4,'winstep',1);
            end
        end
        
        function interpolate(content, EEG) %should works
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
        end
        
        function epoch(content, EEG) %content must be 1.array of names of epochs, 2. first cut and 3. second cut, both in seconds
            EEG = pop_epoch( EEG, {content(1)}, [content(2) content(3)], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
            %EEG = eeg_regepochs(EEG,content,4.094,'limits',[0 4.094]); %this is will give you 2.044 epoch lenghts as matlab lose the 1st point like n-scan
        end
        
        function baseline(content, EEG) %baseline asks for two numbers %untested
            EEG = pop_rmbase( EEG, [content(1) content(2)]);
        end
        
    end
end