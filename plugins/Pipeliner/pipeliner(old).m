% Author: Ugo Bruzadin Nunes
% SIUC
% email: pipelinerbruzadin@gmail.com
% Dec 2019

classdef pipeliner
    methods(Static)
        
        function batches(batches,batchFolder) %store all batches to be done
            OGfolder = batchFolder;
            for i=1:length(batches)
                cd(OGfolder);
                files = dir('*.set');
                batchName = char(strcat('Batch_',num2str(i))); %names batch to "Batch"+number of the batch
                [batchFolder] = pipeliner.createBatchFolders(OGfolder,files,batchName); %created batch folder
                fprintf('generating batch folders'); %prints this sentence
                pipeliner.pipeIn(batchFolder,batches(i)); %start the pipeline
            end
        end
        
        function pipeIn(batchFolder,commands) %store the functions to be rolled in this batch
            commands = table2array(commands); %gets the array of commands to be pipelined
            folderCounter = 0; %start a counter of folders/commands to be run
            fileFolder = batchFolder; %begins with the files inside the main batch folder
            for i=1:length(commands) %for loop, loops the number of commands
                folderCounter = folderCounter + 1;%adds one folder to the counter
                %starts the pipeline
                [fileFolder] = pipeliner.Function(table2array(commands(i)),batchFolder,fileFolder,folderCounter);
            end
        end
        
        function [filePOST] = Function(commands,batchPath,filePath,counter) %magic function, runs the code asked!
            %type = string, the function to be called
            %content = [], arrayof  the extra information to that function
            
            pipeliner.clean(); %wipe the memory
            t = datetime('now','TimeZone','local','Format','dMMMy-HH.mm'); %gets the datetime
            fname = strcat(mfilename,'.'); %get the name of this function for future use, adds a dot to it
            
            cd(filePath); %moves the the last path where files were
            %tic; %start a timer
            folderLetter = char(counter+64); %names the folder!
            folderNameDate = strcat(folderLetter,'-',char(commands(1)),'-',char(t));
            
            [files, filePRE, filePOST] = pipeliner.createfolders(filePath,batchPath,folderNameDate); %creates a folder for the pipeline
            cd(filePRE);
            
            parfor i=1:length(files)
                %load EEG
                EEG =  pop_loadset(files(i).name, filePRE,  'all','all','all','all','auto');
                EEG = eeg_checkset(EEG);
                %call the function = can be susbtituted for a script in the future
                action = str2func(strcat(fname,char(commands(1)))); %this call a function inside this function with the name asked for!
                if length(commands) > 1
                    [EEG, acronym] = action(commands(2:end), EEG); %this is where the function runs the asked code!
                else
                    [EEG, acronym] = action(EEG); %this is where the function runs the asked code!
                end
                
                EEG = eeg_checkset(EEG);
                [individualReport] = pipeliner.tempReport(files(i).name,EEG);%changedneedsfixing
                %saving files & report
                EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4), [acronym], '.set')], 'filepath',filePOST);
                writetable(cell2table(individualReport),strcat(files(i).name(1:end-4),'_report.xlsx')); %saves the table in .mat format
                pipeliner.fft(files(i),EEG);
                %pipeliner.componentFigures(files(i),EEG)
            end
            reports = dir('*.xlsx');
            for i=1:length(reports)
                if i==1
                    finalReport = readtable(reports(i).name);
                else
                    finalReport = cat(1,finalReport,readtable(reports(1).name));
                end
            end
            writetable(finalReport, strcat(folderNameDate,'full_report.xlsx'));
            %------
            %cleaning the folder from binica trash
            pipeliner.emptyTrash(); %deletes binica's leftover trash
            %sends text to me
            %pipeliner.txt(strcat('processing of is over'));
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
            cd(batchPath)
            mkdir (folderName);
            mkdir (folderName,  'pre');
            cd(filePath);
            fdtfiles = dir('*.fdt');
            files = dir('*.set');
            %------
            filePRE = strcat(batchPath,'\', folderName, '\pre');
            filePOST = strcat(batchPath,'\',folderName);
            %------
            parfor i=1:length(files)
                copyfile(files(i).name, filePRE)
                copyfile(fdtfiles(i).name, filePRE);
            end
        end
        
        function [batchFolder] = createBatchFolders(path,files,folderName) %works!!!
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
            %content = cell2mat(content);
            EEG = pop_runica(EEG,'extended', 1, 'pca', table2array(components), 'verbose','off');
            EEG = pop_iclabel(EEG,'default');
            acronym = char(strcat('IC',num2str(table2array(components))));
        end
        
        function [EEG, acronym] = iclabel(cuts,EEG) %iclabel({'all',.9},EEG)
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
            if length(cuts) == 1
                %content = cell2mat(content);
                for i=1:length(flags)
                    flags = [... %this is a variable that contains all the flags for ica label
                        NaN NaN;...%brain
                        1 cuts;...%muscle
                        1 cuts;...%eye
                        1 cuts;...%heart
                        1 cuts;...%line noise
                        1 cuts;...%channel noise
                        NaN NaN;...%other
                        ];
                end
            else
                for i=1:length(cuts)
                    flags(i+1,2) = cell2num(cuts(i));
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
            acronym = char(strcat('ICL',strcat(cuts)));
        end
        
        %stopped trying to make the loops explain the vriance...!
        
        function [EEG, acronym] = icloop(cut, EEG)
            %------ pipeliner.icloop([.8],EEG) or pipeliner.icloop(.8,EEG)
            if ~size(EEG.icaweights,1)
                EEG = pop_runica(EEG, 'extended',1,'interrupt','on','pca',floor(sqrt(EEG.pnts/20)),'verbose','off');
            end
            IC = size(EEG.icaweights,1);
            oldEEG = EEG;
            %IC2 = size(EEG.icaweights,1);
            loop = 100;
            for j=1:loop
                %------ run IC label & flag 
                EEG = pop_iclabel(EEG, 'default');
                EEG = pop_icflag(EEG, [NaN NaN;0.97 1;0.97 1;0.97 1;0.97 1;0.97 1;NaN NaN]);
                %------ store components and update component number
                mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected
                IC = IC - length(mybadcomps);            %stores the number to be the next components analysis
                EEG = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
                
                %------ reset IC2, which is the last highest component #
                if ~isempty(mybadcomps)              %if any components are removed, the IC2 stores the last time a pca removed a comp.
                    %IC2 = IC;               %reset the original IC number so we can go back in case no components are removed later on.
                    oldEEG = EEG;
                end
                
                %------- PCA reduction & break if limit reached
                
                    IC = IC - 1;                    % makes the next PCA of 1 number smaller.
                %------- run new relative PCA
                try EEG = pop_runica(EEG,'extended',1,'pca',IC,'verbose','off'); %does a PCA of IC
                catch EEG = pop_runica(EEG,'extended',1,'pca',IC,'verbose','off'); %BUG: it looks likes it picks up the wrong binica files. inconsistent error.
                end
                if size(EEG.icaweights,1) <= table2array(cut(2)) %stops the loop when the number given in the command line
                    break
                end
            end
            %------- return to last highest component, store acronym
            EEG = oldEEG;
            %EEG = pop_runica(EEG, 'extended',1,'pca',IC2-1,'verbose','off'); %runs a PCA to the last num of ICs since a component was removed
            acronym = char(strcat('IL',num2str(size(EEG.icaweights,1)))); %the acronym to be passed along to be added to the name of the file
        end
        
        function [EEG, acronym] = explainedLoop(content, EEG) %%%not working yet
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
            
            tempTable = {filename,EEG.nbchan,EEG.chanlocs(1).ref,EEG.srate,EEG.trials,length(EEG.event),EEG.xmax,size(EEG.icaweights,1)};
            
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
            
            %finalTable = cat(1,finalTable,tempTable);
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
            %store filter somewhere
            %content = cell2mat(content);
            EEG = pop_eegfiltnew(EEG, 'locutoff',commands(1),'plotfreqz', 0);
            EEG = eeg_checkset( EEG );
            EEG = pop_eegfiltnew(EEG, 'hicutoff',commands(2),'plotfreqz', 0);
            acronym = char(strcat('FI',num2char(commands(1)),'-',num2char(commands(2))));
        end
        
        function [acronym] = notchfilter(EEG)
            EEG = eeg_checkset( EEG );
            twoamps = [2002, 2008, 2010, 2024, 9104, 9109, 9140, 9143, 9243, 9209];
            threeamps = [1109, 1121, 1143];
            if ~ismember(str2num(EEG.setname(1:4)),threeamps) && str2num(EEG.setname(1:4)) <= 2000 ||  ismember(str2num(EEG.setname(1:4)), twoamps) %200 amps
                EEG = pop_eegfiltnew(EEG, 'locutoff',40,'hicutoff',44,'revfilt',1,'plotfreqz',1);
                EEG = eeg_checkset( EEG );
                EEG = pop_eegfiltnew(EEG, 'locutoff',59,'hicutoff',61,'revfilt',1,'plotfreqz',1);
                acronym = 'NF4460'
            else
                EEG = eeg_checkset( EEG );
                EEG = pop_eegfiltnew(EEG, 'locutoff',47,'hicutoff',53,'revfilt',1,'plotfreqz',1);
                EEG = eeg_checkset( EEG );
                EEG = pop_eegfiltnew(EEG, 'locutoff',59,'hicutoff',61,'revfilt',1,'plotfreqz',1);
                acronym = 'NF4760'
            end
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
            %EEG = pop_epoch( EEG, {content(1)},'limits', [content(2) content(3)], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
            EEG = pop_epoch( EEG, { string(content(1)) }, [content(2) content(3)], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
            
            %EEG = pop_epoch( EEG, { 'DIN' }, [0.400 2.448], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');
            
            %EEG = eeg_regepochs(EEG,content,4.094,'limits',[0 4.094]); %this is will give you 2.044 epoch lenghts as matlab lose the 1st point like n-scan
            acronym = 'EP';%make for variable epoc name!
        end
        
        function [EEG, acronym] = baseline(commands, EEG) %baseline asks for two numbers %untested
            EEG = pop_rmbase( EEG, [commands(1) commands(2)]);
            acronym = 'BL'; %make for variable baseline later
        end
        %figuregenerators!
        function fft(files,EEG)
            figure; pop_spectopo(EEG, 1, [EEG.xmin*10^3  EEG.xmax*10^3], 'EEG' , 'freq', [4 6 8 10 12 14 16 18 20 25 30 35 40], 'freqrange',[2 55], 'electrodes','off');
            saveas(gcf,[strcat(files.name(1:end-4),'_FFT.jpg')]);
            close all;
        end
        
        function componentFigures(files,EEG)
            figure; pop_viewprops( EEG, 0,[1:[size(EEG.icaweights,1)]], {'freqrange', [2 55]}, {}, 2, 'ICLabel' )
            saveas(gcf,[strcat(files.name(1:end-4),'_ICS.jpg')]);
            close all;
        end
        
    end
end