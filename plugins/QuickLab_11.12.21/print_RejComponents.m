function print_RejComponents(EEG,myComps)

if nargin  < 2
    myComps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected
end

if myComps
    allComps = [1:size(EEG.icawinv,2)];
    % --- remove the one component number
    allComps(myComps) = [];
    % --- make another copy of the EEG data
    EEGcomp = EEG;
    % --- removes the other components from the data-set to minimize file
    % ---- size
    EEGcomp = pop_subcomp(EEGcomp, allComps, 0);       % actually removes the flagged components
    % --- plots and prints the components
    pop_viewprops4( EEGcomp, 0, [1:size(EEGcomp.icawinv, 2)], {'freqrange', [2 80]}, {}, 2, 'ICLabel' )
end

end