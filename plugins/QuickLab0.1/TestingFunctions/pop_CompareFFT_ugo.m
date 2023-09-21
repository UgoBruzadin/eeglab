%function [EEG, com] = pop_CompareFFT(EEG2,EEG1,COI,AverageChannelsCheck,ExportData,HzRange,GUIOnOff)
%                      - This function Subtract the FFTs of EEG1 from EEG2.
%                      C = EEG2 - EEG2. It will also export these difference
%                      if the user desires.
%
%
% Usage:
%   >>  pop_CompareFFT(EEG2,EEG1,COI,AverageChannelsCheck,ExportData,HzRange,GUIOnOff)
%
% Inputs:
%   EEG2                          - Input dataset.
%   EEG1                          - Input dataset to subtract from EEG2.
%   COI                           - List of channels to average.
%   AverageChannelsCheck          - If set to 1 will average all Channels listed in COI.
%   ExportData                    - If set to 1 will export file as excel. If this fails will try to save as .dat.
%   HzRange                       - The Hz range of interest for plots
%   GUIOnOff                      - Used to skip GUI inputs if using in another function. If
%                                   GUIOnOff doesn't exsist it will run the GUI
%
%
% Author: Matthew Phillip Gunn
%
% See also:
%   eeglab , inputgui, supergui, spectopo

% Copyright (C) 2021  Matthew Gunn, Southern Illinois University Carbondale, neurolode@gmail.com
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.
function [EEG, com] = pop_CompareFFT_ugo(EEG2,EEG1,COI,AverageChannelsCheck,ExportData,HzRange,GUIOnOff)

com = '';
if nargin < 1
    help pop_CompareFFT;
    return;
end

if exist('GUIOnOff') == 0   
global file1 Path1 file2 Path2
    commandloadA = [ 'global file1 Path1 file2 Path2;',...
                    '[file1 Path1]=uigetfile(''*.set'',''Multiselect'',''ON'');'];
    commandloadB = [ 'global file1 Path1 file2 Path2;',...
                    '[file2 Path2]=uigetfile(''*.set'',''Multiselect'',''ON'');'];
   uilist = { { 'style' 'text' 'string' 'FFT - Power Spectrum Difference: C = B - A; File(s) must be the same sampling rate' 'fontweight' 'bold' },...
              {'style' 'text' 'string' 'File(s) to Compare: A in top equation ' }, ...
              { 'style' 'pushbutton' 'string' 'Browse' 'callback' commandloadA },...
              {},...
              { 'style' 'text' 'string' 'File(s) to Compare: B in top equation ' }, ...
              { 'style' 'pushbutton' 'string' 'Browse' 'callback' commandloadB },...  
              {},...
              { 'style' 'text' 'string' 'Channels of Interest'} , ...
              { 'style' 'edit' 'string' '' }, ...
              { 'style' 'text' 'string' 'Ex 1:10 15 20:25'}, ...
              { 'style' 'text' 'string' 'Average Channels'} , ...
              { 'style' 'checkbox' 'string',''} ...
              { 'style' 'text' 'string' 'Average above channels' }, ...
              { 'style' 'text' 'string' 'Export Data' }, ...
              { 'style' 'checkbox' 'string',''}, ...
              { 'style' 'text' 'string' 'Export Diff as Excel with channels as rows' }, ...
              { 'style' 'text' 'string' 'Hz range' }, ...
              { 'style' 'edit' 'string',''}, ...
              { 'style' 'text' 'string' 'Ex. "[50 60]" range will be 50-60Hz' },...
              };   
   uigeom = { [.75] [.75 1 1] [.75 1 1] [.75 1 1] [.75 1 1] [.75 1 1] [.75 1 1]};
   res = inputgui( uigeom, uilist, '', 'Neurolode - Compare' );
  
    % Formating GUI input for channels for matlab - Start
    if ~isempty(res(1,1))
        COI = strrep(res(1,1),' ',',');
        COI = strrep(COI,' ','');
        
        Temp = [cellfun(@(cIn) strsplit(cIn,',')',COI,'UniformOutput',false)]';
        COI_Comma1 = [Temp{:}];
        COI_Find_Colon1 =  strfind(COI_Comma1,':');
    end
    % Formating GUI input for channels for matlab - End
    AverageChannelsCheck = cell2mat(res(1,2));
    ExportData = cell2mat(res(1,3));
    res0 = strrep(res(1,4),'[','');
    res0 = strrep(res0,']','');
    Temp = [cellfun(@(cIn) strsplit(cIn,' ')',res0,'UniformOutput',false)]';
    T0 = ([Temp{:}]');
    MaxHzRange = str2double(T0(1,2));
    MinHzRange = str2double(T0(1,1));
else
%     COI = convertCharsToStrings(COI);
%     COI = strrep(COI,' ',',');
%     COI = strrep(COI,' ','');
%     Temp = [cellfun(@(cIn) strsplit(cIn,',')',COI,'UniformOutput',false)]';
%     COI_Comma1 = [Temp{:}];
%     COI_Find_Colon1 =  strfind(COI_Comma1,':');
    % Formating GUI input for channels for matlab - End
    AverageChannelsCheck = AverageChannelsCheck;
    ExportData = ExportData;
    res0 = convertCharsToStrings(HzRange);
    res0 = strrep(HzRange,'[','');
    res0 = strrep(res0,']','');
    res0 = convertCharsToStrings(res0);
    Temp = [cellfun(@(cIn) strsplit(cIn,' ')',res0,'UniformOutput',false)]';
    T0 = ([Temp{:}]');
    MaxHzRange = str2double(T0(1,2));
    MinHzRange = str2double(T0(1,1));
%     Path1 = FilePath1;
%     Path2 = FilePath2;
end

%%%%%%%%%%%%%% Formatting - Start
% COI_List = [];
% for ii=1:size(COI_Find_Colon1)
%     if COI_Find_Colon1{ii,1} > 0
%         TempN1 = [str2double(COI_Comma1{ii,1}(1:(COI_Find_Colon1{ii,1}-1))):str2double(COI_Comma1{ii,1}((COI_Find_Colon1{ii,1}+1):end))]';
%         COI_List(((end+1:end+size(TempN1,1))),1) = TempN1;
%     else
%         COI_List(end+1,1) = str2double(COI_Comma1{ii,1});
%     end
% end
UserFreq = [MinHzRange MaxHzRange];ChannelList = COI_List;

if exist('GUIOnOff') == 0  
if size(file1,2) > 1 && iscell(file1)
    file1 = file1';
else
    file1 = {file1};
end
if size(file2,2) > 1 && iscell(file2)
    file2 = file2';
else
    file2 = {file2};
end

temp = pwd;
cd(Path1);[~,nameA,~]=fileparts(pwd);
cd(Path2);[~,nameB,~]=fileparts(pwd);
cd(temp)
%%%%%%%%%%%%%% Formatting - End
for i=1:length(file1)
    
    EEG = pop_loadset(file1(i), Path1,  'all','all','all','all','auto');
    
    if isempty(res{1,1}) && i == 1
        COI_List = [1:EEG.nbchan];
    end
    
    if AverageChannelsCheck == 1
        Ao = EEG.data(COI_List,:,:);
        EEGout = mean(Ao, 1);
        [eegspecdA,freqs,compeegspecdB,resvar,specstd] = spectopo(EEGout,EEG.pnts,EEG.srate, 'plot', 'off', 'verbose', 'off');
    else
        [eegspecdA,freqs,compeegspecdB,resvar,specstd] = spectopo(EEG.data,EEG.pnts,EEG.srate, 'plot', 'off', 'verbose', 'off');
    end
    
    A(:,:,i) = eegspecdA;
end
A1 = mean(A,3);

B =[];
for i=1:length(file2)
    EEG = pop_loadset(file2(i), Path2,  'all','all','all','all','auto');
    
    if isempty(res{1,1}) && i == 1
        COI_List = [1:EEG.nbchan];
    end
    if AverageChannelsCheck == 1
        Ao = EEG.data(COI_List,:,:);
        EEGout = mean(Ao, 1);
        [eegspecdB,freqs,compeegspecdB,resvar,specstd] = spectopo(EEGout,EEG.pnts,EEG.srate, 'plot', 'off', 'verbose', 'off');
    else
        [eegspecdB,freqs,compeegspecdB,resvar,specstd] = spectopo(EEG.data,EEG.pnts,EEG.srate, 'plot', 'off', 'verbose', 'off');
    end
    
    B(:,:,i) = eegspecdB;
end
B1 = mean(B,3);
C1 = abs(B1) - abs(A1);

else
    if isempty(COI_List)
        COI_List = [1:EEG.nbchan];
    end
    if AverageChannelsCheck == 1
        Ao = EEG.data(COI_List,:,:);
        EEGout = mean(Ao, 1);
        [eegspecdA,freqs,compeegspecdB,resvar,specstd] = spectopo(EEGout,EEG.pnts,EEG.srate, 'plot', 'off', 'verbose', 'off');
    else
        [eegspecdA,freqs,compeegspecdB,resvar,specstd] = spectopo(EEG.data,EEG.pnts,EEG.srate, 'plot', 'off', 'verbose', 'off');
    end
    A(:,:,:) = eegspecdA;
    A1 = mean(A,3);
    
    B =[];
    if isempty(COI_List)
        COI_List = [1:EEG.nbchan];
    end
    if AverageChannelsCheck == 1
        Ao = EEG.data(COI_List,:,:);
        EEGout = mean(Ao, 1);
        [eegspecdB,freqs,compeegspecdB,resvar,specstd] = spectopo(EEGout,EEG.pnts,EEG.srate, 'plot', 'off', 'verbose', 'off');
    else
        [eegspecdB,freqs,compeegspecdB,resvar,specstd] = spectopo(EEG.data,EEG.pnts,EEG.srate, 'plot', 'off', 'verbose', 'off');
    end
    B(:,:,:) = eegspecdB;
    B1 = mean(B,3);
    C1 = abs(B1) - abs(A1);
end
   

if exist('GUIOnOff') == 0
    %%%% Plotting - This is modified code from spectopo.m plot function
    UserFreq = [2 40];
    [tmp, maxfreqidx] = min(abs(UserFreq(1,2)-freqs)); % adjust max frequency
    [tmp, minfreqidx] = min(abs(UserFreq(1,1)-freqs)); % adjust min frequency
    reallimits(1) = min(min(C1(:,minfreqidx:maxfreqidx)));
    reallimits(2) = max(max(C1(:,minfreqidx:maxfreqidx)));
    dBrange = reallimits(2)-reallimits(1);   % expand range a bit beyond data g.limits
    reallimits(1) = reallimits(1)-dBrange/7;
    reallimits(2) = reallimits(2)+dBrange/7;
    Nodiff = 0;
    if sum(reallimits) == 0
        reallimits(1) = -1;
        reallimits(2) = 1;
        Nodiff = 1;
    end
    
    figure;
    mainfig = gca;
    axis off;
    allcolors = { [0 0.7500 0.7500]
        [1 0 0]
        [0 0.5000 0]
        [0 0 1]
        [0.2500 0.2500 0.2500]
        [0.7500 0.7500 0]
        [0.7500 0 0.7500] }; % colors from real plots                };
    for index = 1:size(C1,1) % scan channels
        tmpcol  = allcolors{mod(index, length(allcolors))+1};
        command = [ 'disp(''Channel ' int2str(index) ''')' ];
        pl(index)=plot(freqs(1:(EEG.srate/2)),C1(index,1:(EEG.srate/2))', ...
            'color', tmpcol, 'ButtonDownFcn', command); hold on;
    end
    set(pl,'LineWidth',2);
    set(gca,'TickLength',[0.02 0.02]);
    xl=xlabel('Frequency (Hz)');
    axis([freqs(minfreqidx) freqs(maxfreqidx) reallimits(1) reallimits(2)]);
    set(xl,'fontsize',12);
    yl=ylabel('Log Power Spectral Density 10*log_{10}(\muV^{2}/Hz)');%yl=ylabel('Power 10*log_{10}(\muV^{2}/Hz)');
    set(yl,'fontsize',12);
    set(gca,'fontsize',12)
    sgtitle(strcat('FFT Subtraction: C = B - A; Shaded = alpha < 0.05 '))

    
    % Two Sample T-test
    TSTT = [];
    for TSTT0=1:size(A,2)
        A_TTestData = A(1,TSTT0,1:end);
        B_TTestData = B(1,TSTT0,1:end);
        [h,p,ci,stats] = ttest(B_TTestData,A_TTestData,'Alpha',0.05);
        TSTT(1,TSTT0) = p;
    end
    TSTT = TSTT(1:end-1);
    TSTT2 = (TSTT >= 0.0) & (TSTT <= 0.05); %(TSTT<=(0.55)) = 1;
    x0 = freqs(1:(EEG.srate/2))';
    y0 = C1(index,1:(EEG.srate/2));
    %patch([x0(TSTT2) fliplr(x0(TSTT2))], [y0(TSTT2) zeros(size(y0(TSTT2)))], 'g', 'FaceAlpha', 0.5)
    %patch([x(lidx) fliplr(x(lidx))], [y1(lidx), fliplr(y2(lidx))], 'g', 'FaceAlpha', 0.5)
    idxX =[0];
    idxY = [0];
    for iA=1:size(TSTT2,2)
        if TSTT2(1,iA) == 1
            idxY(1,iA+1) = y0(1,iA);
            idxX(1,iA+1) = x0(1,iA);
        else
            idxY(1,iA+1) = NaN;
            idxX(1,iA+1) = x0(1,iA);
        end
    end
     area(idxX,idxY,'EdgeColor', 'none', 'FaceColor', [.7 .7 .7],'LineStyle', 'none');
%     for iA = 1:size(TSTT2,2)
%         if TSTT2(1,iA) == 1
%             for iA0=iA:size(TSTT2,2)                
%                 if TSTT2(1,iA) == 0
%                     patch([x0(1,iA:iA0) fliplr(x0(1,iA:iA0))], [y0(1,iA:iA0) zeros(size(y0(1,iA:iA0)))], 'g', 'FaceAlpha', 0.5)
%                     break
%                 end                
%                 if iA0 == size(TSTT2,2)
%                     break
%                 end
%             end
%         end
%     end    
    hold off
    

    
    figure;
    mainfig = gca;
    axis off;
    allcolors = { [0 0.7500 0.7500]
        [1 0 0]
        [0 0.5000 0]
        [0 0 1]
        [0.2500 0.2500 0.2500]
        [0.7500 0.7500 0]
        [0.7500 0 0.7500] }; % colors from real plots                };
    for index = 1:size(A1,1) % scan channels
        tmpcol  = allcolors{mod(index, length(allcolors))+1};
        command = [ 'disp(''Channel ' int2str(index) ''')' ];
        pl(index)=plot(freqs(1:(EEG.srate/2)),A1(index,1:(EEG.srate/2))', ...
            'color', tmpcol, 'ButtonDownFcn', command); hold on;
    end
    set(pl,'LineWidth',2);
    set(gca,'TickLength',[0.02 0.02]);
    xl=xlabel('Frequency (Hz)');
    %if Nodiff == 1
    [tmp, minfreqidx] = min(abs(UserFreq(1,1)-freqs)); % adjust min frequency
    reallimits(1) = min(min(A1(:,minfreqidx:maxfreqidx)));
    reallimits(2) = max(max(A1(:,minfreqidx:maxfreqidx)));
    dBrange = reallimits(2)-reallimits(1);   % expand range a bit beyond data g.limits
    reallimits(1) = reallimits(1)-dBrange/7;
    reallimits(2) = reallimits(2)+dBrange/7;
    % end
    axis([freqs(minfreqidx) freqs(maxfreqidx) reallimits(1) reallimits(2)]);
    set(xl,'fontsize',12);
    yl=ylabel('Log Power Spectral Density 10*log_{10}(\muV^{2}/Hz)');%yl=ylabel('Power 10*log_{10}(\muV^{2}/Hz)');
    set(yl,'fontsize',12);
    set(gca,'fontsize',12)
    sgtitle(strcat('FFT Subtraction; A plot '))
    
    figure;
    mainfig = gca;
    axis off;
    allcolors = { [0 0.7500 0.7500]
        [1 0 0]
        [0 0.5000 0]
        [0 0 1]
        [0.2500 0.2500 0.2500]
        [0.7500 0.7500 0]
        [0.7500 0 0.7500] }; % colors from real plots                };
    for index = 1:size(B1,1) % scan channels
        tmpcol  = allcolors{mod(index, length(allcolors))+1};
        command = [ 'disp(''Channel ' int2str(index) ''')' ];
        pl(index)=plot(freqs(1:(EEG.srate/2)),B1(index,1:(EEG.srate/2))', ...
            'color', tmpcol, 'ButtonDownFcn', command); hold on;
    end
    set(pl,'LineWidth',2);
    set(gca,'TickLength',[0.02 0.02]);
    xl=xlabel('Frequency (Hz)');
    axis([freqs(minfreqidx) freqs(maxfreqidx) reallimits(1) reallimits(2)]);
    % if Nodiff == 1
    [tmp, minfreqidx] = min(abs(UserFreq(1,1)-freqs)); % adjust min frequency
    reallimits(1) = min(min(B1(:,minfreqidx:maxfreqidx)));
    reallimits(2) = max(max(B1(:,minfreqidx:maxfreqidx)));
    dBrange = reallimits(2)-reallimits(1);   % expand range a bit beyond data g.limits
    reallimits(1) = reallimits(1)-dBrange/7;
    reallimits(2) = reallimits(2)+dBrange/7;
    % end
    set(xl,'fontsize',12);
    yl=ylabel('Log Power Spectral Density 10*log_{10}(\muV^{2}/Hz)');%yl=ylabel('Power 10*log_{10}(\muV^{2}/Hz)');
    set(yl,'fontsize',12);
    set(gca,'fontsize',12)
    sgtitle(strcat('FFT Subtraction; B plot '))
end


%Export Data
if ExportData == 1
    t = datestr(now, 'mm_dd_yyyy-HHMM');
    t = string(t);
    t = t(1,1);
    NewEEGlist = [freqs'; C1];
    
    if isempty(res{1,1})
        COI_List0 = 'AllChan';
    end
    
    if AverageChannelsCheck == 1
        COI_List0 = {'AvgChan_'};
        if isempty(res{1,1})
            COI_List0 = 'AllChanAvg';
        end
    else
        COI_List0 =string('');
    end
    %COI_List = COI_List';
    for a=1:size(COI_List,1)
        COI_List0 =  strcat(COI_List0,'_', string(COI_List(a,1)));
    end
    
    if size(file1,1) > 1
        Filename = strcat('_FFTDiff_', COI_List0);
        Report_Name = strcat(nameB,'-',nameA, Filename,'.xlsx');
    else
        Filename = strcat('_FFTDiff_', COI_List0);
        T1 =char(file1);
        T2 =char(file2);
        Report_Name = strcat(T2(1:end-4),'_Minus_',T1(1:end-4), Filename,'.xlsx');
        Report_NameTest = strcat(pwd,'\',Report_Name);
        if strlength(Report_NameTest) > 250
            Report_Name = strcat(Report_Name(1:15),'_NameTruncated_',Report_Name(end-10:end));
        end
    end
    try
        g =table(NewEEGlist);
        writetable(g,Report_Name,'WriteVariableNames',false);
    catch
        Report_Name = char(Report_Name);
        Report_Name = strcat(Report_Name(1:end-5),'.dat');
        try
            writecell(NewEEGlist,Report_Name);
        catch
            writematrix(NewEEGlist,Report_Name);
        end
        %eeglab redraw
    end
end

if exist('GUIOnOff') == 0
    regions = [res(1,1) res(1,2) res(1,3) res(1,4) 1];
    com = sprintf('EEG = pop_CompareFFT(EEG2,EEG1,%s);', vararg2str(regions));   
end
clear file1
clear file2
clear Path1
clear Path2
