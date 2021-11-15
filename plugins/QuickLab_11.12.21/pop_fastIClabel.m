% [EEG,com] = pop_fastIClabel(EEG,minfreq,maxfreq) 
%
% Author: Ugo Bruzadin Nunes
%
% Copyright (C) 2021 Ugo Bruzadin Nunes
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software

function [EEG,com] = pop_fastIClabel(EEG,minfreq,maxfreq)

if nargin < 3
    maxfreq = 55;
end
if nargin < 2
    minfreq = 2;
end

if isempty(EEG.data)
    [EEG,com] = pop_loadset;
end
if isempty(EEG.icawinv)
    [EEG,com] = pop_runica(EEG,'icatype','binica','extended', 1, 'verbose','off');
end
if isempty(EEG.icaact)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
end
[EEG,com] = pop_iclabel(EEG,'default');
pop_viewprops2(EEG,0,1:size(EEG.icawinv,2),{'freqrange',[minfreq maxfreq]});

 fprintf('You are welcome!  /r')
%     
% 
%     try
%         EEG = pop_runica(EEG,'icatype','binica','extended', 1, 'verbose','off');
%         EEG = pop_fastPCAandIClabel(EEG);
%     catch
%         EEG = pop_loadset();
%         EEG = pop_runica(EEG,'icatype','binica','extended', 1, 'verbose','off');
%         EEG = pop_fastPCAandIClabel(EEG);
%     end


end