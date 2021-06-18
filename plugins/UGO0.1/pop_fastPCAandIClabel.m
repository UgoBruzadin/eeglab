function EEG = pop_fastPCAandIClabel(EEG)
% --- this script was made by Ugo Bruzadin Nunes
% --- it runs an ICA or a PCA of N-1 components
% --- and plots them.

if ~isempty(EEG.icawinv)
    fprintf('Gathering Data... \r');
    IC = size(EEG.icawinv,2);
    mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected
    if ~isempty(mybadcomps)
        IC = IC - length(mybadcomps);            %stores the number to be the next components analysis
        fprintf('Rejecting selected components... \r');
        EEG = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
    end
        fprintf('Running N-1 PCA \r');
        EEG = pop_runica(EEG,'icatype','binica','extended', 1,'pca',IC-1,'verbose','off');
        
    if isempty(EEG.icaact)
        EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    end
    fprintf('Running IC Label and plotting components \r');
    EEG = pop_iclabel(EEG);
    pop_viewprops2(EEG,0,1:size(EEG.icawinv,2),2:55);
%     if isempty(EEG.etc.ic_classification.ICLabel.classifications) || ...
%             size(EEG.etc.ic_classification.ICLabel.classifications,2) ~= size(EEG.icawinv,2)
%         EEG = pop_iclabel(EEG);
%     end
    

else
    try
        EEG = pop_runica(EEG,'icatype','binica','extended', 1, 'verbose','off');
        EEG = pop_fastPCAandIClabel(EEG);
    catch
        EEG = pop_loadset();
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = pop_runica(EEG,'icatype','binica','extended', 1, 'verbose','off');
        EEG = pop_fastPCAandIClabel(EEG);
    end
end

fprintf('You are welcome!  /r')
    
end