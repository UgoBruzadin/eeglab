function [EEG] = quick_bss(EEG)

EEG = pop_autobssemg( EEG, [], [], 'bsscca', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [10],'fs', [250],'femg', [15],'estimator',spectrum.welch,'range', [0  49]});

end