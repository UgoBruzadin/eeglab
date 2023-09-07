function [EEG,com] = pop_fastrerefcz(EEG)
if isempty(EEG.data)
    [EEG,com] = pop_loadset();
    eeglab redraw
end
B = [];
for a=1:EEG.nbchan
    A = strfind(EEG.chanlocs(1,a).labels,'Cz');
    if ~isempty(A)
        B = a;
        [EEG,com] = pop_reref( EEG, B);
        break
    else
    end
end

if isempty(B)
    [EEG,com] = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}));
    [EEG,com] = pop_reref( EEG, 99);
end
end