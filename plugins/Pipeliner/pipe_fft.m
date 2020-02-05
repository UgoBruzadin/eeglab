function pipe_fft(files,EEG) %works; by ugo 2/3/2020 7:15pm
    figure; pop_spectopo(EEG, 1, [EEG.xmin*10^3  EEG.xmax*10^3], 'EEG' , 'freq', [4 5 6 7 8 9 10 11 12 18 30 40], 'freqrange',[2 55], 'electrodes','off');
    saveas(gcf,[strcat(files.name(1:end-4),'_FFT.jpg')]);
    close all;
    fprintf('running FFTs')
end