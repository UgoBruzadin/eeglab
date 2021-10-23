function [EEGOUT,com] = quick_bss(EEGIN,window,windowshift)

if nargin < 2
    window = EEGIN.trials*EEGIN.pnts/EEGIN.srate;
end
if nargin < 3
    windowshift = EEGIN.pnts;
end

[EEGOUT,com] = pop_autobssemg( EEGIN, [window], [windowshift], 'bsscca', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [10],'fs', [250],'femg', [15],'estimator',spectrum.welch,'range', [0  49]});

plotDifference(EEGIN,EEGOUT)

end