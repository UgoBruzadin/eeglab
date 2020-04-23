
function [EEG, acronym] = pipe_bss(EEG)
    
    %eventully neds to calculate the ideal bss!

    EEG = pop_autobssemg( EEG, [16.384], [16.384], 'bsscca', {'eigratio', [1000000]}, 'emg_psd', {'ratio', [10],'fs', [EEG.srate],'femg', [15],'estimator',spectrum.welch,'range', [0  14]});

    acronym = 'BSS';
end