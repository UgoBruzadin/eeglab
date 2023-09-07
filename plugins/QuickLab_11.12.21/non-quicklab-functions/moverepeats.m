
% A = dir('*HM9*Ep6*ICA*.set')';
% parfor i=1:length(A)
% copyfile(A(i).name,'./DONE/')
% end
AllFiles = dir('*.set')';

[AllFiles.repeated] = deal(0);
[AllFiles.Latest] = deal(0);

C = {AllFiles.name};
C = C';
D = {AllFiles.datenum};
D = D';

B = cat(2,C,D);

AllFilesStringed = [AllFiles.name];
LocationOfFiles = [1,strfind(AllFilesStringed,'.set')+4]; % Get the place of the file in the list

for i = 1:length(AllFiles)
    
    LocationOfFileStrings = strfind(AllFilesStringed,AllFiles(i).name(1:12));
    LocationOfThisFiles = strfind(AllFilesStringed,AllFiles(i).name(1:end));

    %LocationOfFileStrings = contains(AllFilesFoldersName,strcat(allStartedFiles(i).name(1:end-4),'*','bssICA*.set'));
    NumberOfCountedFiles = length(LocationOfFileStrings);
    
    if NumberOfCountedFiles > 1
        Repeats = find(ismember(LocationOfFiles,LocationOfFileStrings)); %compare two arrays of unequal sizes, and get their IDs with find
        LatestDate = max([AllFiles(Repeats).datenum]);
        nonrepeatfileID = find(([AllFiles.datenum]) == LatestDate);
        if length(nonrepeatfileID) > 1
            AA = max(nonrepeatfileID);
        end
        AllFiles(max(nonrepeatfileID)).Latest = 1; % name the longest name and latest file as 1;
        AllFiles(i).repeated = 1;
    else
        AllFiles(i).Latest = 1;
    end
end

donefiles = find(~[AllFiles.Latest]);
repeats = AllFiles(donefiles);
for k=1:length(repeats)
    movefile(repeats(k).name,'./REPEATS/')
end