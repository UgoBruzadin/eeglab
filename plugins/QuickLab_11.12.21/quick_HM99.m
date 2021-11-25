function [EEG,com] = quick_HM99(EEG)
if isempty(EEG.data)
    [EEG,com] = pop_loadset();
    eeglab redraw
end
[EEG,com] = pop_select( EEG,'nochannel',[8	14	17	21	25	43 48	49	56	63	64	68	69	73	74	81	82	88	89	94	95	99	107	113	119	120	125	126	127	128]);

for a=1:EEG.nbchan
    if isempty(strfind(EEG.chanlocs(1,a).labels,'Cz'))
        EEG.chanlocs(1,a).labels = strcat(EEG.chanlocs(1,a).labels,'_','N',num2str(a));
    end
end

end