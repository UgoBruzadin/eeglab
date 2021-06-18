function EEG = pop_fastPCA(EEG,IC)
if isempty(EEG.data)
    EEG = pop_loadset();
    [EEG] = eeg_store(EEG);
end

mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected
if ~isempty(mybadcomps)
    IC = IC - length(mybadcomps);            %stores the number to be the next components analysis
    fprintf('Rejecting selected components... \r');
    EEG = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
end

if nargin < 2
    EEG = pop_par_runica(EEG,'icatype','binica','extended', 1, 'verbose','off');
else
    EEG = pop_par_runica(EEG,'icatype','binica','extended', 1,'pca',IC, 'verbose','off');
end

EEG = pop_fastIClabel(EEG);

end