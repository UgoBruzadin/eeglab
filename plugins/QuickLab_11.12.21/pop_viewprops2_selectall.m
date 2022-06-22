function pop_viewprops2_selectall(value)

% --- click or unclick the tag
%clickVal = get(findobj(gcf,'Style','checkbox));

set(findobj(gcf,'Style','checkbox'),'Value', value);

% --- turn button color red or green

clickVal = abs(value);

% --- get all component buttons
all_buttons = findobj(gcf,'Style','pushbutton');
% --- 9 is the number of buttons on the end of the page! If I add more buttons
% IF I AD MORE BUTTONS 9 NEEDS TO CHANGE!

comp_buttons = all_buttons(9:end);

if clickVal == 1
    %set(findobj(gcf,'Style','checkbox'),'BackgroundColor',[1 .5 .5])
    set(comp_buttons,'BackgroundColor',[1 .5 .5])
else
    %set(findobj(gcf,'Style','checkbox'),'BackgroundColor',[.75 1 .75])
    set(comp_buttons,'BackgroundColor',[.75 1 .75])
end

end

