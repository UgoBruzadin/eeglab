function [EEG,com] = quick_FFT(EEG,low,high)

if nargin < 3
    high = 40;
end

if nargin < 3
    low = 2;
end

com = strcat('quick_FFT(EEG,',char(low),char(high)');

maxWindow = 2^floor(log2(EEG.pnts));
if maxWindow > 2048
    maxWindow = 2048;
end

figure; pop_spectopo(EEG, 1, [EEG.xmin*1000  EEG.xmax*1000], 'EEG' , 'freq', [4 5 6 7 8 9 10 11 12 15 18 21 25 28 32 36 40], 'freqrange',[low high],'winsize',maxWindow,'electrodes','off');

saveas(gcf,[EEG.filename(1:end-4),'FFT.jpg']);

close(gcf)

end


