% parsetobii() - parse Tobii eye tracking data from an ASCII text-file and
% save the content as a MATLAB structure
%
% Note: this is an early Beta version
%
% Usage:
%   >>  et = parsetobii(inputFile, outputMatFile, triggerKeyword);
%
% Inputs:
%   inputFile      - path to text file containing the raw ET recording
%                    This text file was generated by software from Tobii
%                    (e.g. "Tobii Studio Pro") or using one of the Tobii
%                    SDKs (for example for Matlab or Python).
%                    Note: If this textfile was generated by the user using
%                    an SDK, its format needs to conform to certain
%                    specifications (e.g. with regard to column names).
%                    These specs are documented on the EYE-EEG homepage.
%
%   outputMatFile  - name of MATLAB (.mat) file to save "et" structure in
%
% Optional Inputs:
%   triggerKeyword - keyword contained in special messages used for
%                    synchronization. Text messages can be used as an
%                    alternative method for synchronization with the
%                    EEG (instead of shared trigger pulses). However,
%                    all messages used for synchronization must contain a
%                    special keyword string (e.g. "MYKEYWORD") which is
%                    followed by the respective integer number (e.g. "123")
%                    which is also send as a trigger puls eto the parallel
%                    electrophysiological recording.
%
%                    IMPORTANT: The variable (=column of text file) that
%                    contains these special message must be named
%                    "Event messages".
%
%                    Alternatively, the toolbox will look for data in a
%                    column named "Event value". This column contains values 
%                    send to the Tobii eye tracker via the parallel port
%
% NOTE ON THE TOBII FORMAT FOR TEXT DATA: 
% Tobii text data *MUST* contain the following four data columns 
% (=variables) with these exact names:
%
%  "Recording timestamp"  -> (local) clock timestamp of stimulus computer
%  "Eyetracker timestamp" -> (remote) clock timestamp of Tobii eyetracker
%  "Event value"          -> parallel port values (for sync. with EEG)
%  "Event messages"       -> messages (incl. keyword+value) (for sync. with EEG)
%
% For more information on the Tobii format, please read the tutorial of the
% EYE-EEG toolbox.
%
%   An example use of the function might look like this:
%   % If parallel port triggers were send:
%   >> ET = parsetobii('/myrawdata/SAMPLES.txt','/myfiles/SAMPLES.mat')
%
%   % Alternative with messages containing a keyword:
%   >> ET = parsetobii('/myrawdata/SAMPLES.txt','/myfiles/SAMPLES.mat','MYKEYWORD')
%
% Outputs:
%   et     - eyetracker structure
%
% See also:
%   pop_parsetobii  pop_importeyetracker
%
% Authors: Estefania Dominguez, od
% based on function parsesmi()
% Copyright (C) 2009-2018 Olaf Dimigen & Ulrich Reinacher, HU Berlin
% olaf.dimigen@hu-berlin.de

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, 51 Franklin Street, Boston, MA 02110-1301, USA

function et = parsetobii(inputFile,outputMatFile,triggerKeyword)

if nargin < 2
    help(mfilename);
    return;
end

%% feedback
fprintf('\n\n%s(): Parsing Tobii raw data. This may take a moment...', mfilename)
fprintf('\n-- reading txt...')

fid = fopen(inputFile,'r');
%% Bugfix: 16-bit Unicode encoding
% Use the following code instead if you accidentally used Unicode 16-bit 
% encoding when you exported the data from Tobii software (instead of 8-bit)
%
% warning off MATLAB:iofun:UnsupportedEncoding;
% fid = fopen(inputFile, 'r','n', 'Unicode'); 

if fid == -1
    error('\nThe source file ''%s'' was not found.\n',inputFile)
end
B = fread(fid,'*char')';
fclose(fid);
fprintf('\n\tDone.')

%% file specifications and comments
fprintf('\n-- getting column headers...')
et.comments = []; % unlike SMI or Eyelink data, Tobii data has no "comment" lines

%% build column header - first row
dataColHeader = cellstr(regexp(B,'[^\r\n]*\r\n','match','once'));
if isempty(dataColHeader{1})
    dataColHeader = cellstr(regexp(B,'[^\n]*\n','match','once'));
end
dataColHeader = strread(dataColHeader{1},'%s','delimiter','\t'); % previously strsplit()
fprintf('\n\tDone.')

%% get data
fprintf('\n-- getting data...')
% replace blank cells with NaN values
B = strrep(B,sprintf('\t\t'),sprintf('\tNaN\t'));
B = strrep(B,sprintf('\t\r'),sprintf('\tNaN\r'));
B = strrep(B,sprintf('\t\n'),sprintf('\tNaN\n'));
B = strrep(B,sprintf('\t\t'),sprintf('\t'));
% replace decimal , with .
B = strrep(B,sprintf(','),sprintf('.'));

dataLines = regexp(B,'(^\s*[^\r\n]*)','match','lineanchors')'; % includes the header line
clear B
% remove header row
dataLines(1) = [];
% split and restructure by columns
dataLinesSplit = regexp(dataLines,'(\t)','split')';
dataLinesSplit = mat2cell(vertcat(dataLinesSplit{:}), size(dataLines,1), ones(1,length(dataLinesSplit{1}))); % error matrix size not consistent
clear dataLines
% % remove last column if empty
% if isempty(dataLinesSplit{1,end}{1})
%     dataLinesSplit(end) = [];
%     dataColHeader(end)  = [];
% end
numberLines = length(dataLinesSplit{1});

et.colheader = {};
et.data      = [];
et.event     = [];

% go tru colums, include those that contain numeric data
for i=1:length(dataColHeader)
   
    % keep only numerical characters in "Event value"
    if strcmp(dataColHeader{i},'Event value')
        dataLinesSplit{1,i} = regexprep(dataLinesSplit{1,i},'\w*.\s','');
        event_num = str2double(dataLinesSplit{1,i});
        dataLinesSplit{1,i} = cellstr(num2str(event_num));
    end
    
    % fast conversion from cell of characters to array with blank-pads
    dataChar = char(dataLinesSplit{1,i});
    dataChar(:,end+1) = char(32);
    
    % 
    if length(sscanf(dataChar','%f',[1,inf])') == numberLines
        et.data(:,end+1) = sscanf(dataChar','%f',[1,inf])';
        et.colheader{end+1} = dataColHeader{i};
    else
        % update by OD, 2017-07-17
        if ~strcmp(dataColHeader{i},'Event message')
            fprintf('\nThe variable "%s" contains non-numeric data and will therefore not be included',dataColHeader{i} )
        end
    end
end
fprintf('\n\tDone.')


%% build table with synchronization events for eye tracker
fprintf('\n-- getting messages...')

% check that the two timestamp variables are in the data and get their indices
timeColIndex    = find(strcmp(et.colheader,'Recording timestamp'));
etTimeColIndex  = find(strcmp(et.colheader,'Eyetracker timestamp'));
triggerColIndex = find(strcmp('Event value',et.colheader));

if isempty(timeColIndex)
    error('\n\nThe variable "Recording timestamp" could not be found. Include it or rename the corresponding variable (= local time) to "Recording timestamp" to comply with the format and try again\n');
elseif isempty(etTimeColIndex)
    error('\n\nThe variable "Eyetracker timestamp" could not be found. Include it or rename the corresponding variable (= remote time) to "Eyetracker timestamp" to comply with the format and try again\n');
end

% 1: check for messages containing special KEYWORD in column "Event message"
if exist('triggerKeyword','var')
    
    if isempty(triggerKeyword)
        warning('\n\n%s(): You are using an empty string as the keyword (before the integer event number)!',mfilename)
    end
    
    % take care of leading whitespaces as well as missing trailing whitespaces
    % i.e. handle "MYKEYWORD 123" as well as "MYKEYWORD123"
    indexTrigger = find(strcmp(dataColHeader,'Event message'), 1);
    if isempty(indexTrigger)
        error('\n\nThe variable "Event message" could not be found. If your events are in a message format, please make sure that the variable is named "Event message" and try again\n')
    end
    messages = dataLinesSplit{1,indexTrigger};
    messageTimestamp = find(strncmp(messages, triggerKeyword, length(triggerKeyword)));
    messages = strrep(messages,triggerKeyword,'');
    messages = str2double(messages);
    
    time = et.data(:,timeColIndex);
    if ~isempty(messageTimestamp)
        if isnan(messages(messageTimestamp(1)))
            warning('\n\n%s(): The keyword string you have provided (''%s'') was found in the messages of the ET file (%s). However, it does not contain any additional valid integer event number. Please check your messages and make sure they contain the specified keyword followed by an integer event number.',...
                mfilename, triggerKeyword, inputFile)
        end
        et.event = [time(messageTimestamp) messages(messageTimestamp)];
    else
        warning('\n%s(): The keyword string you have provided (''%s'') was not found in any messages of the ET file (%s). Please check your messages and make sure they contain the specified keyword.',...
            mfilename, triggerKeyword, inputFile)
    end
    
% 2: check for TTL pulses (in separate data column "Event value")
else
    if ~isempty(triggerColIndex)        
        % parallel port pulses often last several samples, take rising edge of
        % pulse as trigger latency. Discard samples where a zero was send to the port
        et.data(isnan(et.data(:,triggerColIndex)),triggerColIndex) = 0;
        et.event = cleantriggers([et.data(:,timeColIndex),et.data(:,triggerColIndex)]);
    else
        warning('\n%s(): The variable "Event value" could not be found in the ET file. Please make sure that the variable containing the trigger events is named "Event Value".',mfilename)
    end
end
% no events found: user feedback
if isempty(et.event)
    warning('\n%s(): Did not find trigger pulses or special messages that could be used as events for synchronization.',mfilename)
    if ~exist('triggerKeyword','var')
        fprintf('\nIf you have sent messages with a special keyword, please provide the keyword when calling this function. See help.')
    end
end

% "Tobii Pro Lab" adds extra rows with stimulus and event information. Remove them
et.data(isnan(et.data(:,etTimeColIndex)),:) = [];
% Change, if necessary, the order of the Recording timestamp column so that 
% it is the first column of the data
if timeColIndex ~= 1
    tempData     = et.data(:,1);
    tempHeader   = et.colheader{1};
    et.data(:,1) = et.data(:,timeColIndex);
    et.colheader{1} = et.colheader{timeColIndex};
    et.data(:,timeColIndex) = tempData;
    et.colheader{timeColIndex} = tempHeader;
end

% delete the variable "Event value" from data and colheader - it will likely be empty
% since the events are stored in additional rows that have been deleted.
if ~isempty(triggerColIndex)
    et.data(:,triggerColIndex) = [];
    et.colheader(triggerColIndex) = [];
end

clear test* triggerColIndex dataLines dataChar dataLinesSplit timeColumn timeColIndex tempData tempHeader
fprintf('\n\tDone.')

%% save
fprintf('\n-- saving structure as mat...')
save(outputMatFile,'-struct','et')
fprintf('\n\tDone.')

fprintf('\n\nFinished parsing eye track.\nSaved .mat file to %s.\n',outputMatFile)