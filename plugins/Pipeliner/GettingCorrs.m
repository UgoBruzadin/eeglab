
AA = [];
BB = [];
CC = [];

% for i =1:size(EEG.icawinv,2)
% for j = 1:size(EEG.icawinv,2)
% AA = corr(EEG.icawinv(:,i),EEG.icawinv(:,j))
% end
% end

for i =1:size(EEG.icawinv,2)
    for j = 1:size(EEG.icawinv,2)
        AA = corr(EEG.icawinv(:,i),EEG.icawinv(:,j))
        AA = cat(1,AA,corr(EEG.icawinv(:,i),EEG.icawinv(:,j)))
        BB = cat(1,BB,num2str(i))
        CC = cat(1,CC,num2str(j))
    end
end
corrcoef(EEG.winv)
corrcoef(EEG.icawinv)
corrcoef(EEG.icaact)
corrcoef(EEG.icaact(7,:,:),EEG.icaact(14,:,:))
corrcoef(EEG.icaact(1,:,:),EEG.icaact(7,:,:))
corrcoef(EEG.icawinv)