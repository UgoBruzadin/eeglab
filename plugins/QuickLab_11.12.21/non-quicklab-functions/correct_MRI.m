
function EEG = correct_MRI(EEG)

for i=1:size(EEGspread.lor.source_int,2)
    
    mx = makehgtform('xrotate',pi/2);
    
    EEG.lor.source_int(i).transform = EEG.lor.source_int(i).transform*mx

end