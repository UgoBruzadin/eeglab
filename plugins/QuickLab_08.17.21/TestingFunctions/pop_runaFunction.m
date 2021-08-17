function [outparam2] = pop_runaFunction(files,path)
if nargin < 2
global files;
global path;
end

[outparam,b,c,d] = inputgui('geometry', { [1 1] [0.5 2] [1 1] }, ...
'geomvert', [1 3 1], 'uilist', { ...
{'style' 'pushbutton' 'string' 'Select Set File(s) ' ...
'callback' ...
'[files,path] = uigetfile(''*.set'',''Select One or More Files'',''MultiSelect'', ''on'');[setfiles,fdtfiles,path] = makefiledir(files,path);files = setfiles'} ...
{}...
{'style' 'checkbox' 'string' 'Paste Function(s)'            } { 'Style', 'edit', 'string', 'EEG = pop_runica(EEG,''icatype'',''binica'',''pca'',30,''extended'',1);' 'tag' 'functions'}...
{'style' 'checkbox' 'string' 'Write New Name Acronym(s)'    } { 'Style', 'edit', 'string', 'NewTag' 'tag' 'acronym'}},...
'addbuttons', 'on');

%if files selected, else run in EEG only
cd(path)
for i=1:length(files)
    newfile = files(i);
    newfile = newfile{:};
    % --- load set files
    EEG = pop_loadset(newfile);
    command = outparam(3);
    command = command{:};
    eval(command);
    acronym = outparam(5);
    acronym = acronym{:};
    newname = strcat(newfile(1:end-4), [acronym], '.set');
    % --- saves file with new name on script's folder
    EEG = pop_saveset(EEG, 'filename', [newname], 'filepath', path);
end
end