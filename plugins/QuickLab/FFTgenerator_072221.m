%--- script made by Ugo Nunes
% on 07/22/2021
% generates FFTs but also save FFTs to the file

clc
clear all


fileINPUT = pwd;
files = dir('*.set');

eeglab;
parfor i=1:length(files) 
    EEG = pop_loadset( files(i).name, fileINPUT);

    %figure; [EEG.x EEG.y] = pop_par_spectopo(EEG, 1, [], 'EEG' , 'winsize', 512, 'freq', [5 8 12 20 30 40 40 50], 'freqrange',[2 60],'electrodes','off');
    if ~isfield(EEG,'ffts')
        EEG.ffts = struct('spectra',[],'freqs',[]);
        try
            EEG.ffts(end+1).spectra = EEG.xOLD;
            EEG.ffts(end+1).freqs = EEG.yOLD;
        catch
        end
        try
            EEG.ffts(end+1).spectra = EEG.xOLD2;
            EEG.ffts(end+1).freqs = EEG.yOLD2;
        catch
        end
        EEG.ffts(end+1).spectra = EEG.xOLD;
        EEG.ffts(end+1).freqs = EEG.yOLD;
    end
    pop_par_spectopo(EEG, 1, [EEG.xmin*1000  EEG.xmax*1000], 'EEG' , 'freq', [4 6 10 12 15 18 21 25 28 32 36], 'freqrange',[2 55],'winsize',1024,'electrodes','off');

    saveas(gcf,[files(i).name(1:end-4),'FFT.jpg']);

    close(gcf)
    close(gcf)
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'savemode','resave');
end