% Export2Format( EEG,CoI,GA,AC,TS,FileType,GUIOnOff)
%                      - This function converts data into Excel, DAT, or
%                      txt format. If the file cannot be written as excel
%                      will default to DAT
%
% Usage:
%   >>  Export2Format( EEG,CoI,GA,AC,TS,FileType,GUIOnOff);
%
% Inputs:
%   EEG         - Input dataset.
%   CoI         - List of channels to average.
%   GA          - If set to 1 will average all epochs Input dataset.
%   AC          - If set to 1 will average all Channels Listed Input dataset.
%   TS          - If set to 1 will add time stamp to output file type.
%   FileType    - Format to export file as.
%    
%
% Author: Matthew Phillip Gunn 
%
% See also: 
%   eeglab 

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

function [EEG] = export2format( EEG,CoI,GA,AC,TS,FileType)
% Formating GUI input for channels for matlab - Start
CoI = strrep(CoI,' ',',');
CoI = strrep(CoI,' ','');
Temp = [cellfun(@(cIn) strsplit(cIn,',')',CoI,'UniformOutput',false)]';
COI_Comma1 = [Temp{:}];
COI_Find_Colon1 =  strfind(COI_Comma1,':');
% Formating GUI input for channels for matlab - End

% Start of process
COI_List = [];
for ii=1:size(COI_Find_Colon1)
    if COI_Find_Colon1{ii,1} > 0
        TempN1 = [str2double(COI_Comma1{ii,1}(1:(COI_Find_Colon1{ii,1}-1))):str2double(COI_Comma1{ii,1}((COI_Find_Colon1{ii,1}+1):end))]';
        COI_List(((end+1:end+size(TempN1,1))),1) = TempN1;
    else
        COI_List(end+1,1) = str2double(COI_Comma1{ii,1});
    end
end


DataSheet0 = EEG.data(COI_List,:,:); %Data of Interest
if GA ==1 && AC ==1
    DataSheet0 = mean(DataSheet0,3);
    DataSheet0 = mean(DataSheet0,1);
    RunningHeaderTime = (EEG.xmin:(abs(EEG.xmax)+abs(EEG.xmin))/EEG.pnts:EEG.xmax);
    RunningHeaderTime = {'Filename' num2cell(RunningHeaderTime(1:end-1))};
    RunningHeaderTime =[RunningHeaderTime{:}];
    TEMPa ='AvgChans';
    for ia=1:size(COI_List,1)
        TEMPa = strcat(TEMPa,'_',string(COI_List(ia,1)));
    end
    TEMPab = strcat(EEG.filename(1:end-4),'_',TEMPa);
    RunningFilename = {TEMPab num2cell(DataSheet0)};
    RunningFilename =[RunningFilename{:}];
    DataSheet1 = [RunningHeaderTime; RunningFilename];   
elseif GrandAverageCheck == 1 %For epochs
    DataSheet0 = mean(DataSheet0,3);
    RunningHeaderTime = (EEG.xmin:(abs(EEG.xmax)+abs(EEG.xmin))/EEG.pnts:EEG.xmax);
    RunningHeaderTime = {'Channel#_DataSet' num2cell(RunningHeaderTime(1:end-1))};
    RunningHeaderTime =[RunningHeaderTime{:}];
    COI_List0 = cellfun(@(c)[c strcat('_Chan_',EEG.filename(1:end-4))],string(COI_List),'uni',false);
    DataSheet0a = {COI_List0 num2cell(DataSheet0)};
    DataSheet0a = [DataSheet0a{:}];
    DataSheet1 = [RunningHeaderTime;DataSheet0a];
    TEMPa ='Chans';
    for ia=1:size(COI_List,1)
        TEMPa = strcat(TEMPa,'_',string(COI_List(ia,1)));
    end
    TEMPab = strcat(EEG.filename(1:end-4),'_',TEMPa);
elseif AverageChannelsCheck == 1 %For channels
    DataSheet0 = mean(DataSheet0,1);
    DataSheet0 = reshape(DataSheet0 , size(DataSheet0,1),size(DataSheet0,2)*size(DataSheet0,3));
    RunningHeaderTime = (EEG.xmin:(abs(EEG.xmax)+abs(EEG.xmin))/EEG.pnts:EEG.xmax);
    RunningHeaderTime = num2cell(RunningHeaderTime(1:end-1));
    RunningHeaderTime = repmat(RunningHeaderTime,1,EEG.trials);
    RunningHeaderTime = {'Channels_DataSet ' RunningHeaderTime};
    RunningHeaderTime =[RunningHeaderTime{:}];
    TEMPa ='AvgChans';
    for ia=1:size(COI_List,1)
        TEMPa = strcat(TEMPa,'_',string(COI_List(ia,1)));
    end
    TEMPab = strcat(EEG.filename(1:end-4),'_',TEMPa);
    RunningFilename = {TEMPab num2cell(DataSheet0)};
    RunningFilename =[RunningFilename{:}];
    DataSheet1 = [RunningHeaderTime; RunningFilename];
else
    if EEG.trials > 1
        DataSheet0 = reshape(DataSheet0 , size(DataSheet0,1),size(DataSheet0,2)*size(DataSheet0,3));
    end
    RunningHeaderTime = (EEG.xmin:(abs(EEG.xmax)+abs(EEG.xmin))/EEG.pnts:EEG.xmax);
    RunningHeaderTime = num2cell(RunningHeaderTime(1:end-1));
    RunningHeaderTime = repmat(RunningHeaderTime,1,EEG.trials);
    RunningHeaderTime = {'Channel#_DataSet' num2cell(RunningHeaderTime(1:end))};
    RunningHeaderTime =[RunningHeaderTime{:}];
    COI_List0 = cellfun(@(c)[c strcat('_Chan_',EEG.filename(1:end-4))],string(COI_List),'uni',false);
    DataSheet0a = {COI_List0 num2cell(DataSheet0)};
    DataSheet0a = [DataSheet0a{:}];
    DataSheet1 = [RunningHeaderTime;DataSheet0a];
    TEMPa ='Chans';
    for ia=1:size(COI_List,1)
        TEMPa = strcat(TEMPa,'_',string(COI_List(ia,1)));
    end
    TEMPab = strcat(EEG.filename(1:end-4),'_',TEMPa);
end


if TS == 1 
    t = datestr(now, 'mm_dd_yyyy-HHMM');
    t = string(t);
    t = t(1,1);
    Report_Name = strcat(EEG.filename(1:end-4),'_',TEMPa,'_',t);  
else
    Report_Name = strcat(EEG.filename(1:end-4),'_',TEMPa);  
end


try
    g = table(DataSheet1);
    Report_Name = char(Report_Name);
    Report_Name0 = strcat(Report_Name,FileType);
    writetable(g,Report_Name0,'WriteVariableNames',false);
catch
    Report_Name = char(Report_Name);
    Report_Name0 = strcat(Report_Name,'.dat');
    writetable(g,Report_Name);    
end
return
 


