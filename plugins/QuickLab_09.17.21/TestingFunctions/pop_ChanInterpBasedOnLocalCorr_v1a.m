function EEG = pop_ChanInterpBasedOnLocalCorr_v1a(EEG,CorrThreshold)

    % pop_eegplotMG( EEG, 1, 1, 1);
    % ExcelSheetStart{i,1} = file1(i).name(1:16);
    % EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}));
    
    if nargin < 2
        CorrThreshold = .6;
    end
    % --- get channel information
    AllChansLocation = EEG.chanlocs;
    xelec = [ AllChansLocation.X ];
    yelec = [ AllChansLocation.Y ];
    zelec = [ AllChansLocation.Z ];
%     % --- Count CorrCoef
%     Corr50to60 = 1;
%     Corr60to70 = 1;
%     Corr70to80 = 1;
%     Corr80to90 = 1;
%     Corr90to100 = 1;
    % --- not sure
    DataMarktoCell = 1;
    % --- loops all epochs
    
    EEG.ChannelClusterCorrelations = zeros(EEG.nbchan,EEG.trials);
    EEG.AbnormalChannelss = zeros(EEG.nbchan,EEG.trials);
    
    
    for Epoch=1:size(EEG.data,3)
        % --- gets current epoch, probably unnecessary/redundant code
        CurrentEpoch = (EEG.data(:,:,Epoch));
        clear localAvgList
        DataMarktoCell = 1;
        % --- loops all channels
        for Channel=1:size(CurrentEpoch,1)
            % --- CompareChannels?
            ListOfSurroundingChannels = [];
            ListOfChannelNumber = 1;
            localAvgListTrigger = 1;
            
            % --- gets the location of the current channel
            CenterOfChannelClusterX = xelec(1,Channel);
            CenterOfChannelClusterY = yelec(1,Channel);
            CenterOfChannelClusterZ = zelec(1,Channel);
            %--- calculates the radius around that channel
            RadiusOfCluster = sqrt(sqrt(CenterOfChannelClusterX^2+CenterOfChannelClusterY^2+CenterOfChannelClusterZ^2));
            % --- calculates plus and minus range in all 3Ds
            RadiusOfInterestXRange1 = CenterOfChannelClusterX(1,1) - RadiusOfCluster;
            RadiusOfInterestXRange2 = CenterOfChannelClusterX(1,1) + RadiusOfCluster;
            
            RadiusOfInterestYRange1 = CenterOfChannelClusterY(1,1) - RadiusOfCluster;
            RadiusOfInterestYRange2 = CenterOfChannelClusterY(1,1) + RadiusOfCluster;
            
            RadiusOfInterestZRange1 = CenterOfChannelClusterZ(1,1) - RadiusOfCluster;
            RadiusOfInterestZRange2 = CenterOfChannelClusterZ(1,1) + RadiusOfCluster;
            
            % --- gets the smallest as min and biggest as max
            if RadiusOfInterestXRange1 > RadiusOfInterestXRange2
                XmaxRadius = RadiusOfInterestXRange1;
                XminRadius = RadiusOfInterestXRange2;
            else
                XmaxRadius = RadiusOfInterestXRange2;
                XminRadius = RadiusOfInterestXRange1;
            end
            if RadiusOfInterestYRange1 > RadiusOfInterestYRange2
                YmaxRadius = RadiusOfInterestYRange1;
                YminRadius = RadiusOfInterestYRange2;
            else
                YmaxRadius = RadiusOfInterestYRange2;
                YminRadius = RadiusOfInterestYRange1;
            end
            if RadiusOfInterestZRange1 > RadiusOfInterestZRange2
                ZmaxRadius = RadiusOfInterestZRange1;
                ZminRadius = RadiusOfInterestZRange2;
            else
                ZmaxRadius = RadiusOfInterestZRange2;
                ZminRadius = RadiusOfInterestZRange1;
            end
            
            for CheckChanList=1:size(xelec,2)
                if xelec(1,CheckChanList) < XmaxRadius && xelec(1,CheckChanList) > XminRadius && ...
                        yelec(1,CheckChanList) < YmaxRadius && yelec(1,CheckChanList) > YminRadius && ...
                        zelec(1,CheckChanList) < ZmaxRadius && zelec(1,CheckChanList) > ZminRadius && ...
                        Channel ~= CheckChanList
                    
                    ListOfSurroundingChannels(1,ListOfChannelNumber) = CheckChanList;
                    ListOfChannelNumber = ListOfChannelNumber + 1;
                    if localAvgListTrigger == 1
                        localAvgList = (EEG.data(CheckChanList,:,Epoch));
                        localAvgListTrigger =0;
                    else
                        CurrentlocalAvgList = (EEG.data(CheckChanList,:,Epoch));
                        localAvgList = [localAvgList ; CurrentlocalAvgList];
                    end
                end  
            end
            for IsSurroudingDataValid0=1:size(localAvgList,1) 
                %--- This section looks for outliers in the surrounding
                %---- electrodes and removes them from the average
                CorrelateSurroundTrigger = 1;
                for Data1Compare=1:size(localAvgList,1)     
                     Data1Corr = corrcoef(localAvgList(IsSurroudingDataValid0,:),localAvgList(Data1Compare,:)); 
                     if Data1Corr(1,2) >= 0.6 && Data1Corr(1,2) <= 1
                         if CorrelateSurroundTrigger == 1
                         localAvgListFinal = localAvgList(Data1Compare,:);   
                         CorrelateSurroundTrigger = 0;                         
                         else                        
                         localAvgListCurrent = localAvgList(Data1Compare,:); 
                         localAvgListFinal = [localAvgListFinal;localAvgListCurrent ];
                         end
                     else
                         lol = 0;
                     end       
                     
                end
                if size(localAvgListFinal) > 1
                    break
                end  
            end
            
            lol = size(localAvgListFinal,1) - size(localAvgList,1);
            if abs(lol) > 0              
               lol =0 ;
            end
            AvgERPforCORR = mean(localAvgListFinal,1);
            IsChanBad = corrcoef((EEG.data(Channel,:,Epoch)),AvgERPforCORR);
            EEG.ChannelClusterCorrelations(Channel,Epoch) = IsChanBad(1,2);
            
%             if IsChanBad(1,2) > .50 && IsChanBad(1,2) < .60
%                 Corr50to60 = Corr50to60 + 1;
%             end
%             if IsChanBad(1,2) > .60 && IsChanBad(1,2) < .70
%                 Corr60to70 = Corr60to70 + 1;
%             end
%             if IsChanBad(1,2) > .70 && IsChanBad(1,2) < .80
%                 Corr70to80 = Corr70to80 + 1;
%             end
%             if IsChanBad(1,2) > .80 && IsChanBad(1,2) < .90
%                 Corr80to90 = Corr80to90 + 1;
%             end
%             if IsChanBad(1,2) > .90 && IsChanBad(1,2) < 1
%                 Corr90to100 = Corr90to100 + 1;
%             end
%             
%             if Epoch == 39
%                 lol=0 ;
%             end
            
%             IntripTriggered = 0;
%             if IsChanBad(1,2) < CorrThreshold %This just looks at the correlation
%                 IntripTriggered = 1;
%                 if DataMarktoCell == 1
%                     AllCompDataChannel = string(Channel);
%                     AllCompDataEpoch = string(Epoch);
%                     DataMarktoCell = 0;
%                 else
%                     CurrentData = string(Channel);
%                     AllCompDataChannel =  strcat(AllCompDataChannel,',',CurrentData);
%                     CurrentData = string(Epoch);
%                     AllCompDataEpoch = strcat( AllCompDataEpoch,',',CurrentData);
%                 end
%             else %This just looks at 60ms chunks comparing the Avg ERP of local electrodes to the current channel
%                 Chunk = floor(60/(((abs(EEG.xmin)+abs(EEG.xmax))*1000)/EEG.pnts));
%                 TotalChunks = floor(EEG.pnts/Chunk);
%                 FirstChunkRun = 1;
%                 for RatioTest = 1:(TotalChunks)
%                     if FirstChunkRun == 1
%                         RatioData1 = EEG.data(Channel,1:Chunk,Epoch);
%                         RatioData2 = AvgERPforCORR(1,1:Chunk);
%                         FirstChunkRun =0 ;
%                     elseif abs(floor(EEG.pnts/Chunk)-(EEG.pnts/Chunk)) >0 && RatioTest == TotalChunks
%                         %This is for if the epoch does not slpit into 60ms
%                         %This will just compare the last remaining ms of the epoch
%                         RatioData1 = EEG.data(Channel,(Chunk*(RatioTest-1)):end,Epoch);
%                         RatioData2 = AvgERPforCORR(1,(Chunk*(RatioTest-1)):end);
%                     else
%                         RatioData1 = EEG.data(Channel,(Chunk*(RatioTest)):(Chunk*(RatioTest+1)),Epoch);
%                         RatioData2 = AvgERPforCORR(1,(Chunk*(RatioTest)):(Chunk*(RatioTest+1)));
%                     end
%                     %Ratio = mean(RatioData1)/mean(RatioData2);
%                     Ratio = (RatioData1)/(RatioData2);
%                     if Ratio >3
%                         IntripTriggered = 1;
%                     end
%                 end
%             end
            
%             if IntripTriggered == 0 %This scan 60ms chunks to find large difference
%                 Chunk = floor(60/(((abs(EEG.xmin)+abs(EEG.xmax))*1000)/EEG.pnts));
%                 for StartEEGPoint = 1:(EEG.pnts-Chunk)
%                     Data1 = EEG.data(Channel,StartEEGPoint:(StartEEGPoint+Chunk-1),Epoch);
%                     LargeDifference = abs(min(Data1+500)-(max(Data1+500)));
%                     if round(LargeDifference) > 60
%                         IntripTriggered = 1;
%                     end
%                 end
%             end
%             
%             if IntripTiggered == 0 
%             CorCheckWithPrevousEpoch = corrcoef(EEG.data(Channel,:,Epoch), EEG.data(Channel,:,(Epoch-1)));
%             if CorCheckWithPrevousEpoch(1,2) < CorrThershold
%             end
%             if IntripTriggered == 1
%                 EEGIntrip = EEG;
%                 EEGIntrip = pop_interp(EEGIntrip, Channel, 'spherical');
%                 EEG.data(Channel,:,Epoch) = EEGIntrip.data(Channel,:,Epoch);
%                 IntripTriggered = 0;
%                 if DataMarktoCell == 1
%                     AllCompDataChannel = string(Channel);
%                     %AllCompDataChannellist = Channel;
%                     AllCompDataEpoch = string(Epoch);
%                     DataMarktoCell = 0;
%                 else
%                     CurrentData = string(Channel);
%                     AllCompDataChannel =  strcat(AllCompDataChannel,',',CurrentData);
%                     %AllCompDataChannellist = [AllCompDataChannellist Channel];
%                     CurrentData = string(Epoch);
%                     AllCompDataEpoch = strcat( AllCompDataEpoch,',',CurrentData);
%                 end
%             else
%                 IntripTriggered = 0;
%             end
            
        end
    end
    
    %  EEG = pop_saveset(EEG, 'filename', [file1(i).name(1:end-4), '_FIbE.set'], 'filepath',fileOUTPUT2);
    %  ExcelSheetStart{i,2} = AllCompDataChannel;
    %  ExcelSheetStart{i,3} = AllCompDataEpoch;
    %  pop_eegplotMG( EEG, 1, 1, 1);
end


% t = datestr(now, 'mm_dd_yyyy-HHMM');
% t = string(t);
% Report_Name = strcat('Test_', t(1,1), '.xlsx');
% xlswrite(Report_Name,ExcelSheetStart);



%             if IsChanBad(1,2) < CorrThershold
%                 %pop_eegplot( EEG, 1, 1, 1);
%
%                 figure;
%                 axes('Position',[-.05 .7 .2 .2])
%                 figure;topoplot([Channel 129], EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'electrodes','off', 'style', 'blank', 'emarkersize1chan', 12);
%                 figure;plot(localAvgList')
%                 legend('location','southoutside');
%                 movegui('northwest')
%                 figure;plot(EEG.data(Channel,:,Epoch))
%                 legend('location','southoutside');
%                 movegui('northeast')
%                 figure;plot(AvgERPforCORR);
%                 movegui('north')
%                 EEGIntrip = EEG;
%                 EEGIntrip = pop_interp(EEGIntrip, Channel, 'spherical');
%                 Differ = EEG.data(Channel,:,Epoch)-EEGIntrip.data(Channel,:,Epoch);
%                 figure;plot(Differ)
%                 movegui('southeast')
%                 figure;plot(EEGIntrip.data(Channel,:,Epoch));
%                 movegui('south')
%                 EEG.data(Channel,:,Epoch) = EEGIntrip.data(Channel,:,Epoch);
%
%                 %figure;topoplot( ListOfChanERP, EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'electrodes','off', 'style', 'blank', 'emarkersize1chan', 12);
%                 figure;topoplot([Channel 129], EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'electrodes','off', 'style', 'blank', 'emarkersize1chan', 12);
%                 movegui('south')
%                 delete EEGIntrip
%                 close all
%             else
%                 Sec_per_Point = (EEG.srate/EEG.pnts);% seconds per point
%             end

