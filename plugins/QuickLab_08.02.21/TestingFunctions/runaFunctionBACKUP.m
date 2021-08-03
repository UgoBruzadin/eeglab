function [outparam2] = runaFunction(UGO,files,path)
if nargin < 2
    UGO = struct();
    files = [];
    path = pwd;
end
clear UGO.files
clear UGO.setfiles
clear UGO.fdtfiles
UGO.files = [];


command = ['global UGO;[files,path] = uigetfile(''*.set'',''Select One or More Files'',''MultiSelect'', ''on'');[UGO.setfiles,UGO.fdtfiles,UGO.path] = makefiledir(files,path);'];

FILES = {'style' 'pushbutton' 'string' 'Select Set File(s) ' ...
'callback' command};

[outparam,b,c,d] = inputgui('geometry', { [1 1] [0.5 2] [1 1] }, ...
'geomvert', [1 3 1], 'uilist', { ...
FILES...
{}...
{'style' 'text' 'string' 'Paste Function(s)'            } { 'Style', 'edit', 'string', 'EEG = pop_runica(EEG,''icatype'',''binica'',''pca'',30,''extended'',1);' 'tag' 'functions'}...
{'style' 'text' 'string' 'Write New Name Acronym(s)'    } { 'Style', 'edit', 'string', 'PCA30' 'tag' 'acronym'}},...
'addbuttons', 'on');

%if files selected, else run in EEG only

global UGO;
cd(UGO.path)
for i=1:length(UGO.setfiles)
    %newfile = EEG.files(i);
    %newfile = newfile{:};
    % --- load set files
    EEG = pop_loadset(UGO.setfiles(i).name);
    command = outparam(1);
    command = command{:};
    eval(command);
    acronym = outparam(2);
    acronym = acronym{:};
    newname = strcat(UGO.setfiles(i).name(1:end-4), [acronym], '.set');
    % --- saves file with new name on script's folder
    EEG = pop_saveset(EEG, 'filename', [newname], 'filepath', UGO.path);
end
end