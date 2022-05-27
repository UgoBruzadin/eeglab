function [EEGOUT,com] = quick_bss(EEGIN,window,windowshift)

% [EEG,com] = quick_bss(EEG,window,windowshift) 
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

if nargin < 2
    window = (EEGIN.pnts/EEGIN.srate)*2;
    
end

if nargin < 3
    windowshift = window; % new change suggested by Gunn, window shift should be max of 2 epochs
    %windowshift = EEGIN.pnts;
end

[EEGOUT,com] = pop_autobssemg( EEGIN, [window], [windowshift], 'bsscca', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [10],'fs', EEGIN.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  floor(EEGIN.nbchan/2)]});

%plotDifference(EEGIN,EEGOUT)

end