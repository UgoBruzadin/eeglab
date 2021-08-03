function EEG = pop_fastICA(EEG)
if ~isempty(EEG.icawinv)
    try
        EEG = pop_par_runica(EEG,'extended', 1, 'verbose','off');
    catch
        EEG = pop_loadset();
        EEG = pop_par_runica(EEG,'extended', 1, 'verbose','off');
    end
end
if ~isempty(EEG.icaact)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
end

EEG = pop_iclabel(EEG);

pop_viewprops(EEG,0,1:size(EEG.icawinv,2),2:55)

fprintf('You are welcome!  /r')
    
end