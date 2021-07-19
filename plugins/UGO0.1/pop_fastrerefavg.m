function EEG = pop_fastrerefavg(EEG)
if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end
EEG = pop_reref( EEG, [],'keepref','on');

end