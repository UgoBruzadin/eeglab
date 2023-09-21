

% 
% A = EEG.icaact(20,:);
% B = EEGa.icaact(17,:);
% C = corrcoef(A',B');
% 


A = reshape(EEG.icaact,128,[]);

C = corrcoef(A');
CV = cov(A');

% tldr doesnt work, corr/cov are too small