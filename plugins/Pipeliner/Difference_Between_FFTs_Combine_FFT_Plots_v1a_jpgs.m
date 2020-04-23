clc
clear
path1 = pwd;
path2 = strcat(path1, '/12ICL55TEST_Pre'); %Where the Pre Files are located
cd (path2);
filePre1 = dir('*.set');
path3 = strcat(path1, '/12ICL55TEST_Post'); %Where the Post Files are located
cd (path3);
filePost2 = dir('*.set');
cd (path1);

ProcessComparing = ('BSS Effect Test');
FreqList = [12 14 16 20 30]; % Fregs you want to plot
reallimits = [NaN NaN]; % y-axis range for Comparison plot
AbsoluteRelativeMapColor = [NaN NaN]; %[NaN NaN] mean do relative coloring on Topo Maps
maxfreqidx = 100; % x-axis range max
minfreqidx = 0;  % x-axis range min
maxfreqForPreAndPost = 20; % x-axis range max For Pre And Pos plots
minfreqForPreAndPost = -30;  % x-axis range min For Pre And Pos plots

parfor i=1:length(filePre1)
    % For Pre Figure
    EEG1 = pop_loadset( filePre1(i).name, path2);
    [x1, y1] = pop_spectopo(EEG1, 1, [EEG1.xmin*10^3  EEG1.xmax*10^3], 'EEG' , 'freq', FreqList, 'freqrange',[minfreqidx maxfreqidx], 'electrodes','off', 'limits', [0 60 minfreqForPreAndPost maxfreqForPreAndPost NaN NaN]);
    sgtitle(strcat( filePre1(i).name(1:10),' Pre or File1'));
    cd (path2);
    saveas(gcf,[filePre1(i).name 'Pre.jpg'])
    cd (path1);
    saveas(gcf,[num2str(i) 'Pre.jpg'])
    close(gcf)
    
    % For Pre Figure
    EEG2 = pop_loadset(filePost2(i).name, path3);
    [x2, y2] = pop_spectopo(EEG2, 1, [EEG2.xmin*10^3  EEG2.xmax*10^3], 'EEG' , 'freq', FreqList, 'freqrange',[minfreqidx maxfreqidx], 'electrodes','off', 'limits', [0 60 minfreqForPreAndPost maxfreqForPreAndPost NaN NaN]);
    sgtitle(strcat( filePost2(i).name(1:10),' Post or File2'));
    cd (path3);
    saveas(gcf,[filePost2(i).name 'Post.jpg'])
    cd (path1);
    saveas(gcf,[num2str(i) 'Post.jpg'])
    close(gcf)
    
    % For Pre Minus Post Figure
    xDETLA = x1 - x2;
    EEGChanLocation = EEG1.chanlocs;
    pipe_spectopo(xDETLA,FreqList,reallimits, AbsoluteRelativeMapColor, minfreqidx, maxfreqidx, EEGChanLocation)
    sgtitle('Pre Minus Post or File1 Minus File2');
    saveas(gcf,[num2str(i) 'PreMinusPost.jpg'])
    close(gcf)
    
    % For Combining Images
    out = imtile({strcat(num2str(i),'Pre.jpg'), strcat(num2str(i),'Post.jpg'), strcat(num2str(i),'PreMinusPost.jpg')});
    imshow(out);
    sgtitle(ProcessComparing);
    saveas(gcf,[filePre1(i).name(1:10),'_',filePost2(i).name(1:10), num2str(i),'_Pre_vs_POST.jpg']);
    delete (strcat(num2str(i),'Pre.jpg'), strcat(num2str(i),'Post.jpg'), strcat(num2str(i),'PreMinusPost.jpg'));
    
    close all
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%Below this line is and edited Function for specoto.m%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
