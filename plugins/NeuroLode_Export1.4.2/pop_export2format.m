% [EEG, com] = Export2Format( EEG,CoI,GA,AC,TS,FileType,GUIOnOff)
%                      - This function converts data into Excel, DAT, or
%                      txt format. If the file cannot be written as excel
%                      will default to DAT
%
% Usage:
%   >>  OUTEEG = Export2Format( EEG,CoI,GA,AC,TS,FileType,GUIOnOff);
%
% Inputs:
%   EEG         - Input dataset.
%   CoI         - List of channels to average.
%   GA          - If set to 1 will average all epochs Input dataset.
%   AC          - If set to 1 will average all Channels Listed Input dataset.
%   TS          - If set to 1 will add time stamp to output file type.
%   FileType    - Format to export file as.
%   GUIOnOff    - Used to skip GUI inputs if using in another function. If
%                 BadChanGUI doesn't exsist it will run the GUI
%
% Outputs:
%   OUTEEG     - Output dataset.
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

function [EEG, com] = pop_export2format( EEG,CoI,GA,AC,TS,FileType)
com = '';
if nargin < 1
    help Export2Format;
    return;
elseif nargin == 1
    FileType = '.xlsx';
elseif nargin == 2
    FileType = '.dat';
elseif nargin == 3
    FileType = '.txt';
end

NumberOfFieldsAndFieldSpace = [.75 1 1];
Title = { { 'style' 'text' 'string' strcat('Export as', 32, FileType) 'fontweight' 'bold' } ...
    {} ...
    {  'style' 'text' 'string' '' } ...
    {  'style' 'text' 'string' '' }};

C1  = { { 'style' 'text' 'string' 'Channels of interest' } ...
    { 'style' 'edit' 'string' '1:10' } ...
    { 'style' 'text' 'string' 'Ex. "1:10" Will EXpoxt Channels 1 to 10' } };

Mo1  = { { 'style' 'text' 'string' 'Grand Average' } ...
    { 'style' 'checkbox' 'string',''} ...
    { 'style' 'text' 'string' 'Check if you want to Avg epochs' } };

Mo2  = { { 'style' 'text' 'string' 'Average Channels' } ...
    { 'style' 'checkbox' 'string',''} ...
    { 'style' 'text' 'string' 'Check if you want to Avg Channels' } };

Mo4  = { { 'style' 'text' 'string' 'Time Stamp Files' } ...
    { 'style' 'checkbox' 'string',''} ...
    { 'style' 'text' 'string' 'Will Add time to end of filename' } };

allGeom = { 1 NumberOfFieldsAndFieldSpace };
Title = [ Title(:)' C1(:)'];
allGeom{end+1} = NumberOfFieldsAndFieldSpace;
Title = [ Title(:)' Mo1(:)'];
allGeom{end+1} = NumberOfFieldsAndFieldSpace;
Title = [ Title(:)' Mo2(:)'];
allGeom{end+1} = NumberOfFieldsAndFieldSpace;
Title = [ Title(:)' Mo4(:)'];
allGeom{end+1} = NumberOfFieldsAndFieldSpace;

res = inputgui(allGeom, Title);
if isempty(res)
    return
end
CoI = res(1,1);
GA = cell2mat(res(1,2));
AC = cell2mat(res(1,3));
TS = cell2mat(res(1,4));

if isempty(EEG.filename(1:end-4))
%     NumberOfFieldsAndFieldSpace = [.75 1 1];
%     Title = { { 'style' 'text' 'string' 'ERROR Filename is Empty' 'fontweight' 'bold' } {} {  'style' 'text' 'string' '' } {  'style' 'text' 'string' '' }};allGeom = { 1 NumberOfFieldsAndFieldSpace };Title = [ Title(:)'];res = inputgui(allGeom, Title);
    msg = 'Neurolode Error: Filename is Empty. Please Save file with name';error(msg)
end

[EEG] = export2format( EEG,CoI,GA,AC,TS,FileType);

regions = [res(1,1) res(1,2) res(1,3) res(1,4) FileType];
com = sprintf('EEG = export2format(EEG,%s);', vararg2str(regions));