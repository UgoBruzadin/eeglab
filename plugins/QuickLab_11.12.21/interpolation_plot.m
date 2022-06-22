% 
% figure; fh = uipanel("Position",[0 0 1 1]);
% 
% imshow(g.winrej(:,6:end)','InitialMagnification','fit')

function interpolation_plot(g)

EEG = g.EEG;
axes('Parent', gcf, 'position',[ 0.92    0.31    0.080    0.10 ],'units','normalized');

bads = g.winrej(6:end);

forplot_bads = double(~bads);
forplot_bads(:,bTrial_ind) = EEG.trials + 1;
for tr = 1:EEG.trials
    forplot_bads(bads(:,tr),tr) = tr;
end
forplot_bads(bChan_ind,:) = EEG.trials + 1;

%figure; imagesc(forplot_bads);
imagesc(forplot_bads);
colormap([1 1 1; rand([EEG.trials 3]); [1 .25 .25]])
title('Bad channels by trial')
%xlabel('Trial'); ylabel('Channel');
yticks(1:EEG.nbchan); yticklabels({EEG.chanlocs.labels});
annotation('textbox', [0.1, 0.07, 0, 0],...
    'String', 'Each trial is marked by a color. Red lines indicate a channel or trial that will be completelty removed. ',...
    'FitBoxToText', 'on', 'LineStyle', 'none');
