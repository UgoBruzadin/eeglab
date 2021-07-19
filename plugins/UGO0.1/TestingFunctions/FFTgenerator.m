clc
clear all
%addpath('C:\eeglab12_0_1_0b\');
[file1 path1]=uigetfile('*.set','Select RAW files','Multiselect', 'ON');
if ischar(file1)==1
    file1={file1};
end

eeglab;
parfor i=1:length(file1)
    EEG = pop_loadset( file1{1,i}, path1);
    %[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
    h=figure
    % figure; pop_erpimage(EEG,1, [11],[[]],'PZ',10,1,{},[],'' ,'yerplabel','\muV','erp','on','cbar','on','topo', { [11] EEG.chanlocs EEG.chaninfo } );
    %figure; pop_eegplot( EEG, 1, 1, 1);
    %figure; [EEG.x EEG.y] = pop_par_spectopo(EEG, 1, [], 'EEG' , 'winsize', 512, 'freq', [5 8 12 20 30 40 40 50], 'freqrange',[2 60],'electrodes','off');
    
    %figure; pop_spectopo(EEG, 1, [EEG.xmin*1000  EEG.xmax*1000], 'EEG' , 'freq', [4 6 8 10 12 15 18 21 25 28 32 36], 'freqrange',[2 40],'winsize',2^floor(log2(EEG.pnts)),'electrodes','off','percent',80);
    figure; pop_spectopo(EEG, 1, [EEG.xmin*1000  EEG.xmax*1000], 'EEG' , 'freq', [4 6 8 10 12 15 18 21 25 28 32 36], 'freqrange',[2 40],'winsize','512','electrodes','off','percent',100);
    % EEG = pop_saveset( EEG, [file1{1,i}(1:end-4),'ERP.jpg'], 'Q:\N2 CNT and EEG Data\Correct N2 P3\8-MARA\');
    saveas(gcf,[file1{1,i}(1:end-4),'.jpg']);
    % EEG = pop_saveset( EEG, [file1{1,i}(1:7),'BCBEi.set'], 'V:\N2 CNT and EEG Data\Correct N2 P3\7-ICA\');
    %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    %set(gcf, 'Visible', 'off')
    close(gcf)
    close(gcf)
end