devStd = std(EEG.data(:,:), [], 2);

if any(devStd == 0)
    flatchan = find(devStd < 0.1)';
end

if any(devStd == 0)
    xtremechan = find(devStd > 1000)';
end

numberOfSurroundingChannels = 5;

AllChansLocation = EEG.chanlocs;

xelec = [ AllChansLocation.X ];
yelec = [ AllChansLocation.Y ];
zelec = [ AllChansLocation.Z ];
% --- make it into three columns
chanLocMatrix = [xelec',yelec',zelec'];

% --- searches for the K closest neighbors in 3D space
surrChans = knnsearch(chanLocMatrix,chanLocMatrix,'K',numberOfSurroundingChannels);
% --- removes itself from the list
surrChans(:,1) = [];
    

% --- FINDING UNCORRELATED TIME-PERIODS

% --- defining variables for each period
timePeriod = 0.5; %(in seconds)
binSize = EEG.srate*timePeriod; % in bins (4 seconds)
redundancy = 0; % in bins (1 second)

% --- calculates how many correlations are going to be run

numberOfSections = ceil(size(EEG.data,2)/binSize);

% trying to add redundancy
% --- empty array to store the correlations of each period
finalCorr = zeros(EEG.nbchan,numberOfSections);
finalStd = zeros(EEG.nbchan,numberOfSections);
% --- empty array to store the beggining and end of each period
corrPeriodStart = zeros(EEG.nbchan,numberOfSections);
corrPeriodEnd = zeros(EEG.nbchan,numberOfSections);

for channel = 1:EEG.nbchan
    count = 0;
    chanData = EEG.data(channel,:);
    surrData = EEG.data(surrChans(channel,:),:);
    %compositeData = mean(surrData);
    red = 0; %for redundancy
    for period = 1:numberOfSections-1
        % for redundancy
        % if this is first trial, no redundancy
        if period == 1
            red = 0;
            beg = 0;
        else
            red = redundancy;
            beg = 1;
        end
        % --- a and b refer to the beggining and end of the period
        
        %binPeriod = binPeriod-20;
        a = period-red; b = (period+1)*binSize;
        if b > size(EEG.data,2)
            b = size(EEG.data,2);
        end
        % --- computes the correlation bewteen the two data
        thisStd = std(chanData(a:b), [], 2);
        
        thisCorr = corrcoef(chanData(a:b),compositeData(a:b));
        
        % --- stores it in the correlation array
        
        finalCorr(channel,period) = thisCorr(1,2);
        
        finalStd(channel,period) = thisStd;
        
        % --- stores the period in the array
        corrPeriodStart(channel,count) = [a];
        corrPeriodEnd(channel,count) = [b];
    end
end