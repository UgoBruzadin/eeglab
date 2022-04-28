% [com] = quick_spectra(EEG, high, low, reference) - Quickly plots channel
%                                                    frequency spectra
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

% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function [com] = quick_spectra(EEGIN,high,low,topo,references)

if isempty(EEGIN.data)
    [EEGIN,com] = pop_loadset();
    [EEGIN,com] = eeg_store(EEGIN);
end

% collects defaults defined at QuickLabDefs

QuickLabDefs; % using SPECTRADEFS 1 for High Frequency filter, 2 for low frequency filter and 3 for maximum points for FFT display
              % also using SPECTRATOPO for defaulty defined frequencies to display
%% collecting defaults or given variables
              
if nargin > 3
    [EEGIN,com] = quick_reref(EEGIN,references);
end

if nargin < 4
   topo = SPECTRATOPO; % SPECTRATOPO DEFINED INSIDE QuickLabDefs 
end

if nargin < 3 
    %low = 2;
    low = SPECTRADEFS(2); % SPECTRADEFS DEFINED INSIDE QuickLabDefs 
end

if nargin < 2
    %high = 55;
    high = SPECTRADEFS(1); % SPECTRADEFS DEFINED INSIDE QuickLabDefs 
    
maxWindow = 2^floor(log2(EEGIN.pnts));
if maxWindow > SPECTRADEFS(3)
    %maxWindow = 2048;
    maxWindow = SPECTRADEFS(3);
end
 
% numberOfHeadmaps = 10;
% 
% calc = (high - low) / numberOfHeadmaps;
% topo = zeros(1,numberOfHeadmaps);
% 
% for i=1:numberOfHeadmaps
%     topo(i) = floor(low + i*calc);
% end

%topo = [4 5 6 7 8 9 10 11 12 15 20 25 30 36];

%% runs pop_spectopo with the given defaults or variables

tic
figure; pop_spectopo(EEGIN, 1, [EEGIN.xmin*1000  EEGIN.xmax*1000], 'EEG' , 'freq', [topo], 'freqrange',[low high],'winsize',maxWindow,'electrodes','off');
toc

end