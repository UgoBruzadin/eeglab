function [EEG] = channelIntByComps(EEG,sdv,components)
if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end
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
ChansForInterp = transpose(nonzeros(unique(uniqueOutlierChans)));

if ChansForInterp
    fprintf(strcat('Marked channels ',strcat(num2str(ChansForInterp)), '/r'));
    EEG = pop_interp(EEG, [ChansForInterp], 'spherical');
else
    fprintf(strcat('no channels marked above ',num2str(sdv), '/r'));
end

%EEG.reject.gcompreject = [];
end
