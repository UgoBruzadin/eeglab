function checkBox(index)

A = get(findobj(gcf,'Tag',int2str(index)),'Value');

set(findobj(gcf,'Tag',int2str(index)),'Value', abs(A-1))

end

