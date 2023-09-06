newname = {};
freq = {'theta','alpha','beta'};

for i=1:19
    for j=1:3
        newname{end+1} = strcat(string(freq(j)),string(A{i}));
    end
end



DATA = renamevars(DATA,26:82,[newname{:}])