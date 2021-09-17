function EEG = trialrejprob(EEG,sdv)

if nargin < 2
   sdv = 5;
end

EEG = pop_jointprob(EEG,1,[1:99],sdv,sdv,0,0,0,[],0);

EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);

MYREJ = find(EEG.reject.rejjp);

if MYREJ
    EEG = pop_rejepoch( EEG, MYREJ ,0);
else
    fprintf('No trials Rejected');
end
end
