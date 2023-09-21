function EEG = outlierChannelsPerEpoch(EEG,sdv)
if nargin < 2
    sdv = 3;
end

MeanEpoch = mean(EEG.data(:,:,:),2);
SdvEpoch = std(EEG.data(:,:,:),2);

MeanEpoch2 = reshape(MeanEpoch,size(EEG.data,1),size(EEG.data,3));
OutlierMean = outlier(MeanEpoch2,3);

% --- find non-zeros, interpolate channels just for those 

end