% convert2continuous(EEG) - This function converts data from epoch to
%                               continuous format.
%
% Usage:
%   >>  OUTEEG = convert2continuous(EEG);
%
% Inputs:
%   EEG     - Input dataset.
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

function [EEG, com] = convert2continuous(EEG)  
com = '';
if nargin < 1
    help convert2continuous;
    return;
elseif nargin == 1
end

if EEG.trials > 1
    A = size(EEG.data,2)*size(EEG.data,3);
    EEG.data = reshape(EEG.data , size(EEG.data,1),size(EEG.data,2)*size(EEG.data,3));
    try
    EEG.icaact = reshape(EEG.icaact , size(EEG.icaact,1),size(EEG.icaact,2)*size(EEG.icaact,3));
    catch
    end
    EEG.urevent = EEG.event;
    EEG.times = 1:EEG.trials*EEG.pnts;
    EEG.pnts = size(EEG.data,2);
    EEG.epoch = [];
    EEG.trials = 1; 
    EEG.xmin   = 0;
    EEG.xmax   = A;
end
com = sprintf('EEG = convert2continuous(EEG);');
return