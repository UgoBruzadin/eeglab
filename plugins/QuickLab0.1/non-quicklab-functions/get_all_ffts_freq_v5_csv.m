%clear all
%clc;

mainfolder = pwd;

% choose high frequency to plot and low frequency to plot
low = 6.5;
high = 30;
%theta (6.5hz to 8hz), alpha-1 (8.5hz to 10hz), alpha-2 (10.5 to 12hz), beta-1 (12.5hz to 18hz), beta-2 (18.5hz to 21hz), beta-3 (21.5hz to 30hz) 

theta = [6.5 8];
alpha1 = [8.5 10];
alpha2 = [10.5 12];
beta1 = [12.5 18];
beta2 = [18.5 21];
beta3 = [21.5 30];

allfreqs = [theta; alpha1; alpha2; beta1; beta2; beta3];

% F3, Fz, F4, C3, Cz, C4, P3, Pz, P4
frequencies = ["theta","alpha1","alpha2","beta1","beta2","beta3"];
channelnames = ["Fz", "F3", "C3", "P3", "Pz", "P4", "C4", "F4","Cz"];

channels = [07 15 23 34 43 63 72 85 86];

allids = table2array(alldatRedit(:,1));

count = 1;
for i=1:size(channelnames,2)
    for j = 1:size(frequencies,2)
        chanfreq(count) = strcat(channelnames(i),'_',frequencies(j));
        count = count + 1;
    end
end
% collects all folders with 2 letters!
%[ FullFolderList ] = GetAllDirFolders(pwd,2);

% create a table of tables!
%FinalFolder_tables = cell(size(FullFolderList,1),1);

eeglab;
%for j = 1: size(FullFolderList,1) % FIX THIS BEFORE SAVING!!

%[ FullFileList ] = GetAllDirFiles(pwd, '.set');
%for j = 1: size(FullFileList,1)

    %cd(strcat(FullFolderList(j).folder,'\',FullFolderList(j).name))

    % collect all files in the directory
    [ FullFileList ] = GetAllDirFiles(pwd, '.set');

    %load first file to collect information on the srate and winsize
    %[EEG] =  pop_loadset(FullFileList(1).name, FullFileList(1).folder,  'all','all','all','all','auto'); %loads files

    %make max window, if needed be change this ti desired winsize i.e. 512
    winsize = 2^floor(log2(EEG.pnts));

    %runs spectra on first file, again to know generally the frequencies and
    %spectra
    %[spectra,freq] = spectopo(EEG.data,EEG.pnts,EEG.srate,'winsize',winsize,'plot','off');

    % makes the right assertion over the number of frequencies to be created,
    % not sure if this will work for every file, needs to be checked
    freqsize = (EEG.pnts/2)+1;

    %created an empty table for all frequencies
    %FinalTable = zeros(length(FullFileList),freqsize);

    %freqs = cell(size(FullFileList,1),1);

    % loops through all files, collecting the bins in the FinalTable.
    allids = char(strcat(T4.name,'E',num2str(T4.Session)));

    for i=112:size(FullFileList,1)
        try
        [EEG] =  pop_loadset(FullFileList(i).name, FullFileList(i).folder,  'all','all','all','all','auto'); %loads files
        
        findIDx = strfind(string(allids),EEG.filename(1:6));
        IDx = find(~cellfun('isempty',findIDx));

        %reref MASTOIDS
        %EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}));
        %EEG = pop_reref( EEG, [38 68] ,'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}),'keepref','on');
        EEG = pop_reref( EEG, {'E57_N44' 'E100_N74'} ,'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}),'keepref','on');
        [spectra,freqs] = spectopo(EEG.data,EEG.pnts,EEG.srate,'winsize',512,'plot','off');

        %getids
        count = 1;
        for cha=1:size(channels,2)
            chanspec = spectra(channels(cha),:);

            for fre = 1:size(frequencies,2)
                %chanfreq(count) = strcat(channelnames(t),'_',frequencies(y));

                freqIdx = find(freqs>allfreqs(fre,1) & freqs<allfreqs(fre,2));
                T4(IDx,25+count) = {mean(10.^(chanspec(freqIdx)/10))};

                count = count + 1;
            end
% 
%             thetaIdx = find(freqs>theta(1) & freqs<theta(2));
%             alpha1Idx = find(freqs>alpha1(1) & freqs<alpha1(2));
%             alpha2Idx = find(freqs>alpha2(1) & freqs<alpha2(2));
%             beta1Idx = find(freqs>beta1(1) & freqs<beta1(2));
%             beta2Idx = find(freqs>beta2(1) & freqs<beta2(2));
%             beta3Idx = find(freqs>beta3(1) & freqs<beta3(2));
% 
%             T4(ID,25+cha*size(chans,2)) = mean(10.^(chanspec(thetaIdx)/10));
%             T4(ID,25+cha*size(chans,2)) = mean(10.^(chanspec(alpha1Idx)/10));
%             T4(ID,25+cha*size(chans,2)) = mean(10.^(chanspec(alpha2Idx)/10));
%             T4(ID,25+cha*size(chans,2))  = mean(10.^(chanspec(beta1Idx)/10));
%             T4(ID,25+cha*size(chans,2))  = mean(10.^(chanspec(beta2Idx)/10));
%             T4(ID,25+cha*size(chans,2))  = mean(10.^(chanspec(beta3Idx)/10));

            %print csvs
            %spectra_table = array2table(spectra,'VariableNames',string(freqs));

        end

        catch
            fprintf('hi')
        end
        
        %freqs(i) = freq;

        %mean_spectra = mean(spectra);

        %FinalTable(i,:) = mean_spectra;

    end
    writetable(T4,[Dotloc_Spectable,'.xlsx']);

%end
    %[tmp indexfreq] = min(abs(g.freq-freqs));


    %saves data from these ffts.
%     FinalFolder_tables{j} = FinalTable; %store in the big table
%     save(['All_ffts.mat'],'FinalTable'); %saves the table in .mat format
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % plot spectrum of each file
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % Adjusts the colors
% allcolors = { [0 0.7500 0.7500]
%     [1 0 0]
%     [0 0.5000 0]
%     [0 0 1]
%     [0.2500 0.2500 0.2500]
%     [0.7500 0.7500 0]
%     [0.7500 0 0.7500] }; % colors from real plots                };
% 
% figure; % makes new figure
% 
% mainfig = gca; axis off;
% %specaxes = sbplot(3,4,[5 12], 'ax', mainfig);
% specaxes = sbplot(1,1,1, 'ax', mainfig);
% 
% % calculates min and max frequencies to plot
% [tmp maxfreqidx] = min(abs(high-freq));
% [tmp minfreqidx] = min(abs(low-freq));
% 
% % loops through every row ht Final Table and plots
% for index = 1:size(FinalTable,1)
%     tmpcol  = allcolors{mod(index, length(allcolors))+1};
%     command = ['disp(''File  ' FullFileList(index).name ''')']; % this is the command that diplays the file name.
%     pl(index)=plot(freq(minfreqidx:maxfreqidx),FinalTable(index,minfreqidx:maxfreqidx)', ...
%         'color', tmpcol, 'ButtonDownFcn', command); hold on;
% end
% 
% % Adjusts the figure
% set(pl,'LineWidth',2);
% set(gca,'TickLength',[0.02 0.02]);
% %     try,
% %         axis([freqs(minfreqidx) high reallimits(1) reallimits(2)]);
% %     catch, disp('Could not adjust axis'); end
% xl=xlabel('Frequency (Hz)');
% set(xl,'fontsize',12);
% yl=ylabel('Rel. Power (dB)');
% yl=ylabel('Log Power Spectral Density 10*log_{10}(\muV^{2}/Hz)');%yl=ylabel('Power 10*log_{10}(\muV^{2}/Hz)');
% set(yl,'fontsize',12);
% set(gca,'fontsize',12)
% box off;
% 
% if strcmp(FullFolderList(j).name(1),'E')
% % Change the title accordingly!
%     textsc(sprintf(strcat('Mean Spectral Activity for Session',FullFolderList(j).name(2))), 'title');
% else
%     groupnumber = str2double(FullFolderList(j).name(end))
%     switch groupnumber
%         case 1
%             groupname = ' BUP'
%         case 2
%             groupname = ' NRT'
%         case 3
%             groupname = ' PLA'
%         case 4
%             groupname = ' SMO'
%     end
%     textsc(sprintf(strcat('Mean Spectral Activity for Session ',' ',FullFolderList(j).folder(end),' for ',groupname)), 'title');
% end
% set(gca,'fontsize',12)
% saveas(gcf,'all_ffts.jpg')
% save(['All_Groups_of_FFts.mat'],'FinalFolder_tables')
% end