function [EEG] = pop_runapipelinePar(UGO,listoffiles,pathIn,pathOut,Functions)
clear UGO
if nargin < 2
    Functions = []; %doesnt do anything yet; space for automatizing
    UGO = struct(); %struct where data will be stored
    listoffiles = []; %list of files to be run
    pathIn = pwd; %path where files are loaded from
    pathOut = pwd; %path where files are saved at
end
% if EEG
%     oldEEG = EEG;
% end
clear UGO.files UGO.setfiles UGO.fdtfiles UGO.pathIn UGO.pathOut EEG;

UGO.files = listoffiles;
UGO.pathIn = pathIn;
UGO.pathOut = pathOut;

filesButton = ['global UGO;[files,path] = uigetfile(''*.set'',''Select One or More .set Files'',''MultiSelect'', ''on'');[UGO.setfiles,UGO.fdtfiles,UGO.pathIn] = makefiledir(files,path);'];

FilesBracket = {'style' 'pushbutton' 'string' 'Select .set File(s) ' ...
'callback' filesButton};

folderButton = ['global UGO;[path] = uigetdir();UGO.pathOut] = makefiledir(files,path);'];

FolderBracket = {'style' 'pushbutton' 'string' 'Select Folder to save ' ...
'callback' folderButton};

[outparam,userdat,strhalt,outstruct] = inputgui('title','Run a function in selected files','geometry', { [1 1] [0.5 2] [1 1] }, ...
'geomvert', [1 2 1], 'uilist', { ...
FilesBracket...
FolderBracket...
{'style' 'text' 'string' 'Paste Function(s)'            } { 'Style', 'edit', 'string', 'EEG = pop_par_runica(EEG,''icatype'',''binica'',''pca'',30,''extended'',1);EEG = pop_par_iclabel(EEG)' 'tag' 'functions'}...
{'style' 'text' 'string' 'Write New Name Acronym(s)'    } { 'Style', 'edit', 'string', 'PCA30' 'tag' 'acronym'}},...
'addbuttons', 'on');

%if files selected, else run in EEG only

global UGO;
% if ~isstring(UGO.pathOut)
%     UGO.pathOut = UGO.pathIn;
% end
cd(UGO.pathIn)
forSize = length(UGO.setfiles);
command2 = outparam(1);
command2 = command2{:};
acronym = outparam(2);
acronym = acronym{:};
UGO.function = command2;

for i=1:forSize
    %newfile = EEG.files(i);
    %newfile = newfile{:};
    % --- load set files
    EEG = pop_par_loadset(UGO.setfiles(i).name);

    eval(UGO.function);

    newname = strcat(UGO.setfiles(i).name(1:end-4), [acronym], '.set');
    % --- saves file with new name on script's folder
    EEG = pop_par_saveset(EEG, 'filename', [newname], 'filepath', UGO.pathOut);
end

end