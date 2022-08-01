function [EEG,com] = quick_icrej(EEG, percent)
com = '';
if nargin < 2
    percent = 0.8;
else
    if iscell(percent)
        percent = percent{:};
    end
end

if isempty(EEG.icaact)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
end
%if isempty(EEG.etc.ic_classification.ICLabel.classifications)
[EEG] = pop_par_iclabel(EEG, 'default');
%end
IC = size(EEG.icaweights,1);

[EEG] = pop_par_icflag(EEG, [NaN NaN;percent 1;percent 1;percent 1;NaN NaN;NaN NaN;NaN NaN]);

%                          'Brain''Muscle''Eye''Heart''Line Noise''Channel Noise''Other' };
%EEG = pop_par_icflag(EEG, [NaN NaN;flag 1;flag 1;flag 1;flag 1;flag 1;NaN NaN]);
mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected

% %EEG = pop_par_iclabel(EEG, 'default');
%  if mybadcomps
%      EEG = pop_par_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
%      %acronym = char(strcat('PcRj',num2str(size(mybadcomps,1)))); %the acronym to be passed along to be added to the name of the file
%  else
%      %acronym = 'PcRj0';
%  end

end