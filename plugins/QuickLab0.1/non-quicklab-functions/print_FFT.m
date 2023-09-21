function [spectra,frequencies] = print_FFT(EEG)

maxWindow = 2^floor(log2(EEG.pnts));
if maxWindow > 2048
    maxWindow = 2048;
end

figure; [spectra,frequencies] = pop_spectopo(EEG, 1, [EEG.xmin*1000  EEG.xmax*1000], 'EEG' , 'freq', [4 6 10 12 15 18 21 25 28 32 36], 'freqrange',[2 55],'winsize',maxWindow,'electrodes','off');

saveas(gcf,[EEG.filename(1:end-4),'FFT.jpg']);

close(gcf)

end


