function [UGO,EEG] = pop_runapipeline(UGO,EEG,listoffiles,pathIn,pathOut,commands)
clear global
if nargin < 1
    % --- If no variables are given, this sections makes sure the important
    % ---- variables are empty or set to default
    % --- UNDER CONSTRUCTION - needs to have an IF for each variable
    commands = [];     % doesnt do anything yet; space for automatizing
    listoffiles = [];  % list of files to be run
    pathIn = pwd;      % path where files are loaded from
    pathOut = pwd;     % path where files are saved at
    % --- clears global variable UGO and builds it back
    clear UGO.files UGO.setfiles UGO.fdtfiles UGO.pathIn UGO.pathOut EEG;
    UGO = struct();    % struct where data will be stored
    UGO.files = listoffiles;
    UGO.pathIn = pathIn;
    UGO.pathOut = pathOut;
    UGO.files = [];
    
    % --- CHOOSE FILE(S) BUTTON 
    filesButton = ['global UGO;[files,path] = uigetfile(''*.set'',''Select One or More .set Files'',''MultiSelect'', ''on''); if files==0 return; end;'];
    FilesBracket = {'style' 'pushbutton' 'string' 'Select .set File(s) ' ...
        'callback' filesButton};
    
    % --- CHOOSE FOLDER BUTTON 
    folderButton = ['global UGO; [path] = uigetdir(); if path==0 return; end; [UGO.pathOut] = path;'];
    FolderBracket = {'style' 'pushbutton' 'string' 'Select Folder to save ' ...
        'callback' folderButton};
    
    % --- UI DESIGN 
    [outparam,userdat,strhalt,outstruct] = inputgui('title','Run a function in selected files','geometry', { [1 1] [0.5 2] [1 1] }, ...
        'geomvert', [1 2 1], 'uilist', { ...
        FilesBracket...
        FolderBracket...
        {'style' 'text' 'string' 'Paste Function(s)'            } { 'Style', 'edit', 'string', 'EEG = pop_par_runica(EEG,''icatype'',''binica'',''pca'',30,''extended'',1);EEG = pop_iclabel(EEG)' 'tag' 'functions'}...
        {'style' 'text' 'string' 'Write New Name Acronym(s)'    } { 'Style', 'edit', 'string', 'PCA30' 'tag' 'acronym'}},...
        'addbuttons', 'on');
    
    [UGO.setfiles,UGO.fdtfiles,UGO.pathIn] = makefiledir(files,path);
    
    % --- Collects acronym and functions(s)
    % --- if no files are selected, skip this part
    if ~isempty(outparam)
        if ~isempty(outparam(1))
            UGO.command = outparam(1);
            UGO.command = UGO.command{:};
        else
            fprintf('No functions given. /r')
            return;
        end
        if ~isempty(outparam(2))
            UGO.acronym = outparam(2);
            UGO.acronym = UGO.acronym{:};
        else
            fprintf('No acronyms given, acronym is now _. /r')
            UGO.acronym = '_';
        end
    else
    %--- if no files are selected, makes sure EEG is returned empty;
        EEG = [];
    end
end
% --- makes sures that UGO is a global variable - unsure if necessary
global UGO;
% --- if no files are selected, cancels function.
if isempty(UGO.setfiles)
    return;
end

%get more than one commands, to run them seperately if necessary
% A = find(UGO.command,';');
% for j=1:length(A)
%     %UGO.command(j) = 
% end

for i=1:length(UGO.setfiles)
    % --- moves to file path
    cd(UGO.pathIn)
    % --- load set files
    EEG = pop_loadset(UGO.setfiles(i).name);
    % --- runs (ALL) given function(s)
    eval(UGO.command);
    % --- creates new name given acronym
    newname = strcat(UGO.setfiles(i).name(1:end-4), [UGO.acronym], '.set');
    % --- saves file with new name on script's folder
    EEG = pop_saveset(EEG, 'filename', [newname], 'filepath', UGO.pathOut);
end
end