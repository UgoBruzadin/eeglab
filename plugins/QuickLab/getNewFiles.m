function todofiles = getNewFiles(folder1,folder2)

if nargin < 1
    folder1 = pwd;
end

if nargin < 2
    cd ..
    folder2 = pwd;
    cd(folder1)
end

%--- collect directory
prefiles = dir('*.set');
cd(folder2)
postfiles = dir('*.set');
cd(folder1)
%---start comparing the files
if ~isempty(postfiles)
%postnames = strcat(postfiles{:});
postnames = cat(2,postfiles.name);
todofiles = dir('');

for j=1:length(prefiles)
    if ~contains(postnames,prefiles(j).name(1:16))
        todofiles = cat(1,todofiles,dir(prefiles(j).name));
    end
end
else
   todofiles = prefiles;
end

end