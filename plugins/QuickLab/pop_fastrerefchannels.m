function EEG = pop_fastrerefchannels(EEG,channels)
if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

EEG = pop_reref( EEG, channels,'keepref','on');

end