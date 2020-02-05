function pipe_icfigures(files,EEG) %maybe fixed by ugo 2/3/2020 7:15pm
    IC = size(EEG.icaweights,1);
    if size(EEG.icaweights,1) > 35
        IC = 35;
    end
    pop_topoplot(EEG, 0, [1:IC] ,'Neuroscan EEG data pruned with ICA epochs resampled',[5 6] ,0,'electrodes','off');
    saveas(gcf,[strcat(files.name(1:end-4),'_35-ICS.jpg')]);
    close all;
    fprintf('saving components figures')
end