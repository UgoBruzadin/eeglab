function EEG = pop_fastIClabel(EEG)
if isempty(EEG.icawinv)
    try
        EEG = pop_par_runica(EEG,'extended', 1, 'verbose','off');
    catch
        EEG = pop_loadset();
        EEG = pop_par_runica(EEG,'extended', 1, 'verbose','off');
    end
end

if isempty(EEG.icaact)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
end
if isempty(EEG.etc.ic_classification.ICLabel.classifications) || ...
size(EEG.etc.ic_classification.ICLabel.classifications,2) ~= size(EEG.icawinv,2)
EEG = pop_iclabel(EEG);
end
pop_viewprops2(EEG,0,1:size(EEG.icawinv,2),2:55);

fprintf('You are welcome!  \r')
    
end