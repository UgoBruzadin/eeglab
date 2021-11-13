function epoch_component_interpolation(EEG,TrialsforRj,components)

if TrialsforRj
    for j = TrialsforRj
        % --- find components rejected for every trial
        FlagsCom = components;
        % --- reject the components
        EEG1 = EEG;
        EEG1 = pop_subcomp(EEG1,components(FlagsCom));
        % --- basically interpolates epochs from component removals
        % --- if there are any trial flagged, imputes those trials!
        % --- substitutes the specified epochs from the copy
        
        if FlagsCom
            fprintf(strcat(' Rejected trials _', strcat(num2str(j)), ' from component _', strcat(num2str(FlagsCom))), '\r');
            EEG.data(:,:,j) = EEG1.data(:,:,j);
        else
            fprintf(strcat('No components rejected r'));
        end
    end
EEG.reject.gcompreject = [];
end