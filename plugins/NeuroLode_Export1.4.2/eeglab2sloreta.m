% [EEG, com] = eeglab2sloreta( EEG,ListSort,BadChanGUI,GUIOnOff)
%                  - This formats data for use in sLORETA.
%
% Usage:
%   >>  OUTEEG = eeglab2sloreta( EEG,ListSort,BadChanGUI)
% 
%
% Inputs:
%   EEG         - Input dataset.
%   ListSort    - The chacters in the filename to sort into folders.
%   BadChanGUI  - Channels that should be removed from dataset.
%    
% Outputs:
%   OUTEEG     - Output dataset.
%
% Author: Matthew Phillip Gunn 
%
% See also: 
%   pop_select, pop_export, eeglab 

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

function [EEG] = eeglab2sloreta( EEG,ListSort,BadChanGUI)
                         
if nargin < 1   
    help eeglab2sloreta;
    return;
end
Path = pwd;

 % Formating GUI input for channels for matlab - Start   
    COI = strrep(string(ListSort),' ',',');
    Temp = [cellfun(@(cIn) strsplit(cIn,',')',COI,'UniformOutput',false)]';
    COI_Comma1 = [Temp{:}];
    COI_Find_Colon1Sort =  strfind(COI_Comma1,':');
    COI_ListSort = [];
    for ii=1:size(COI_Find_Colon1Sort)
        if COI_Find_Colon1Sort{ii,1} > 0
            TempN1 = [str2double(COI_Comma1{ii,1}(1:(COI_Find_Colon1Sort{ii,1}-1))):str2double(COI_Comma1{ii,1}((COI_Find_Colon1Sort{ii,1}+1):end))]';
            COI_ListSort(((end+1:end+size(TempN1,1))),1) = TempN1;
        else
            COI_ListSort(end+1,1) = str2double(COI_Comma1{ii,1});
        end
    end    
    
    
if mean(BadChanGUI,'all') > 0
    if isempty(BadChanGUI) == 0 %DeletePeripheralChannels.m
        EEG = pop_select( EEG,'nochannel',BadChanGUI); %Change channel list as necessary.
    end
end

    NewFilename = EEG.filename(1:end-4);
    EEG1=EEG;
    for j=1:EEG.trials
        EEG1.data=EEG.data(:,:,j);EEG1.trials=1;
        pop_export(EEG1, [Path '/' NewFilename num2str(j) '.asc'], 'transpose', 'on', 'elec', 'off', 'time', 'off');
    end

cd(Path);
file = dir([EEG1.filename(1:end-6),'*.asc']);
for i=1:length(file)
    f=file(i,1);
    temp(i,1)= cellstr(f.name(COI_ListSort(1,1):COI_ListSort(end,1)));
end
U=unique(temp);
for j=1:length(U)
    fname=sprintf(U{j,1}); %%%%
    mkdir(Path,fname);
end
for k=1:length(file)
    Source=[Path,'/',file(k,1).name];
    Destination=[Path,'/',file(k,1).name(COI_ListSort(1,1):COI_ListSort(end,1)),'/'];
    movefile(Source,Destination,'f');
end
return