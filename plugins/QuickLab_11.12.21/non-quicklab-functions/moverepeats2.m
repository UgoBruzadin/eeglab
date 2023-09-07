
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

Files = {AllFiles.name}';
Files_char = char(Files);
Files_char_start = Files_char(:,1:12);
Unique_files = unique(Files_char_start,'rows');

Shortest_repeats = zeros(length(Files),1);

count = 1;

for i = 1:length(Unique_files)
    
    filecounts = strfind(AllFilesStringed,Unique_files(i,:)); % count how many times the name shows up
    if size(filecounts,2) > 1 % if there's more than one file with that name
        
        IDs = [];
        for j = 1:size(filecounts,2) % loops for every file with that name
            IDs = [IDs,find(filecounts(j) == LocationOfFiles)]; % gets repeated files IDs
        end
        filenames = char({AllFiles(IDs).name});
        nameSizes = [];
        for k = 1:size(filecounts,2)
            nameSizes = [nameSizes,sum(~isspace(filenames(k,:)))];
        end
        keep = find(max(nameSizes));
        newIDs = IDs;
        newIDs(keep) = [];
        for l=1:length(newIDs)
            AllFiles(newIDs(l)).repeated = 1;
        end
        %i = i + size(filecounts,2);
    end
    count = count + 1; 
end

repeats = AllFiles(find([AllFiles.repeated]))

 for k=1:length(repeats)
     movefile(repeats(k).name,'./REPEATS/')
 end

% 
% AllFilesStringed = [AllFiles.name];
% LocationOfFiles = [1,strfind(AllFilesStringed,'.set')+4]; % Get the place of the file in the list
% 
% for i = 1:length(AllFiles)
%     
%     LocationOfFileStrings = strfind(AllFilesStringed,AllFiles(i).name(1:12));
%     LocationOfThisFiles = strfind(AllFilesStringed,AllFiles(i).name(1:end));
% 
%     %LocationOfFileStrings = contains(AllFilesFoldersName,strcat(allStartedFiles(i).name(1:end-4),'*','bssICA*.set'));
%     NumberOfCountedFiles = length(LocationOfFileStrings);
%     
%     if NumberOfCountedFiles > 1
%         Repeats = find(ismember(LocationOfFiles,LocationOfFileStrings)); %compare two arrays of unequal sizes, and get their IDs with find
%         LatestDate = max([AllFiles(Repeats).datenum]);
%         nonrepeatfileID = find(([AllFiles.datenum]) == LatestDate);
%         if length(nonrepeatfileID) > 1
%             AA = max(nonrepeatfileID);
%         end
%         AllFiles(max(nonrepeatfileID)).Latest = 1; % name the longest name and latest file as 1;
%         AllFiles(i).repeated = 1;
%     else
%         AllFiles(i).Latest = 1;
%     end
% end
% 
% donefiles = find(~[AllFiles.Latest]);
% repeats = AllFiles(donefiles);
% for k=1:length(repeats)
%     movefile(repeats(k).name,'./REPEATS/')
% end