% Author: Ugo Bruzadin Nunes
% SIUC
% email: ugobruzadin@gmail.com
% Dec 2019

classdef pipeliner2
    methods(Static)
%         
%         function pipeline(content,type)
%            for i=1:length(content)
%             pipeliner2.Function(content(i), type(i))
%            end
%         end
        
        function Function() %magic function, runs the code asked!

            pipeliner2.clean();
            fname = strcat(mfilename);
            %fname2 = strcat(mfilename,'.');
            eeglab;
            [files,path] = uigetfile({'*.set'},'Multiple File Selection','MultiSelect','on');
            cd(path);
            [scriptName,scriptPath] = uigetfile({'*.m'},'Multiple Scripts Selection','MultiSelect','on');
            addpath(scriptPath);
            %cd(path);
            %file = files;
            %files = dir('*.set');
            t = datetime('now','TimeZone','local','Format','dMMMy-HH.mm');
            nameDate = strcat(scriptName,char(t))
            [filePRE, filePOST] = pipeliner2.createfolders(files,nameDate);
            cd(filePRE);
            fileCounter = 0;
            finalReport = [];
            tic
            for i=1:length(files)
                tic %start timer
                [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                EEG =  pop_loadset(files(i).name, filePRE,  'all','all','all','all','auto');
                fileCounter =+ 1;
                [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
                cd (scriptPath);
                str2func(scriptName); %this call a function inside this function with the name asked for!
                %action = str2func(strcat(fname,type)); %this call a function inside this function with the name asked for!
                %action(content, EEG); %this is where the function runs the asked code!
                EEG = eeg_checkset(EEG);
                %[acronym] = pipeliner2.makeAcronym(type,content);
                %Acronym = type(1:2);
                EEG = pop_saveset(EEG, 'filename', [strcat(files(i).name(1:end-4), '_', scriptName, '.set')], 'filepath',filePOST);
                
                [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                [temporaryTable] = pipeliner2.tempReport(fileCounter, files(i).name,contents,EEG,t);
                t = datetime('now','TimeZone','local','Format','dMMMy-HH.mm'); % gets time
                finalReport = cat(1,finalReport,temporaryTable);
                ALLEEG = pop_delset(ALLEEG, 1);
                pipeliner2.emptyTrash(); %deletes binica's leftover trash
                Report_Name = strcat(scriptName,t); %
                xlswrite(Report_Name,finalReport); %writes the report down
            end
            pipeliner2.txt(strcat('processing ', scriptName,t,' is over'))
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
        
        function [filePRE, filePOST] = createfolders(files, type) %untested
            % create the folders where the pipeline will run
            %filePRE = strcat(basefolder,'\', type, '\pre'); %copies files
            %here, so I turned it off)

            basefolder = pwd;
            filePRE = basefolder; %made this line later!
            mkdir (type)
            mkdir (type,  'pre');
            fdtfiles = dir('*.fdt');
            %filePRE = strcat(basefolder,'\', type, '\pre');
            filePOST = strcat(basefolder,'\',type);
            
            %for i=1:length(files)
                %copyfile(files(i).name, filePRE)
                %copyfile(fdtfiles(i).name, filePRE);
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
        
        function icalabel(content,EEG) %probably needs fixing in rejecting! %might be working!
            EEG = eeg_checkset( EEG );
            EEG = pop_iclabel(EEG, 'default');
            EEG = eeg_checkset( EEG );
            flags = [...
                NaN NaN;...%brain
                NaN NaN;...%muscle
                NaN NaN;...%eye
                NaN NaN;...%heart
                NaN NaN;...%line noise
                NaN NaN;...%channel noise
                NaN NaN;...%other
                ];
            if string(content(1)) == 'all'
                for i=1:length(content)
                    flags(i,2) = content{2};
                end
            else
                for i=1:length(content)
                    flags(i,1) = content(i,1);
                    flags(i,2) = content(i,2);
                end
                    EEG = pop_icflag(EEG, flags);
            end
            mybadcomps = [];
            for j=1:length(EEG.reject.gcompreject)
                if EEG.reject.gcompreject(1,j)> 0
                    mybadcomps(end+1) = j;
                end
            end
            EEG = pop_subcomp( EEG, mybadcomps, 0);  
        end
        
        function [tempTable] = tempReport(fileCounter,filename,content,EEG)
            %pipeliner2.tempReport(fileCounter, files(i),action,type,EEG)
            ExcelSheet = [];
            if fileCounter == 1
                ExcelSheetHeader = {'name','process','process info','numchans','ref','srate','trials','events','xmax','components'};
                if ~isempty(EEG.icaweights)
                    for j=1:size(EEG.icaweights,1)
                        ExcelSheetHeader{end+1} = [j,];
                        ExcelSheetHeader{end+1} = '%';
                    end
                end
            end
            tempTable = ExcelSheetHeader;
            tempTable = cat(1,tempTable,{filename,content,EEG.nbchan,EEG.chanlocs(1).ref,EEG.srate,EEG.trials,length(EEG.event),EEG.xmax,length(EEG.icaweights)});
            if ~isempty(EEG.icaweights)
                [max_num,max_idx] = max(EEG.etc.ic_classification.ICLabel.classifications(j,:));
                tempTable{end+1} = cell2mat((EEG.etc.ic_classification.ICLabel.classes(max_idx)));
                tempTable{end+1} = round(max_num*100,4);
            end
        end
                
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
        
        function ica(content, EEG) %works
            EEG = pop_runica(EEG,'extended', 1, 'verbose', 'off','pca', content);
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