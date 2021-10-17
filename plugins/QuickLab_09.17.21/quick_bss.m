function [EEGOUT,com] = quick_bss(EEGIN)

window = EEGIN.trials*EEGIN.pnts/EEGIN.srate

[EEGOUT,com] = pop_autobssemg( EEGIN, [window], [window], 'bsscca', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [10],'fs', [250],'femg', [15],'estimator',spectrum.welch,'range', [0  49]});

plotDifference(EEGIN,EEGOUT)

end