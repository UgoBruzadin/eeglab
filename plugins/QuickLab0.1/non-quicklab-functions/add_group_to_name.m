

allfiles = dir();

[ allfiles ] = GetAllDirFiles(pwd, 'asc');

%[ allfiles ] = GetAllDirFiles(pwd, '');
%allfiles(ismember({allfiles.name},{'.','..'})) = [];

%T = readtable('E:/N5DLListINFO.xls');

allids = table2array(N5DLListINFO(:,1));

for i=1:size(allfiles,1)

    [~, f,ext] = fileparts(allfiles(i).name);
    ID = [];
    try ID = find(allids==str2double(f(1:4))); catch; end

    if ~isempty(ID)
        group = table2array(N5DLListINFO(ID,4));
        if ~contains(f,'_G')
            rename = strcat(allfiles(i).folder,'\',f,['_G',num2str(group)],ext); 
            movefile(allfiles(i).name, rename); 
        end
    end

end