%clc
%clear;

allfiles = dir();

ext = '';
%crssfiles = dir('*.crss');

origin = pwd;

%[ allfiles ] = GetAllDirFiles(origin, 'asc');
% S(ismember({S.name},{'.','..'})) = [];
% S(endsWith({S.name},{'.txt'})) = [];
% S(endsWith({S.name},{'.crss'})) = [];
% S(endsWith({S.name},{'.slor'})) = [];

marker = ['E1';'E2';'E3';'E4';'E5';'E6'];
groups = ['G1';'G2';'G3';'G4'];

for j = 1:size(marker,1)
    
    cd(origin);
    thismarker = marker(j,1:end);
    mkdir(thismarker);

    %thesefiles = dir(['*',thismarker,'*', ext]);
    thesefiles = GetSpecificFiles(allfiles,thismarker);

    cd(thismarker);

    if ~isempty(thesefiles)
        
        for i=1:size(groups,1)
            thisgroup = groups(i,:);
            
            mkdir(thisgroup);
            cd(thisgroup);
            thisfolder = dir();
            
            newpath = pwd;
            cd(origin);
            

            %grouptext = ['*',thismarker,'*',thisgroup,'*', ext];
            %groupfiles = dir(grouptext);
            grouptext = ['.',thisgroup,'.'];
            groupfiles = GetSpecificFiles(thesefiles,grouptext);
            
            %newfiles = getNewFiles(origin,newpath,grouptext,[],origin,8);

            if ~isempty(groupfiles)
                for k=1:length(groupfiles)
                    movefile([groupfiles(k).folder,'\',groupfiles(k).name],newpath)
                end
            end
            cd(thismarker);
        end
    end
end

