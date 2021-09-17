
function EEG = quick_rejection(EEG)
if isfield(EEG,'reject')
    if isfield(EEG.reject,'gcompreject')
        mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected
        if ~isempty(mybadcomps)
            fprintf('Rejecting selected components... /r');
            EEG = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
        end
    end
end
end