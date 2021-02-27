clc
clear
path1 = uigetdir('1. select directory to save images'); %Where the Post Files are located
[filePre1,path2] = uigetfile('.set','2. select files PRE', 'MultiSelect', 'on');
[filePost2,path3] = uigetfile('.set','3. select files POST', 'MultiSelect', 'on'); %Where the Pre Files are located
%cd (path2);
%filePre1 = dir('*.set');
%cd (path3);
%filePost2 = dir('*.set');
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
function FFT_Difference(xDETLA,FreqList,reallimits, AbsoluteRelativeMapColor, minfreqidx, maxfreqidx, EEGChanLocation)
%FreqList = [12 14 16 20 30];
freqidx = FreqList;
%xDETLA = xDETLA';
eegspecdB = xDETLA;
%reallimits = [-30 10];
%AbsoluteRelativeMapColor = [NaN NaN]; %[NaN NaN] mean do relative coloring on Topo Maps
AXES_FONTSIZE_L = 12.5;
PLOT_LINEWIDTH_S = .5;
freqs =[0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34;35;36;37;38;39;40;41;42;43;44;45;46;47;48;49;50;51;52;53;54;55;56;57;58;59;60;61;62;63;64;65;66;67;68;69;70;71;72;73;74;75;76;77;78;79;80;81;82;83;84;85;86;87;88;89;90;91;92;93;94;95;96;97;98;99;100;101;102;103;104;105;106;107;108;109;110;111;112;113;114;115;116;117;118;119;120;121;122;123;124;125;126;127;128;129;130;131;132;133;134;135;136;137;138;139;140;141;142;143;144;145;146;147;148;149;150;151;152;153;154;155;156;157;158;159;160;161;162;163;164;165;166;167;168;169;170;171;172;173;174;175;176;177;178;179;180;181;182;183;184;185;186;187;188;189;190;191;192;193;194;195;196;197;198;199;200;201;202;203;204;205;206;207;208;209;210;211;212;213;214;215;216;217;218;219;220;221;222;223;224;225;226;227;228;229;230;231;232;233;234;235;236;237;238;239;240;241;242;243;244;245;246;247;248;249;250];
%maxfreqidx = 46;
%minfreqidx = 13;
range = [minfreqidx maxfreqidx];
limits = [minfreqidx maxfreqidx reallimits(1) reallimits(2) AbsoluteRelativeMapColor(1) AbsoluteRelativeMapColor(2)];
%varargin =['fregs' FreqList 'freqrange' range 'electrodes' 'off' 'limits' limits 'verbose' 'off' 'chanlocs' EEG.chanlocs 'chaninfo'];
figure;
allcolors = { [0 0.7500 0.7500]
    [1 0 0]
    [0 0.5000 0]
    [0 0 1]
    [0.2500 0.2500 0.2500]
    [0.7500 0.7500 0]
    [0.7500 0 0.7500] }; % colors from real plots

mainfig = gca; axis off;
specaxes = sbplot(3,4,[5 12], 'ax', mainfig);
specdata = eegspecdB; %This will be difference
for index = 1:size(specdata,1) % scan channels
    tmpcol  = allcolors{mod(index, length(allcolors))+1};
    command = [ 'disp(''Channel ' int2str(index) ''')' ];
    pl(index)=plot(freqs(1:maxfreqidx),specdata(index,1:maxfreqidx)',...
        'color', tmpcol, 'ButtonDownFcn', command);
    hold on;
end
set(pl,'LineWidth',2);
set(gca,'TickLength',[0.02 0.02]);
try
    axis([freqs(minfreqidx) freqs(maxfreqidx) reallimits(1) reallimits(2)]);
catch
    disp('Could not adjust axis');
end
xl=xlabel('Frequency (Hz)');
set(xl,'fontsize',AXES_FONTSIZE_L);
% yl=ylabel('Rel. Power (dB)');
yl=ylabel('Log Power Spectral Density 10*log_{10}(\muV^{2}/Hz)');%yl=ylabel('Power 10*log_{10}(\muV^{2}/Hz)');
set(yl,'fontsize',AXES_FONTSIZE_L);
set(gca,'fontsize',AXES_FONTSIZE_L)
box off;
colrs = {'r','b','g','m','c'}; % component spectra trace colors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot vertical lines through channel trace bundle at each headfreq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for f=1:length(FreqList)
    hold on;
    plot([(freqs(freqidx(f))+1) (freqs(freqidx(f))+1)], ...
        [min(eegspecdB(:,freqidx(f))) max(eegspecdB(:,freqidx(f)))],...
        'k','LineWidth',2.5);
end
tmpmainpos = get(gca, 'position');
headax = zeros(1,length(FreqList));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot windows of ToPlot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for f=1:length(FreqList)
    headax(f) = sbplot(3,length(FreqList),f, 'ax', mainfig);
    axis([-1 1 -1 1]);
    %axis x coords and use
    tmppos = get(headax(f), 'position');
    allaxcoords(f) = tmppos(1);
    allaxuse(f)    = 0;
end
large = sbplot(1,1,1, 'ax', mainfig);
realpos = 1:length(FreqList); % indices giving order of plotting positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot connecting lines using changeunits()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for f=1:length(FreqList)
    from = changeunits([freqs(freqidx(f)),max(eegspecdB(:,freqidx(f)))],specaxes,large);
    
    pos = get(headax(realpos(f)),'position');
    to = changeunits([0,0],headax(realpos(f)),large)+[0 -min(pos(3:4))/2.5];
    hold on;
    if f<=length(FreqList)
        colr = 'k';
    else
        colr = colrs{mod((f-2),5)+1};
    end
    
    li(realpos(f)) = plot([from(1) to(1)],[from(2) to(2)],colr,'LineWidth',PLOT_LINEWIDTH_S);
    axis([0 1 0 1]);
    axis off;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot selected channel head using topoplot()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for f=1:length(FreqList)
    axes(headax(realpos(f)));
    
    topodata = eegspecdB(:,freqidx(f))-nan_mean(eegspecdB(:,freqidx(f)));
    
    if isnan(limits(5))
        maplimits = 'absmax';
    else
        maplimits = [limits(5) limits(6)];
    end
    %        A = string(cat(2,{EEG.chanlocs.urchan}));
    %        A = str2double(A);
    A = 1:size(eegspecdB,1);
    topoplot(topodata(A),EEGChanLocation,'maplimits',maplimits, 'electrodes','off'); %, varargin{:});
    
    if f<(length(FreqList)+1)
        tl=title([num2str(freqs(freqidx(f)+1), '%3.1f')]);
    end
    set(tl,'fontsize',AXES_FONTSIZE_L);
    axis square;
    drawnow
    %myfprintf(g.verbose, '.');
end
disp('Click on each trace for channel/component index');
axcopy(gcf, 'if ~isempty(get(gca, ''''userdata'''')), eval(get(gca, ''''userdata'''')); end;');


cb=cbar;
pos = get(cb,'position');
set(cb,'position',[pos(1) pos(2) 0.03 pos(4)]);
set(cb,'fontsize',12);
try
    if isnan(g.limits(5))
        ticks = get(cb,'ytick');
        [tmp. zi] = find(ticks == 0);
        ticks = [ticks(1) ticks(zi) ticks(end)];
        set(cb,'ytick',ticks);
        set(cb,'yticklabel',strvcat('-',' ','+'));
    end
catch
end

%sgtitle('Pre Minus Post or LeftFigure Minus MiddleFigure', 'position',[1 1])
end