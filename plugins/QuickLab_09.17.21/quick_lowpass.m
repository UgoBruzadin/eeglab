function EEG = quick_lowpass(EEG,lowpass)

if nargin < 2
   lowpass = 15; 
end

EEG = pop_eegfiltnew(EEG, 'hicutoff',lowpass,'plotfreqz',1);

end