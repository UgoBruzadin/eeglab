function [EEG,com] = quick_PCA(EEG,IC,type)
% [EEG,com] = quick_PCA(EEG,IC,type) 
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

com = [];
if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

if nargin < 3
    type = 'binica';
end

mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected

if nargin < 2 || isempty(IC)
    if ~isempty(mybadcomps)
        IC = size(EEG.icawinv,2);
        IC = IC - size(mybadcomps,2);            %stores the number to be the next components analysis
        fprintf('Rejecting selected components... \r');
        [EEG,com] = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
    end
    [EEG,com] = pop_par_runica(EEG,'extended', 1,'icatype',type, 'verbose','off');
else

    if ~isempty(mybadcomps)
        fprintf('Rejecting selected components... \r');
        [EEG,com] = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
    end
    if ischar(IC)
        IC = size(EEG.icaact,1)-1;
    end
    [EEG,com] = pop_par_runica(EEG,'extended', 1,'icatype',type,'pca',IC, 'verbose','off');
end

[EEG,com] = quick_IClabel(EEG);

end