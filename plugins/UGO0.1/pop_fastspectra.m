function EEG = pop_fastspectra(EEG)
if isempty(EEG.data)
    EEG = pop_loadset();
    [EEG] = eeg_store(EEG);
end

figure; pop_spectopo(EEG, 1, [EEG.xmin*1000  EEG.xmax*1000], 'EEG' , 'freq', [4 6 8 9 10 11 15 18 21 40], 'freqrange',[2 40],'winsize',2^floor(log2(EEG.pnts)),'electrodes','off');

end