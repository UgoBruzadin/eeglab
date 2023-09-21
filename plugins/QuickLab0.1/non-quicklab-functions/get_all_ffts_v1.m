


ext = '.set';

mainfolder = pwd;

[ FullFileList ] = GetAllDirFiles(pwd, ext);

%FinalTable(i,1:9) = {'ID','Session','delta','theta','alpha','beta1','beta2','beta3','gamma'};

eeglab

low = 3.5;
high = 31;

freqsize = 257;

FinalTable = zeros(length(FullFileList),freqsize);

parfor i=1:size(FullFileList,1)

    [EEG] =  pop_loadset(FullFileList(i).name, FullFileList(i).folder,  'all','all','all','all','auto'); %loads files

    [spectra,freqs] = spectopo(EEG.data,EEG.pnts,EEG.srate,'winsize',512,'plot','off');

    mean_spectra = mean(spectra);

    FinalTable(i,:) = mean_spectra;

end

save(['All_ffts.mat'],'FinalTable'); %saves the table in .mat format

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot spectrum of each channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



allcolors = { [0 0.7500 0.7500]
    [1 0 0]
    [0 0.5000 0]
    [0 0 1]
    [0.2500 0.2500 0.2500]
    [0.7500 0.7500 0]
    [0.7500 0 0.7500] }; % colors from real plots                };

mainfig = gca; axis off;
specaxes = sbplot(3,4,[5 12], 'ax', mainfig);

for index = 1:size(FinalTable,1)
    tmpcol  = allcolors{mod(index, length(allcolors))+1};
    command = ['disp(''File  ' FullFileList(index).name ''')'];
    pl(index)=plot(freqs(7:66),FinalTable(index,7:66)', ...
        'color', tmpcol, 'ButtonDownFcn', command); hold on;
end

set(pl,'LineWidth',2);
set(gca,'TickLength',[0.02 0.02]);
%     try,
%         axis([freqs(minfreqidx) high reallimits(1) reallimits(2)]);
%     catch, disp('Could not adjust axis'); end
xl=xlabel('Frequency (Hz)');
%set(xl,'fontsize',AXES_FONTSIZE_L);
% yl=ylabel('Rel. Power (dB)');
yl=ylabel('Log Power Spectral Density 10*log_{10}(\muV^{2}/Hz)');%yl=ylabel('Power 10*log_{10}(\muV^{2}/Hz)');
%set(yl,'fontsize',AXES_FONTSIZE_L);
%set(gca,'fontsize',AXES_FONTSIZE_L)
box off;

saveas(gcf,'all_ffts.jpg')