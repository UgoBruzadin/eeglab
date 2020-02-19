function [EEG, acronym] = pipe_iclabel(commands, EEG)
    %------ pipeliner.iclabel({loop, flag},EEG
    
    if size(EEG.icaweights,1) == 0
        EEG = pop_runica(EEG, 'extended',1,'pca',45,'verbose','off');
    end
    
    IC = size(EEG.icaweights,1);
    oldEEG = EEG;
    %IC2 = size(EEG.icaweights,1);
    loop = table2array(commands(1));
    for j=1:loop
        flag = table2array(commands(2));
        %------ run IC label & flag 
        EEG = pop_iclabel(EEG, 'default');
        EEG = pop_icflag(EEG, [NaN NaN;flag 1;flag 1;flag 1;flag 1;flag 1;NaN NaN]);
        
        %------ store components and update component number
        mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected
        IC = IC - length(mybadcomps);            %stores the number to be the next components analysis
        %------- reject flagged components
        EEG = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
        %------- PCA reduction & break if limit reached
%         if size(EEG.icaweights,1) <= table2array(cut(2)) %stops the loop when the number given in the command line
%             break
%         else
        
        IC = IC - 1;                    % makes the next PCA of 1 number smaller.
        %end
        %------- run new relative PCA
        try EEG = pop_runica(EEG,'extended',1,'pca',IC,'verbose','off'); %does a PCA of IC
        catch EEG = pop_runica(EEG,'extended',1,'pca',IC,'verbose','off'); %BUG: it looks likes it picks up the wrong binica files. inconsistent error.
        end

        %------ reset IC2, which is the last highest component #
        if ~isempty(mybadcomps)              %if any components are removed, the IC2 stores the last time a pca removed a comp.
            %IC2 = IC;               %reset the original IC number so we can go back in case no components are removed later on.
            oldEEG = EEG;
        end
    end
    %------- return to last highest component, store acronym
    EEG = oldEEG;
    EEG = pop_iclabel(EEG, 'default');
    %EEG = pop_runica(EEG, 'extended',1,'pca',IC2-1,'verbose','off'); %runs a PCA to the last num of ICs since a component was removed
    acronym = char(strcat('Pc',num2str(size(EEG.icaweights,1)))); %the acronym to be passed along to be added to the name of the file
end