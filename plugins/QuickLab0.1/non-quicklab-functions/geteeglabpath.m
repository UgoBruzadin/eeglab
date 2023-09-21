function folder = geteeglabpath()

folder = [];

fullpaths = path;
A = strfind(fullpaths,'eeglab;');
if A
B = strfind(fullpaths,';');
C = B < A;
if find(C)
    D = B(max(find(C)));
    E = B(max(find(C))+1);
    folder = fullpaths(D+1:E-1);
else
    folder = fullpaths(1:B(1)-1);
end
end
end