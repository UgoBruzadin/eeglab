function EEG = storebackup(EEG,varargin)

%store EEG backup
%store EEG difference
%store newest FFT

if nargin < 2
    varargin = [];
end

if ~isfield(EEG,'backup')
    EEG.backup = struct();
    EEG.backup.EEG = EEG;
    EEG.backup.datadiff = EEG.data - EEG.data;
end

if ~isfield(EEG,'fft')
    EEG.fft = struct();
    [EEG.fft.spectra, EEG.fft.freqs, EEG.fft.speccomp, EEG.fft.contrib, EEG.fft.specstd] = spectopo2(EEG.data,'default',EEG.srate,'winsize',2^floor(log2(EEG.pnts)),'plot','off');
    EEG.removedEpochNUmbers = [];
    EEG.interpolatedChannels = [];
end
    
end
eeglab redraw
