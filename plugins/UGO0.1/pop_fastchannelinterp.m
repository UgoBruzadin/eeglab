function [EEG] = pop_fastchannelinterp(EEG,sdv,minfreq,maxfreq)
if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

if nargin < 2
    sdv = 3;
end

if nargin < 3
    maxfreq = 55;
    minfreq = 2;
end

% if EEG.ref ~= 'average'
%     EEG = pop_fastrerefavg(EEG);
% end

ChansForInterp = outlierChannelsFrequency(EEG,minfreq,maxfreq,sdv);

CentralCircle = [7,31,55,80,106];

if ChansForInterp
    fprintf(strcat('Marked channels',strcat(num2str(ChansForInterp)), ' /r'));
    EEG = pop_interp(EEG, [ChansForInterp], 'spherical');
else
    fprintf(strcat('no channels marked above ',num2str(sdv), '/r'));
end

acronym = strcat('Ch',num2str(ChansForInterp));

end