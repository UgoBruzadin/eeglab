function [power,frequency] = getPlotPoint()
    %p  = get(hobj,'currentpoint'); % get coordinates of click
    
    %disp(p);
    
    %get mouse data X and y
    
    %get closest line
    
    %display data point X and Y.
    
% function getPoint(src, eventdata, x, y)
currentPoint = get(gca, 'CurrentPoint');
power = currentPoint(1,2);
frequency = currentPoint(1,1);

set(findobj(gcf,'Tag','power'),'String',power)
set(findobj(gcf,'Tag','freq'),'String',frequency)


%     
%     
%     d = pdist2([x y],p([1 3]));    % find combination of distances
%     [~,ix] = min(d);               % find smallest distance
%     line(x(ix),y(ix),'linestyle','none','marker','o')
%     [x(ix),y(ix)]