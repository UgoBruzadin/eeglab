  
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
    
    % --- FINDING ABSURD CHANNEL SPIKES
    % --- creates an empty array for
    finalDiff = zeros(size(EEG.data));
    finalFlags = [];
    tempFlags = zeros(1,3);
    probChans = [];
    finalFlags = [];
    dEEG = EEG;
    for chan=1:EEG.nbchan
        
        chanData = EEG.data(chan,:);
        otherData = EEG.data(surrChans(chan,:),:);
        
        % --- method 1: difference i.e. spike difference
        
        threshold = 500; %in mV
        
        % FINDS SPIKES IN the VS SURROUNDING chans for given threshold
        chanDiff = chanData - otherData;
        meanDiff = mean(chanDiff,1);
        %the secret was make it absolute
        sortData = sort(abs(otherData));
        sortData2 = sortData;
        sortData2(4,:) = [];
        chanDiff2 = chanData - sortData2;
        meanDiff2 = mean(chanDiff2,1);
        minDiff = min(chanDiff,[],1);
        dEEG.data(chan,:) = meanDiff2;
    end
    
    eegplot_w(dEEG.data);
    