function [EEG,com] = quick_rerefavg(EEG)

if isempty(EEG.data)
    [EEG,com] = pop_loadset();
    eeglab redraw
end

[EEG,com] = pop_reref( EEG, [],'keepref','on');

end