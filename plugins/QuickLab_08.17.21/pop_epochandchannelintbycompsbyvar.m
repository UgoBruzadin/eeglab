function [EEG] = pop_epochandchannelintbycompsbyvar(EEG,sdv,components)

if nargin < 2
    sdv = 1;
end

if nargin < 3
    % --- get channel outliers by components given specific sdv
    outlierChansbyComps = outlier(EEG.icawinv,sdv);
    % --- make empty arrays to fill
    allOutlierChans = cell(1,size(outlierChansbyComps,2));
    uniqueOutlierChans = zeros(1,size(outlierChansbyComps,2));
    % --- loops for all components
    for j=1:size(outlierChansbyComps,2)
        % --- Get the channel numbers from the outliers
        allOutlierChans(j) = {find(outlierChansbyComps(:,j))};
        % --- If theres only one channel
        if size(cat(1,allOutlierChans{j}),1)==1
            % --- Collects that 1 channel number
            uniqueOutlierChans(j) = allOutlierChans{j};
        end
    end
end

% --- to be added: option to preselect the channels & components to be interpolated

% --- gets all unique channels to be interpolated
channelsToInterpolate = transpose(nonzeros(unique(uniqueOutlierChans)));

for k = channelsToInterpolate
    FlagsCom = find(uniqueOutlierChans==k);
    EEG1 = EEG;
    EEG1 = pop_subcomp(EEG1,FlagsCom);
    % --- basically interpolates channels from component removals
    % --- if there are any trial flagged, imputes those trials!
    % --- substitutes the specified epochs from the copy
    fprintf(strcat(' Rejected components _',strcat(num2str(FlagsCom)),'from channel_', strcat(num2str(k)), '/r'));
    EEG.data(channelsToInterpolate,:,:) = EEG1.data(channelsToInterpolate,:,:);
end

%EEG.reject.gcompreject = [];
end
