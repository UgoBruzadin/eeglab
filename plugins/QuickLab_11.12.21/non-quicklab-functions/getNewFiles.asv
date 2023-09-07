function todofiles = getNewFiles(folder1,folder2,format1,format2,backfolder,namesize)
if nargin < 6
    namesize = 9;
end

if nargin < 5
    backfolder = pwd;
end
if nargin < 1
    folder1 = pwd;
end

if nargin < 2
    cd ..
    folder2 = pwd;
    cd(folder1)
end

if nargin < 3
    format1 = '*.set';
end

if nargin < 4 || isempty(format2)
    format2 = format1;
end

%--- collect directory
cd(folder1);
prefiles = dir(format1);
cd(folder2);
postfiles = dir(format2);
cd(folder1);

%--- selecting longests list

if size(prefiles,2) >= size(postfiles,2)
    postfiles2 = postfiles;
    prefiles2 = prefiles;
    prefiles = postfiles2;
    postfiles = prefiles2;
end

%---start comparing the files
if ~isempty(postfiles)
    %postnames = strcat(postfiles{:});
    postnames = cat(2,postfiles.name);
    todofiles = dir('');
    
    for j=1:length(prefiles)
        if ~contains(postnames,prefiles(j).name(1:namesize))
            todofiles = cat(1,todofiles,prefiles(j));
        end
    end
else
   todofiles = prefiles;
end
    cd(backfolder);
end