function pop_fftdiff2(EEG,filesPre,pathPre,filesPost,pathPost,pathOut)

clear global
if nargin < 1
    % --- If no variables are given, this sections makes sure the important
    % ---- variables are empty or set to default
    % --- UNDER CONSTRUCTION - needs to have an IF for each variable
    
    filesPre = [];  % list of files to be run
    filesPost = [];
    pathPre = pwd;      % path where files are loaded from
    pathPost = pwd;
    pathOut = pwd;     % path where files are saved at
    % --- clears global variable UGO and builds it back
    clear UGO.files UGO.setfiles UGO.fdtfiles UGO.pathIn UGO.pathOut EEG;
    UGO = struct();    % struct where data will be stored
    UGO.filesPre = filesPre;
    UGO.pathpathPre = pathPre;
    UGO.filesPost = filesPost;
    UGO.pathPost = pathPost;
    UGO.pathOut = pathOut;
    UGO.setfiles = [];
    
    % --- CHOOSE PRE FILE(S) BUTTON
    filesButton1 = ['global UGO;[files1,path1] = uigetfile(''*.set'',''Select One or More .set Files'',''MultiSelect'', ''on'');if files1==0 return; end;[UGO.setfiles1,UGO.fdtfiles1,UGO.pathPre] = makefiledir(files1,path1);'];
    FilesBracket1 = {'style' 'pushbutton' 'string' 'Select .set File(s) ' ...
        'callback' filesButton1};
    
    % --- CHOOSE POST FILE(S) BUTTON
    filesButton2 = ['global UGO;[files2,path2] = uigetfile(''*.set'',''Select One or More .set Files'',''MultiSelect'', ''on'');if files2==0 return; end;[UGO.setfiles2,UGO.fdtfiles2,UGO.pathPost] = makefiledir(files2,path2);'];
    FilesBracket2 = {'style' 'pushbutton' 'string' 'Select .set File(s) ' ...
        'callback' filesButton2};
    
    % --- CHOOSE FOLDER BUTTON 
    folderButton = ['global UGO;[path] = uigetdir();if path==0 return; end;[UGO.pathOut] = path;'];
    FolderBracket = {'style' 'pushbutton' 'string' 'Select Folder to save pictures' ...
        'callback' folderButton};
    
    % --- UI DESIGN
    [outparam,userdat,strhalt,outstruct] = inputgui('title','Run a function in selected files','geometry', { [1] [1] [2] }, ...
        'geomvert', [2 2 2], 'uilist', { ...
        FilesBracket1 FilesBracket2 FolderBracket}...
        ,'addbuttons', 'on');
    %--- if no files are selected, makes sure EEG is returned empty;
    EEG = [];
end

% check if lists are consistent
% 


end