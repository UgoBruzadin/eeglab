folder = dir('*.m');

list = "";

list(1:length(folder),1) = [''];

parfor i=1:length(folder)

    list(i) = [find_unused_files(folder(i).name)];

end

