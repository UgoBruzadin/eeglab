% Author: Ugo Bruzadin Nunes
% SIUC
% email: ugobruzadin@gmail.com
% Dec 2019

classdef ugo
    methods(Static)
        
        function txt(content)
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
        
        function clean()
            clc;         % clear command window
            clear all;
            evalin('base','clear all');  % clear base workspace as well
            close all;   % close all figures
        end
        
        function createfolders(type)
            % create the folders where the pipeline will run
            basefolder = pwd;
            mkdir type
            mkdir pre
            mkdir post
            for i=1:length(file1)
                copyfile(file1(i).name, strcat(basefolder,'/pre');
            end
            save(strcat(type,'.mat'),'FinalTable');
        end
        
        function pipeline()
            number = 1;
        end
        
        function Function(type,content)
            fname = strcat(mfilename,'.');
            ugo.clean()
            ugo.createfolder(ugo.pipeline.number, type)
            fileINPUT = pwd;
            fileOUTPUT = pwd;
            cd(fileINPUT)
            files = dir('*.set')
            Acronym = type(1:2);%getAcronym(action)
            for i=1:length(files)
                [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
                EEG =  pop_loadset(files(i).name, fileINPUT,  'all','all','all','all','auto');
                [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
                action = str2func(strcat(fname,type)); %this call a function inside this function with the name asked for!
                action(content, EEG)
                EEG = eeg_checkset(EEG);
                EEG = pop_saveset(EEG, 'filename', [files(i).name(1:end-4), '_',Acronym,'.set'], 'filepath',fileOUTPUT);
                [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                ugo.storemat(EEG);
                ALLEEG = pop_delset(ALLEEG, 1);
            end
        end
        
        function savemat(FinalTable)
            save('AllFilesComponents_v2a.mat','FinalTable'); %saves the table in .mat format
        end
        
        function savexls(FinalTable)
            writecell(FinalTable,'AllFilesComponents_v2a.xls');  
        end
        
        function icaloop(content,EEG)
            %             IC = size(EEG.icaweights,1);
            %             while IC > content
            %                 ugo.ica(content, EEG)
            %                 EEG = pop_icflag(EEG, [NaN 0.01;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
            %                 mybadcomps = [];
            %                 for j=1:length(EEG.reject.gcompreject)
            %                     if EEG.reject.gcompreject(j,1)> 0
            %                         mybadcomps(end+1) = j;
            %                     end
            %                 end
            %             end
        end
        
        function [] = storeica(header,content)
            FinalTable = {'name','ref','numchans','srate','trials','event','xmax'};

                tempCompTable = {[file1(i).name],EEG.chanlocs(1).ref,EEG.nbchan,EEG.srate,EEG.trials,length(EEG.event),EEG.xmax};
                for j=1:size(EEG.icaweights,1)
                    if i < 2
                        FinalTable{end+1} = [j,];
                        FinalTable{end+1} = '%';
                    end
                    [max_num,max_idx] = max(EEG.etc.ic_classification.ICLabel.classifications(j,:));
                    tempCompTable{end+1} = cell2mat((EEG.etc.ic_classification.ICLabel.classes(max_idx)));
                    tempCompTable{end+1} = round(max_num*100,4);
                end
                FinalTable = cat(1,FinalTable,tempCompTable); % the function cat adds the table from file #(i) to the FinalTable matrix         
        end
        
        
        function storemat(EEG)
            TemporaryTable = {EEG.filename,EEG.chanlocs(1).ref,EEG.ref(1),EEG.nbchan,EEG.srate,EEG.trials,EEG.xmax};
            FinalTable = cat(1,FinalTable,TemporaryTable); % the function cat adds the table from file #(i) to the FinalTable matrix
        end
        
        function filter(content,EEG)
            %store filter somewhere
            EEG = pop_eegfiltnew(EEG, 'locutoff',content{1},'plotfreqz', 0);
            EEG = eeg_checkset( EEG );
            EEG = pop_eegfiltnew(EEG, 'hicutoff',content{2},'plotfreqz', 0);
            EEG = pop_saveset(EEG, 'filename', [file1(i).name(1:end-4), '_.3HP55LP.set'],'filepath',fileOUTPUT2);
            
        end
        function rereference(content,EEG)
            switch content
                case 'LE' | 'le' | 'Le'
                    ALLEEG = pop_reref( EEG, [],'refloc',struct('labels',{'LE'},'type',{''},'theta',{[]},'radius',{[]},'X',{[]},'Y',{[]},'Z',{[]},'sph_theta',{[]},'sph_phi',{[]},'sph_radius',{[]},'urchan',{[]},'ref',{''},'datachan',{0},'sph_theta_besa',{[]},'sph_phi_besa',{[]}));
                case 'CZ' | 'cz' | 'Cz'
                    ALLEEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}));
                case 'AVG' | 'av' | 'Avg' | 'AV'
                    ALLEEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'type',{''},'theta',{[]},'radius',{[]},'X',{[]},'Y',{[]},'Z',{[]},'sph_theta',{[]},'sph_phi',{[]},'sph_radius',{[]},'urchan',{[]},'ref',{''},'datachan',{0},'sph_theta_besa',{[]},'sph_phi_besa',{[]}));
            end
        end
        
        function headmodel(content,EEG)
            %autodetect which headmodels data needs
            EEG = pop_chanedit(EEG, 'load',{'G:\\Matlab_Batch_v6.0a-129Chan-N5_DL\\C-00-InsertHeadModel\\Pre\\HCGSN128Renamed.sfp' 'filetype' 'autodetect'});
            EEG = eeg_checkset( EEG );
            EEG = pop_chanedit(EEG, 'append',131,'changefield',{132 'labels' 'Cz'},'changefield',{132 'theta' '0'},'changefield',{132 'radius' '0'},'changefield',{132 'X' '0'},'changefield',{132 'Y' '0'},'changefield',{132 'sph_theta' '0'},'changefield',{132 'sph_phi' '0'},'changefield',{132 'sph_radius' '0'},'changefield',{132 'Z' '8.7919'});
            EEG = eeg_checkset( EEG );
            EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{''},'urchan',{[]},'datachan',{0}));
            
        end
        
        function trim(content, EEG)
            % trims the data at upper seconds lower seconds
        end
        
        function ica(content, EEG)
            EEG = pop_runica(EEG,'pca', content, 'extended', 1);
            EEG = pop_iclabel(EEG, 'default');
        end
        
        function cleanline(content,EEG) %can do 50hz, 60hz, 70, and so on!
            for i=1:length(content)
                EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan(1,1)] ,'computepower',1,'linefreqs',content{i},'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',1,'sigtype','Channels','tau',100,'verb',1,'winsize',4,'winstep',1);
            end
        end
        
        function interpolate(content, EEG)
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
        
        function baseline(content, EEG) %baseline asks for two numbers
            EEG = pop_rmbase( EEG, [content(1) content(2)]);
        end
        
    end
end