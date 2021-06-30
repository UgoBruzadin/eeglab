function EEG = quickfastPCADF(EEG,IC)
if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected

if nargin < 2
    if ~isempty(mybadcomps)
        IC = size(EEG.icawinv,2);
        IC = IC - size(mybadcomps,2);            %stores the number to be the next components analysis
        fprintf('Rejecting selected components... \r');
        EEG = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
    end
    EEG = pop_par_runica(EEG,'icatype','binica','extended', 1, 'verbose','off');
else
    if ~isempty(mybadcomps)
        fprintf('Rejecting selected components... \r');
        EEG = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
    end
    EEG = pop_par_runica(EEG,'icatype','binica','extended', 1,'pca',IC, 'verbose','off');
end

EEG = pop_fastIClabelDF(EEG);

end