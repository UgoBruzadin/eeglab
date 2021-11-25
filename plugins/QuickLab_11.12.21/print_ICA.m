function print_ICA(EEG,components)

if nargin < 2
    components  = 1:size(EEG.icawinv, 2);
end

pop_viewprops4( EEGcomp, 0, [1:components], {}, 2, 'ICLabel' );

end


