function pop_viewprops2_checkbox(index)

% --- click or unclick the tag
clickVal = get(findobj(gcf,'Tag',int2str(index)),'Value');

set(findobj(gcf,'Tag',int2str(index)),'Value', abs(clickVal-1));

% --- turn button color red or green

clickVal = abs(clickVal-1);

if clickVal == 1
    %set(findobj(gcf,'Style','checkbox'),'BackgroundColor',[1 .5 .5])
    set(findobj(gcf,'Tag',strcat('comp',int2str(index))),'BackgroundColor',[1 .5 .5])
else
    %set(findobj(gcf,'Style','checkbox'),'BackgroundColor',[.75 1 .75])
    set(findobj(gcf,'Tag',strcat('comp',int2str(index))),'BackgroundColor',[.75 1 .75])
end

end

