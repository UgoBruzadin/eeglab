function [EEG] = pop_epochintbycompsbyvar(EEG,components,sdv)

if nargin < 3
    sdv = 3;
end

if nargin < 2
    components = find(EEG.reject.gcompreject);
    if components
    else
        fprintf('No components rejected /r');
        return;
    end
end
    
% --- make a copy of EEG
EEG1 = EEG;

FinalFlags(size(components,1),EEG.trials) = zeros();
FinalFlagsT = [];

for i=1:length(components)

    % --- identify the bad trials
    
    % --- collects the V variance for each trial of the component
    V = var(EEG.icaact(components(i),:,:));
    V = reshape(V,1,size(V,3));
    % --- gets the S sum of the variance (i.e. total variance)
    S = sum(V,2);
    % --- calculates C contributing variance for each trial
    C = (S - V)/S;
    % --- reshapes it in an array of lenght C
    C = reshape(C,1,length(C));
    % --- calculates the Z score for that array
    Z = zscore(C);
    % --- makes an array bols of the trials which fair above absolute 3 SDVs
    FlagV = abs(Z) > sdv;
    % --- finds the trial numbers flagged above
    FlagsV = find(FlagV);
    % --- passes the flagged trials to upper variable
    FinalFlags(i,:) = FlagV;
    %FinalFlagsT = cat(1,FinalFlagsT,FlagsV);
end

trialsSum = sum(FinalFlags,1);
TrialsforRj = find(trialsSum);

if TrialsforRj
    for j = TrialsforRj
        % --- find components rejected for every trial
        FlagsCom = find(FinalFlags(:,j));
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
% if FlagsCom %NEEDS FIXING
%     EEG = pop_saveset(EEG);
% else
%     fprintf(strcat('No changes occurred /r'));
% end
%     EEG = pop_loadset(EEG);
 end
