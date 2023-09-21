


%[ allfiles ] = GetAllDirFiles(pwd, '');
%allfiles(ismember({allfiles.name},{'.','..'})) = [];

%T = readtable('E:/N5DLListINFO.xls');

allids = table2array(N5DLListINFO(:,1));
allids2 = table2array(ACCMATLAB(:,1));

for i=1:size(allids2,1)

    ID = [];
    try ID = find(allids==allids2(i)); catch; end

    if ~isempty(ID)
        ACCMATLAB(i,4) = N5DLListINFO(ID,4);
    end

end