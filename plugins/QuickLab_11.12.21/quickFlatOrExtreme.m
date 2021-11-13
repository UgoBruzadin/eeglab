function EEG = quickFlatOrExtreme(EEG)

devStd = std(EEG.data(:,:), [], 2);

flatchans = [];
xtremechans = [];

if any(devStd < 0.1)
    flatchans = find(devStd < 0.1)';
    ChansForInterp = flatchans;
end

if any(devStd > 1000)
    xtremechans = find(devStd > 1000)';
    ChansForInterp = xtremechans;
end

if xtremechans && flatchans
    ChansForInterp = cat(2,xtremechans,flatchans);
end

if ChansForInterp
    fprintf(strcat('Marked channels',strcat(num2str(ChansForInterp)), ' /r'));
    EEG = pop_interp(EEG, [ChansForInterp], 'spherical');
else
    fprintf(strcat('no flat channels or extreme channels found /r'));
end

fprintf('Flat and Extreme chans removed \r')

end