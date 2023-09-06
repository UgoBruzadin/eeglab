clear all
clc;

mainfolder = pwd;

% choose high frequency to plot and low frequency to plot
low = 3.5;
high = 31;

% collect all files in the directory
FullFileList = dir('*.set');

%load first file to collect information on the srate and winsize
[EEG] =  pop_loadset(FullFileList(1).name, FullFileList(i).folder,  'all','all','all','all','auto'); %loads files  

%make max window, if needed be change this ti desired winsize i.e. 512
winsize = 2^floor(log2(EEG.pnts));

%runs spectra on first file, again to know generally the frequencies and
%spectra
[spectra,freq] = spectopo(EEG.data,EEG.pnts,EEG.srate,'winsize',winsize,'plot','off');

% makes the right assertion over the number of frequencies to be created,
% not sure if this will work for every file, needs to be checked
freqsize = (EEG.pnts/2)+1;

%created an empty table for all frequencies
FinalTable = zeros(length(FullFileList),freqsize);

% create a table of tables!
FinalFolder_tables = cell()
%freqs = cell(size(FullFileList,1),1);

% loops through all files, collecting the bins in the FinalTable.
parfor i=1:size(FullFileList,1)
    
    [EEG] =  pop_loadset(FullFileList(i).name, FullFileList(i).folder,  'all','all','all','all','auto'); %loads files
    
    [spectra,freqss] = spectopo(EEG.data,EEG.pnts,EEG.srate,'winsize',winsize,'plot','off');
    
    %freqs(i) = freq;

    mean_spectra = mean(spectra);

    FinalTable(i,:) = mean_spectra;

end


%[tmp indexfreq] = min(abs(g.freq-freqs));


%saves data from these ffts.
save(['All_ffts.mat'],'FinalTable'); %saves the table in .mat format

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot spectrum of each file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Adjusts the colors
allcolors = { [0 0.7500 0.7500]
    [1 0 0]
    [0 0.5000 0]
    [0 0 1]
    [0.2500 0.2500 0.2500]
    [0.7500 0.7500 0]
    [0.7500 0 0.7500] }; % colors from real plots                };

figure; % makes new figure

mainfig = gca; axis off;
specaxes = sbplot(3,4,[5 12], 'ax', mainfig);

% calculates min and max frequencies to plot
[tmp maxfreqidx] = min(abs(high-freq));
[tmp minfreqidx] = min(abs(low-freq));

% loops through every row ht Final Table and plots
for index = 1:size(FinalTable,1)
    tmpcol  = allcolors{mod(index, length(allcolors))+1};
    command = ['disp(''File  ' FullFileList(index).name ''')']; % this is the command that diplays the file name.
    pl(index)=plot(freqs(minfreqidx:maxfreqidx),FinalTable(index,minfreqidx:maxfreqidx)', ...
        'color', tmpcol, 'ButtonDownFcn', command); hold on;
end

% Adjusts the figure
set(pl,'LineWidth',2);
set(gca,'TickLength',[0.02 0.02]);
%     try,
%         axis([freqs(minfreqidx) high reallimits(1) reallimits(2)]);
%     catch, disp('Could not adjust axis'); end
xl=xlabel('Frequency (Hz)');
set(xl,'fontsize',12);
yl=ylabel('Rel. Power (dB)');
yl=ylabel('Log Power Spectral Density 10*log_{10}(\muV^{2}/Hz)');%yl=ylabel('Power 10*log_{10}(\muV^{2}/Hz)');
set(yl,'fontsize',12);
set(gca,'fontsize',12)
box off;

% Change the title accordingly!
textsc(sprintf('Mean Spectral Activity for Session 1 Group 1'), 'title');

saveas(gcf,'all_ffts.jpg')