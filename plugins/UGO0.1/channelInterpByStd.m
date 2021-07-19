function EEG = channelInterpByStd(EEG,sdv)
if nargin < 2
    sdv = 3;
end

out = outlier(EEG.data,sdv);

outliers = sum(out,2);

outliersR = reshape(outliers,size(outliers,1),size(outliers,3));

end
