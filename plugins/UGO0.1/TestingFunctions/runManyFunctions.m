function [outparam2] = runManyFunctions(EEG)
files = [];
path = [];

[outparam,b,c,d] = inputgui('geometry', { [1 1] [0.5 2] [1 1] }, ...
'geomvert', [1 3 1], 'uilist', { ...
{'style' 'pushbutton' 'string' 'Select Set File(s) ' 'callback' '[files,path] = uigetfile(''*.set'',''Select One or More Files'',''MultiSelect'', ''on'');[setfiles,fdtfiles,path] = makefiledir(files,path)'} { 'Style', 'edit', 'string', '' 'tag' 'files'}...
{'style' 'checkbox' 'string' 'Paste Function(s)'            } { 'Style', 'edit', 'string', 'EEG = pop_runica(EEG,''icatype'',''binica'',''extended'',1);' 'tag' 'functions'}...
{'style' 'checkbox' 'string' 'Write New Name Acronym(s)'    } { 'Style', 'edit', 'string', 'NewTag' 'tag' 'acronym'}},...
'addbuttons', 'on');

outparam2 = outparam(3);
command = outparam2{:};

eval(command);

end