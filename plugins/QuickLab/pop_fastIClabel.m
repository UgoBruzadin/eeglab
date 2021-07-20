function EEG = pop_fastIClabel(EEG,minfreq,maxfreq)
if nargin < 3
    maxfreq = 55;
end
if nargin < 2
    minfreq = 2;
end

if isempty(EEG.data)
    EEG = pop_loadset;
end
if isempty(EEG.icawinv)
    EEG = pop_runica(EEG,'icatype','binica','extended', 1, 'verbose','off');
end
if isempty(EEG.icaact)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
end
EEG = pop_iclabel(EEG);
pop_viewprops2(EEG,0,1:size(EEG.icawinv,2),{'freqrange',[minfreq maxfreq]});

 fprintf('You are welcome!  /r')
%     
% 
%     try
%         EEG = pop_runica(EEG,'icatype','binica','extended', 1, 'verbose','off');
%         EEG = pop_fastPCAandIClabel(EEG);
%     catch
%         EEG = pop_loadset();
%         EEG = pop_runica(EEG,'icatype','binica','extended', 1, 'verbose','off');
%         EEG = pop_fastPCAandIClabel(EEG);
%     end


end