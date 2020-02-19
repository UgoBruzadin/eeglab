function [EEG, PercentBrainAccountedFor_Total] = pipe_explainedvariance(content,EEG)

if nargin < 2
    content = size(EEG.icaweights,1); %default: how much brain in the whole set
    %or
    %content = 10 %maybe default: how much brain in the first 10 components
    %if PCs > 10
end
%getVarianceEmplained(components,EEG)
temporaryList = {};
finalList = [];
EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);

chanorcomp = size(EEG.icaweights,1);
for j=1:chanorcomp
    icaacttmp = EEG.icaact(j, :, :);
    maxsamp = 1e6;
    n_samp = min(maxsamp, EEG.pnts*EEG.trials);
    try
        samp_ind = randperm(EEG.pnts*EEG.trials, n_samp);
    catch
        samp_ind = randperm(EEG.pnts*EEG.trials);
        samp_ind = samp_ind(1:n_samp);
    end
    if ~isempty(EEG.icachansind)
        icachansind = EEG.icachansind;
    else
        icachansind = 1:EEG.nbchan;
    end
    datavar = mean(var(EEG.data(icachansind, samp_ind), [], 2));
    projvar = mean(var(EEG.data(icachansind, samp_ind) - ...
        EEG.icawinv(:, j) * icaacttmp(1, samp_ind), [], 2));
    pvafval = 100 *(1 - projvar/ datavar);
    pvaf = num2str(pvafval, '%3.1f');
    temporaryList = {pvaf};
    finalList = cat(1, finalList, temporaryList);
end

PercentBrainAccountedFor_Total = 0;
for a =1:content % This will only count the first X components
    PercentBrainAccountedFor_Comp = EEG.etc.ic_classification.ICLabel.classifications(a,1)*str2double((finalList{a,1}));
    PercentBrainAccountedFor_Total = PercentBrainAccountedFor_Total + PercentBrainAccountedFor_Comp;
end
end