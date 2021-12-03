function [EEGOUT,com] = quick_bss(EEGIN,window,windowshift)

if nargin < 2
    window = (EEGIN.pnts/EEGIN.srate)*2;
end
if nargin < 3
    windowshift = window; % new change suggested by Gunn, window shift should be max of 2 epochs
    %windowshift = EEGIN.pnts;
end

[EEGOUT,com] = pop_autobssemg( EEGIN, [window], [windowshift], 'bsscca', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [10],'fs', EEGIN.srate,'femg', [15],'estimator',spectrum.welch,'range', [0  floor(EEGIN.nbchan/2)]});

plotDifference(EEGIN,EEGOUT)

end