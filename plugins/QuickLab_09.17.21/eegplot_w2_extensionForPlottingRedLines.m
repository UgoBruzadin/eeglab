
%STARTS AT Line 1665 OF EEGPLOT_W2
if ~isempty(g.winrej)
    %tmp_plot_data_x=1:length(lowlim:highlim);
    theresbaddata = 0;
    %tmppos_x=mouse_near_boundary_correction(g.badchannel(tmppos(1))+lowlim,g);
    tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim,highlim);
    highlim2 = 0;
    lowlim2 = lowlim;
    %plot(ax1,tmp_plot_data_y', 'color', g.color{1}, 'clipping','on');
    for j=1:size(g.winrej,1)
        if g.winrej(j,1) >= lowlim && g.winrej(j,1) <= highlim
            theresbaddata = theresbaddata+1;
            lowlim2(end+1) = g.winrej(j,1);
            if g.winrej(j,2) < highlim
                highlim2(end+1) = g.winrej(j,2);
            else
                highlim2(end+1) = highlim;
            end
        end
    end
    %CREATE A UNIQUE LIST OF LIMITS, ENDS AND STARTS ON RED OR BLACK
    if theresbaddata > 0
        
        for l=length(lowlim2):-1:1
            %plot red part
            tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim2(l),highlim);
            plot(ax1,tmp_plot_data_y', 'color', [ 1 0 0 ], 'clipping','on');
            %plot blue part
            tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim2(1),lowlim);
            plot(ax1,tmp_plot_data_y', 'color', g.color{1}, 'clipping','on');
        end
    else
        tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim,highlim);
        plot(ax1,tmp_plot_data_y', 'color', g.color{1}, 'clipping','on');
    end
    % plot the rest
    tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim,highlim2);
    %plot(ax1,tmp_plot_data_y', 'color', [ .85 .85 .85 ], 'clipping','on');
    %plot(ax1,tmp_plot_data_y', 'color', [ 1 0 0 ], 'clipping','on');
    for i = chans_list_bad
        line_params = ...
            {1,mean(i*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing),2),...
            'Marker','<','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6,...
            'clipping','off','userdata',g.chans-i+1,'ButtonDownFcn',{@MarkChannel,figh,g.chans-i+1}};
        if verLessThan_matlab_9
            line(line_params{:})
        else
            line(ax1,line_params{:});
        end;
    end
end;