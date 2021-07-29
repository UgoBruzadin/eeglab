function EEG = pop_fastrerefcz(EEG)
if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

EEG = pop_reref( EEG, 'Cz');

end