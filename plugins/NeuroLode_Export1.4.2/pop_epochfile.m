% [EEG, com] = pop_epochfile(EEG,TimeBased,StimCodes,Preonset,Postonset,BaselineCorrectStart,BaselineCorrectEnd,GUIOnOff)
%                  - This epochs file and applies baseline correct.
%
% Usage:
%   >>  OUTEEG = pop_epochfile(EEG,TimeBased,StimCodes,Preonset,Postonset,BaselineCorrectStart,BaselineCorrectEnd,GUIOnOff)
% 
%
% Inputs:
%   EEG                     - Input dataset.
%   TimeBased               - Time interval to epoch if no event codes are being used.
%   StimCodes               - The list of event codes to epoch around.
%   Preonset                - How many milliseconds to epoch before event code onset 
%   Postonset               - How many milliseconds to epoch after event code onset
%   BaselineCorrectStart    - How many milliseconds to start baseline correct.
%   BaselineCorrectEnd      - How many milliseconds to end baseline correct.
%   GUIOnOff                - Used to skip GUI inputs if using in another function. If
%                             BadChanGUI doesn't exsist it will run the GUI
%    
% Outputs:
%   OUTEEG     - Output dataset.
%
% Author: Matthew Phillip Gunn 
%
% See also: 
%   eeg_regepochs,pop_epoch,pop_rmbase,eeglab 
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

function [EEG, com] = pop_epochfile(EEG,TimeBased,StimCodes,Preonset,Postonset,BaselineCorrectStart,BaselineCorrectEnd,GUIOnOff) 
% Not too much different from the pop_epoch function just bunlded for
% easier uses
com = '';
if nargin < 1
    help EpochFile_v1a;
    return;
elseif nargin == 1
end

%%%%%%%%%%%%%%%%
if exist('GUIOnOff') == 0   
    NumberOfFieldsAndFieldSpace = [.75 1 1];
    Title = { { 'style' 'text' 'string' 'Epoch File - Rebundling of Pop_Epoch and pop_rmbase' 'fontweight' 'bold' } ...
        {} ...
        {  'style' 'text' 'string' '' } ...
        {  'style' 'text' 'string' '' }};

    Title1 = { { 'style' 'text' 'string' 'Time-Based' 'fontweight' 'bold' } ...
            {  'style' 'text' 'string' '' } ...
            {  'style' 'text' 'string' '' }};

    C1  = { { 'style' 'text' 'string' 'Time interval' } ...
          { 'style' 'edit' 'string' '' } ...
          { 'style' 'text' 'string' 'Ex. "1000" Epoch in 1000ms intervals' } }; 

   Title2 = { { 'style' 'text' 'string' 'Stimulus-Based' 'fontweight' 'bold' } ...
          {  'style' 'text' 'string' '' } ...
          {  'style' 'text' 'string' '' }};

    C2  = { { 'style' 'text' 'string' 'Stim Codes' } ...
           { 'style' 'edit' 'string' '' } ...
           { 'style' 'text' 'string' 'Ex. "10 12" Will Epch on codes 10 and 12' } }; 
    
    Mo1  = { { 'style' 'text' 'string' 'Pre-Stimulus Onset' } ...
        { 'style' 'edit' 'string' '' } ...
        { 'style' 'text' 'string' 'Ex. "-100" Epoch start -100ms Pre-onset' } };
    
    Mo2  = { { 'style' 'text' 'string' 'Post-Stimulus Onset' } ...
        { 'style' 'edit' 'string' '' } ...
        { 'style' 'text' 'string' 'Ex. "200" Epoch end 200ms Post-onset' } };
    
    Mo3  = { { 'style' 'text' 'string' 'Baseline Correct - Start' } ...
        { 'style' 'edit' 'string' '' } ...
        { 'style' 'text' 'string' 'Ex. "-100" 100ms Before Onset' } };
    
    Mo4  = { { 'style' 'text' 'string' 'Baseline Correct - End' } ...
        { 'style' 'edit' 'string' '' } ...
        { 'style' 'text' 'string' 'Ex. "0" will end at stimulus Presentation' } };
    
    allGeom = { 1 NumberOfFieldsAndFieldSpace };%     
    Title = [ Title(:)' Title1(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Title = [ Title(:)' C1(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Title = [ Title(:)' Title2(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Title = [ Title(:)' C2(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
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

% else
%     TimeBased = cell2mat(res(1,1));
%     EEG = eeg_regepochs(EEG,'recurrence',TimeBased);
%     StimCodes = string(res(1,2));
%     Preonset = (cell2mat(res(1,3)))/1000;
%     Postonset = (cell2mat(res(1,4)))/1000;
%     BaselineCorrectStart = cell2mat(res(1,5));
%     BaselineCorrectEnd = cell2mat(res(1,6));
end
TimeBased = (str2double(res(1,1)))/1000;
 if TimeBased > 0
    TimeBased = (str2double(res(1,1)))/1000;
    EEG=eeg_regepochs(EEG,'recurrence',TimeBased,'limits',[0 TimeBased]); 
else
    StimCodes = string(res(1,2));
    Preonset = (str2double(res(1,3)))/1000;
    Postonset = (str2double(res(1,4)))/1000;
    if ~isempty(res(1,5))
        BaselineCorrectStart = str2double(res(1,5));
        BaselineCorrectEnd = str2double(res(1,6));
        EEG = pop_epoch( EEG, {StimCodes}, [Preonset Postonset]);
        EEG = pop_rmbase( EEG, [BaselineCorrectStart BaselineCorrectEnd] ,[]);
    else
        EEG = pop_epoch( EEG, {StimCodes}, [Preonset Postonset]);
    end
end

if exist('GUIOnOff') == 0
    regions = [res(1,1) res(1,2) res(1,3) res(1,4) res(1,5) res(1,6)];
    com = sprintf('EEG = pop_epochfile(EEG,%s);', vararg2str(regions));
end



%end