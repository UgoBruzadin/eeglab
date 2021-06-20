function [EEG] = pop_fastchannelinterp(EEG,minfreq,maxfreq,sdv)

if nargin < 2
    minfreq = 2;
    maxfreq = 55;
    sdv = 3;
end

if EEG.ref ~= 'average'
    EEG = pop_fastrerefavg(EEG);
end

ChansForInterp = outlierChannelsFrequency(EEG,minfreq,maxfreq,sdv);

if ChansForInterp
    fprintf(strcat('marked channels ',num2str(ChansForInterp), '/r'));
    EEG = pop_interp(EEG, [ChansForInterp], 'spherical');
else
    fprintf(strcat('no channels marked above ',num2str(sdv), '/r'));
end

acronym = strcat('Ch',num2str(ChansForInterp));

end