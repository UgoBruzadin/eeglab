function EEG = quick_N1PCA(EEG)
% --- this script was made by Ugo Bruzadin Nunes
% --- it runs an ICA or a PCA of N-1 components
% --- and plots them.
if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end
if ~isempty(EEG.icawinv)
    fprintf('Gathering Data... /r');
    IC = size(EEG.icawinv,2);
    mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected
    if ~isempty(mybadcomps)
        IC = IC - length(mybadcomps);            %stores the number to be the next components analysis
        fprintf('Rejecting selected components... /r');
        EEG = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
    end
    fprintf('Running N-1 PCA \r');
    EEG = pop_runica(EEG,'extended', 1,'icatype','binica','pca',IC-1,'verbose','off');
        
    if isempty(EEG.icaact)
        EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    end
    fprintf('Running IC Label and plotting components /r');
    EEG = quick_fastIClabel(EEG);
%     if isempty(EEG.etc.ic_classification.ICLabel.classifications) || ...
%             size(EEG.etc.ic_classification.ICLabel.classifications,2) ~= size(EEG.icawinv,2)
%         EEG = pop_iclabel(EEG);
%     end
    
else
    try
        EEG = quick_PCA(EEG);
    catch
        EEG = pop_loadset();
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = quick_PCA(EEG);
    end
end

fprintf('You are welcome!  /r')
    
end