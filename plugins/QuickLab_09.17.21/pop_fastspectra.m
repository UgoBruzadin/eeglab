function EEG = pop_fastspectra(EEG,high,low)
if isempty(EEG.data)
    EEG = pop_loadset();
    [EEG] = eeg_store(EEG);
end

maxWindow = 2^floor(log2(EEG.pnts));
if maxWindow > 2048
    maxWindow = 2048;
end

if nargin < 3 
    low = 2;
end

if nargin < 2
    high = 55;
end

numberOfHeadmaps = 10;

calc = (high - low) / numberOfHeadmaps;
topo = zeros(1,numberOfHeadmaps);

for i=1:numberOfHeadmaps
    topo(i) = floor(low + i*calc);
end
tic
figure; pop_spectopo(EEG, 1, [EEG.xmin*1000  EEG.xmax*1000], 'EEG' , 'freq', [topo], 'freqrange',[low high],'winsize',maxWindow,'electrodes','off');
toc

end