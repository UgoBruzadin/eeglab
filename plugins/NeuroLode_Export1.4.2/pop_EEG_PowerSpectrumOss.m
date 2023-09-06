%function [EEG, com] = pop_EEG_PowerSpectrumOss(EEG,COI,AverageChannelsCheck,ExportData,GUIOnOff)
%                      - This function organizes EEG data to uses to use
%                      matlab's spectralSpread and is set-up to view data
%                      in the time domain.
%
%
% Usage:
%   >>  pop_EEG_PowerSpectrumOss(EEG,COI,AverageChannelsCheck,ExportData,GUIOnOff)
%
% Inputs:
%   EEG                           - Input dataset.
%   CoI                           - List of channels to average.
%   AverageChannelsCheck          - If set to 1 will average all epochs Input dataset.
%   ExportData                    - If set to 1 will export file as excel. If this fails will try to save as .dat.
%   HzRange                       - The Hz range of interest
%   GUIOnOff                      - Used to skip GUI inputs if using in another function. If
%                                   GUIOnOff doesn't exsist it will run the GUI
%
%
% Author: Matthew Phillip Gunn
%
% See also:
%   eeglab , spectralSpread

% Copyright (C) 2021  Matthew Gunn, Southern Illinois University Carbondale, neurolode@gmail
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
function [EEG, com] = pop_EEG_PowerSpectrumOss(EEG,COI,AverageChannelsCheck,ExportData,HzRange,GUIOnOff)
com = '';
if nargin < 1
    help pop_EEG_PowerSpectrumOss;
    return;
end

if exist('GUIOnOff') == 0
    %Spectral Spread - Customize
    NumberOfFieldsAndFieldSpace = [.75 1 1];
    Title = { { 'style' 'text' 'string' 'FFT - Power Spectrum Oss. - Must have 3 min of data ' 'fontweight' 'bold' } ...
        {} ...
        {  'style' 'text' 'string' '' } ...
        {  'style' 'text' 'string' '' }};
    Mo1  = { { 'style' 'text' 'string' 'Channels of Interest' } ...
        { 'style' 'edit' 'string',''} ...
        { 'style' 'text' 'string' '' } };
    Mo2  = { { 'style' 'text' 'string' 'Average Channels' } ...
        { 'style' 'checkbox' 'string',''} ...
        { 'style' 'text' 'string' 'Average above channels' } };
    Mo3  = { { 'style' 'text' 'string' 'Export Data' } ...
        { 'style' 'checkbox' 'string',''} ...
        { 'style' 'text' 'string' 'Export as Excel with channels as rows' } };
    Mo4  = { { 'style' 'text' 'string' 'Hz range' } ...
        { 'style' 'edit' 'string',''} ...
        { 'style' 'text' 'string' 'Ex. "[50 60]" range will be 50-60Hz' } };
    allGeom = { 1 NumberOfFieldsAndFieldSpace };
    Title = [ Title(:)' Mo1(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Title = [ Title(:)' Mo2(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Title = [ Title(:)' Mo3(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Title = [ Title(:)' Mo4(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    res = inputgui(allGeom, Title);
    if isempty(res)
        return
    end
    % Formating GUI input for channels for matlab - Start
    COI = strrep(res(1,1),' ',',');
    COI = strrep(COI,' ','');
    Temp = [cellfun(@(cIn) strsplit(cIn,',')',COI,'UniformOutput',false)]';
    COI_Comma1 = [Temp{:}];
    COI_Find_Colon1 =  strfind(COI_Comma1,':');
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
    COI = convertCharsToStrings(COI);
    COI = strrep(COI,' ',',');
    COI = strrep(COI,' ','');
    Temp = [cellfun(@(cIn) strsplit(cIn,',')',COI,'UniformOutput',false)]';
    COI_Comma1 = [Temp{:}];
    COI_Find_Colon1 =  strfind(COI_Comma1,':');
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
end
%%%%%%%%%%%%%% Formatting - Start
COI_List = [];
for ii=1:size(COI_Find_Colon1)
    if COI_Find_Colon1{ii,1} > 0
        TempN1 = [str2double(COI_Comma1{ii,1}(1:(COI_Find_Colon1{ii,1}-1))):str2double(COI_Comma1{ii,1}((COI_Find_Colon1{ii,1}+1):end))]';
        COI_List(((end+1:end+size(TempN1,1))),1) = TempN1;
    else
        COI_List(end+1,1) = str2double(COI_Comma1{ii,1});
    end
end
%%%%%%%%%%%%%% Formatting - End
FFTList = [];UserFreq = [MinHzRange MaxHzRange];ChannelList = COI_List;

if EEG.trials > 1
    EEGout = reshape(EEG , size(EEG.data,1),size(EEG.data,2)*size(EEG.data,3));
    EEGout = eeg_regepochs(EEGout,'recurrence',700/EEGout.srate,'limits',[0 700/EEGout.srate]);
else
   EEGout = eeg_regepochs(EEG,'recurrence',700/EEG.srate,'limits',[0 700/EEG.srate]); 
end
EEGout = pop_resample( EEGout, 366);
if AverageChannelsCheck == 1
    A = EEGout.data(COI_List,:,:);
    EEGout.data = mean(EEGout.data,1);
    COI_List0 = {'Avg Channel'};
else
    EEGout.data = EEGout.data(COI_List,:,:);
    Clabels= {};
    for w=1:size(ChannelList,1)
        Clabels{w,1} = (EEG.chanlocs(ChannelList(w,1)).labels);
    end
end
for i=1:size(EEGout.data,3)
    for iii=1:size(EEGout.data,1)
        [eegspecdB,freqs,compeegspecdB,resvar,specstd] = spectopo(EEGout.data(iii,:,i),EEGout.pnts,EEGout.srate, 'plot', 'off', 'verbose', 'off');
        freqs(freqs<(UserFreq(1,1))) = 0;
        freqs(freqs>(UserFreq(1,2))) = 0;
        UserFreqIdx = find(freqs);
        UserFreqAvg = mean(eegspecdB(1,UserFreqIdx(1,1):UserFreqIdx(end,1)));
        FFTList(iii,1,i) = UserFreqAvg;
        FFTList_Figure(iii,1:25,i) = UserFreqAvg;
    end
end

if exist('GUIOnOff') == 0
    eegplot_SpectrumOss(FFTList_Figure, 'NL_Labels',Clabels)
    sgtitle(strcat('Mean Spectrum per epoch:',string(MinHzRange), ' - ', string(MaxHzRange), ' Hz'))
    FFTList_New = reshape(FFTList , size(FFTList,1),size(FFTList,2)*size(FFTList,3));
    figure;
    [eegspecdB,freqs,compeegspecdB,resvar,specstd] = spectopo(FFTList_New,size(FFTList_New,2), 0.7148, 'winsize', 128);
    sgtitle(strcat('Spectrum Oscillation:',string(MinHzRange), ' - ', string(MaxHzRange), ' Hz'))
else
    FFTList_New = reshape(FFTList , size(FFTList,1),size(FFTList,2)*size(FFTList,3));
    [eegspecdB,freqs,compeegspecdB,resvar,specstd] = spectopo(FFTList_New,size(FFTList_New,2), 0.7148, 'winsize', 128,'plot', 'off', 'verbose', 'off');
end


%Export Data
if ExportData == 1
    t = datestr(now, 'mm_dd_yyyy-HHMM');
    t = string(t);
    t = t(1,1);
    NewEEGlist = [freqs'; eegspecdB]; 
        
    if AverageChannelsCheck == 1
        COI_List0 = {'Avg_'};
    else
        COI_List0 =string('');
    end
    
    for a=1:size(COI_List,1)
        COI_List0 =  strcat(COI_List0,'_', string(COI_List(a,1)));
    end
    Filename = strcat('_PowerSpectrumOsc_', 'Chans',COI_List0);
    Report_Name = strcat(EEG.filename(1:end-4),Filename,'.xlsx');
    try
        g =table(NewEEGlist);
        writetable(g,Report_Name,'WriteVariableNames',false);
    catch
        Report_Name = char(Report_Name);
        Report_Name = strcat(Report_Name(1:end-5),'.dat');
        writecell(NewEEGlist,Report_Name);
        eeglab redraw
    end
end

if exist('GUIOnOff') == 0
    regions = [res(1,1) res(1,2) res(1,3) res(1,4) 1];
    com = sprintf('EEG = pop_EEG_PowerSpectrumOss(EEG,%s);', vararg2str(regions));
end