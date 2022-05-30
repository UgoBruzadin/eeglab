function getPlotPoint(hobj)
    p  = get(hobj,'currentpoint'); % get coordinates of click
    
    disp(p);
    
    %get mouse data X and y
    
    %get closest line
    
    %display data point X and Y.
    
    
    
    d = pdist2([x y],p([1 3]));    % find combination of distances
    [~,ix] = min(d);               % find smallest distance
    line(x(ix),y(ix),'linestyle','none','marker','o')
    [x(ix),y(ix)]