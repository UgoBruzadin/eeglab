function EEG = quick_eegsave(EEG,text)

if nargin < 2 || isempty(text)
    text = 'sv';
end

[EEG] = pop_saveset(EEG, 'filename', [strcat( EEG.filename(1:end-4),text,'.set')],'filepath',EEG.filepath);

end