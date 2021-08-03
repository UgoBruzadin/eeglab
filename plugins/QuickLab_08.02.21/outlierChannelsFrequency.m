function ChansForInterp = outlierChannelsFrequency(EEG,minfreq,maxfreq,sdv)
if nargin < 4
   sdv = 3; %default sdv to 3 
end
if nargin < 3
   maxfreq = EEG.srate/2; %defaults max frequency to max frequency of FFT(i.e. EEG.srate/2 ) 
end
if nargin < 2
   minfreq = 0; %defaults min frequency to 0
end

% --- performs fft and gets spectra and frequencies
[spectra,freqs,speccomp,contrib,specstd] = spectopo(EEG.data, EEG.pnts,EEG.srate,'winsize',2^floor(log2(EEG.pnts)),'plot','off');
% --- collects the location of the bins in which the asked frequencies start and end.
minFreqBin = max(find(freqs<minfreq));
maxFreqBin = min(find(freqs>maxfreq));
% --- collects the data for the bins in the spectra
spectraFocus = spectra(:,minFreqBin:maxFreqBin);
% --- gets a table of outliers for each column
outliers = outlier(spectraFocus,sdv);
% --- gets the sum of outliers (i.e., reduces the outliers to one column)
outSum = sum(outliers,2);
% --- gets the channels numbers responsible for the outliers
ChansForInterp = find(outSum);

end