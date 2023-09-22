

function rejected_trials = quick_variancethreshold(EEG,icacomp, sdv)

% identify trials with total variance in all channels or components above
% given sdv. % could make it by channel as well.

if icacomp == 1
    V = var(EEG.icaact,0,2);
    V2 = reshape(V,size(EEG.icaact,1),EEG.trials);
    V3 = sum(V2,1);
    V4 = outlier(V3,sdv);
else
    V = var(EEG.data,0,2);
    V2 = reshape(V,EEG.nbchan,EEG.trials);
    V3 = sum(V2,1);
    V4 = outlier(V3,3);
end

rejected_trials = V4;
