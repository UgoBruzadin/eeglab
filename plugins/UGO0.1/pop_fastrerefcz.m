function EEG = pop_fastrerefcz(EEG)

for a=1:EEG.nbchan
    A = strfind(EEG.chanlocs(1,a).labels,'Cz');
    if A
        B = a;
        break
    end
end

EEG = pop_reref( EEG, B);

end