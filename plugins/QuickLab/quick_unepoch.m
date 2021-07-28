function EEG1 = quick_unepoch(EEG)

EEG1 = EEG;

EEG1 = pop_selectevent( EEG1, 'omittype',{'X'},'deleteevents','on','deleteepochs','off','invertepochs','off');

if EEG1.trials > 1

EEG1.data = EEG.data(:,:);
EEG1.xmax = EEG.trials*EEG.pnts;
if ~isempty(EEG.icaact)
    EEG1.icaact = EEG.icaact(:,:);
    %EEG.icaact = reshape(EEG.icaact , EEG.nbchan, EEG.trials*EEG.pnts);
end
EEG1.pnts = EEG1.xmax;
EEG1.epoch = [];
EEG1.urevent = EEG.event;
EEG1.times = 1:EEG.trials*EEG.pnts;
EEG1.trials = 1;

else
    fprintf('Nothing done. File is already in continuous shape \r');
end

end