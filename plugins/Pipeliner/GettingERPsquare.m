

%for j = 1:size(EEG.icaact,1)
%pop_erpimage( EEG, typeplot, channel, projchan, titleplot, smooth, decimate, sortingtype, ...
%            sortingwin, sortingeventfield, varargin)
    
%     [DataInFigure] = pop_erpimage(EEG,0,[31],[[]],'Comp. 1',1,1,{},[],'',...
%     'yerplabel','','erp','on','cbar','on','topo',{ mean(EEG.icawinv(:,[31]),2)...
%     EEG.chanlocs EEG.chaninfo } );

    [DataInFigure] = pop_erpimage(EEG,0,[31],[[]],'Comp. 1',1,1,{},[],'',...
    'yerplabel','','erp','on','cbar','on','topo',{ mean(EEG.icawinv(:,[31]),2)...
    EEG.chanlocs EEG.chaninfo } );

%end
%pop_erpimage( EEG, typeplot, channel, projchan, titleplot, smooth, decimate, sortingtype, ...
%            sortingwin, sortingeventfield, varargin)
% 
% DatatoCorrlate = []
% 
% FirstRun = 1;
% for i=1:size(DataInFigure)
%     if FirstRun == 1
%         %DatatoCorrlate = (i,:);
%         FirstRun = 0;
%     else
%         CurrentIndex = DataInFigure(i,:);
%         DatatoCorrlate = [DatatoCorrlate CurrentIndex];
%     end
% end
