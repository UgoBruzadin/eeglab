function pipe_icfigures(files,EEG) %maybe fixed by ugo 2/3/2020 7:15pm
    IC = size(EEG.icaweights,1);
    pop_topoplot(EEG, 0, [1 : size(EEG.icaweights,1)] ,'Neuroscan EEG data pruned with ICA epochs resampled',[6 8] ,0,'electrodes','off');
    saveas(gcf,[strcat(files.name(1:end-4),'_PCS.jpg')]);
    close all;
    fprintf('saving components figures')
end