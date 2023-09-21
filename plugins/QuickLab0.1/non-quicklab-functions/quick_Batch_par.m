function [newfiles,folderPOST] = quick_Batch_par(Commands,Save,createfolders,files,filesFolder,acronym) %magic function, runs the code asked!

if ischar(Commands)
    Commands = {Commands};
end
if nargin < 6
    acronym = char(Commands(1));
end

if nargin < 5
    createfolders = 0;
end

if nargin < 4
    filesFolder = pwd;
    folderPRE = pwd;
    folderPOST = pwd;
end
if nargin < 3
    files = dir('*.set');
end
if nargin < 2
    Save = 0;
end

% --- collects script instructions in an array
if createfolders == 1
    %Functions = Commands{:};
    % --- gets date and time
    t = datetime('now','TimeZone','local','Format','dMMMy-HH.mm'); %gets the datetime
    % --- makes a name for the function
    %fname = strcat(mfilename,'.'); %get the name of this function for future use, adds a dot to it
    % --- moves to the last path where files were
    cd(filesFolder);
    % --- starts a timer; to be added to approximate time to finish
    %tic;
    % --- creates folder name
    %scriptCounter = 1;
    %folderLetter = char(scriptCounter+64); %names the folder initial letter (A, B, etc)!
    %folderNameDate = strcat(folderLetter,'-',char(Commands),'-',char(t)); %makes folder full name
    %folderName = strcat(folderLetter,'-',char(Commands)); %makes folder partial name
    %folderList = dir();
    %if NEWFOLDER
    folderNameDate = strcat(char(Commands(1)),'-',char(t)); %makes folder full name
    [files, folderPRE, folderPOST] = createfolders(filesFolder,filesFolder,folderNameDate); %creates a folder for the pipeline
    %else
end
%end
% --- moves down to scripts new directory
%cd(filePOST);
% --- gest the scripts that are not the name of the function
%Functions2 = Functions(2:end);
% -- loops all files and run the function fo each one.
parfor i=1:length(files)
    % --- load EEG
    EEG = pop_par_loadset(files(i).name, folderPRE,  'all','all','all','all','auto');
    % --- call the function = can be susbtituted for a script in the future
    % -- functions are always named "pipe_" and contain the
    % -- name and instructions to be performed
    %try
    % --- action is creates a function out of string in
    % -- script(1) and runs it the script it refers to
    action = str2func(strcat('quick_',char(Commands(1)))); %this call a function inside this function with the name asked for!
    if length(Commands) > 1
        %Commands2 = Commands{:};
        [EEG] = action(EEG, Commands{2:end}); %this is where the function runs the asked code!
    else
        [EEG] = action(EEG); %this is where the function runs the asked code!
    end
   
    % --- saves file with new name on script's folder
    if Save == 1
        % --- makes a new name for the file, adding the acronym
        % -- to the name
        newname = strcat(files(i).name(1:end-4), [acronym], '.set');
        EEG = pop_par_saveset(EEG, 'filename', [newname], 'filepath', folderPOST);
    end
    %EEG = pop_delset(EEG,1); %fixed and added 2/3/2020
end
save('done.txt');
%send_ugoslabgmail_alert('One Process Done',folderName)
newfiles = dir(strcat('*',acronym,'.set'));

end

function [files, filesPRE, filesPOST] = createfolders(batchFolder,previousFolderPath,folderName)
%------ create the folders where the pipeline will run
%------ filePRE = strcat(basefolder,'\', type, '\pre'); %copies files
%------ one can I turn it off)
cd(batchFolder) % - goes to last path's folder

% --- add: is there already a folder? if not, make new folder

% --- makes Script directory
% --- collects files and folders in the directory
folderList = dir();
% --- checks if it's empty, it is, makes a new folder
if isempty(folderList)
    mkdir (folderName)
    % --- If it isn't, checks to see if the folder to be mde
    % already exists. If so, doesn't make a new folder.
    % Instead, it
else
    new = 0;
    for k=1:length(folderList)
        if contains(folderList(k).name,folderName(1:7))
            folderName = folderList(k).name;
            new = 1;
        end
    end
    if ~new
        mkdir (folderName)
    end
end

cd(folderName);
filesPOST = pwd;
if ~isfolder('Pre')
    mkdir ('Pre'); % creates new folder
end
cd (strcat(pwd, '/Pre'));
filesPRE = pwd;

files = getNewFiles(previousFolderPath,filesPRE,'*.set','*.set',pwd);

%fdtfiles = getNewFiles(filesPRE,pwd,'*.fdt','*.fdt',pwd);
%setfiles = getNewFiles(filesPRE,pwd,'*.set','*.set',pwd);
%fdtfiles = dir('*.fdt'); %gets fdt files
%setfiles = dir('*.set'); %gets set files
%filesPRE = strcat(filesPOST,'\pre');
if ~isempty(files)
    cd(previousFolderPath)
    parfor j=1:length(files)
        copyfile(files(j).name, filesPRE)
    end
    cd(filesPRE)
end

% --- if the pipeline has already started
% --- check if the process is midway through
%             if counter > 1
%                 cd(filesPOST)
%                 filesPOSTdir = dir('*.set');
%                 if ~isempty(filesPOSTdir)
%                     fdtfiles = getNewFiles(pwd,filesPRE,'*.fdt','*.fdt',filesPRE);
%                     setfiles = getNewFiles(pwd,filesPRE,'*.set','*.set',filesPRE);
%                 end
%             end
cd(filesPOST)
if ~isfile('done.txt')
    cd(filesPRE);
    files = getNewFiles(filesPRE,filesPOST,'*.set','*.set',pwd);
else
    cd(filesPRE);
    files = [];
end
end


function varargout = getCommands(varargin)


end
