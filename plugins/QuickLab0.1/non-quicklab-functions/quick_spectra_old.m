function [EEG,com] = quick_spectra(EEG,high,low,avg)
if isempty(EEG.data)
    [EEG,com] = pop_loadset();
    [EEG,com] = eeg_store(EEG);
end

QuickLabDefs;
try
    topo = SPECTRATOPO;
    high = SPECTRADEFS(1);
    low = SPECTRADEFS(2);
    maxWindow = 2^floor(log2(EEG.pnts));
    if maxWindow > SPECTRADEFS(3)
        maxWindow = SPECTRADEFS(3);
    end
catch
maxWindow = 2^floor(log2(EEG.pnts));
if maxWindow > 2048
    maxWindow = 2048;
end
if nargin < 4
    avg = 0;
end
if avg
    [EEG,com] = pop_fastrerefavg(EEG);
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

topo = [4 5 6 7 8 9 10 11 12 15 20 25 30 36];
end
tic
figure; [EEG.x,EEG.y] = pop_spectopo(EEG, 1, [EEG.xmin*1000  EEG.xmax*1000], 'EEG' , 'freq', [topo], 'freqrange',[low high],'winsize',maxWindow,'electrodes','off');
toc

end