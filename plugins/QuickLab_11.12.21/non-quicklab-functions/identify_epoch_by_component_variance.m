function EEGOUT = remove_epoch_by_component_variance(EEGIN)

A = [var(EEGIN.icaact(:,:,:),1,[1 2])];
B = reshape(A,1,[]);
[C,I] = sort(B);
outlier(C,1.5);




