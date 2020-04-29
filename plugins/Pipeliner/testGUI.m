

function testGUI(EEG)

uilist = { { 'style' 'text' 'string' 'Output file name' }, ...
    { 'style' 'edit' 'string' '' 'tag' 'tagedit' }, ...
    { 'style' 'pushbutton' 'string' 'Browse' 'callback' },...
    };
commandload = [ '[filename, filepath] = uiputfile(''*'', ''Select a text file'');' ...
    'if filename ~=0,' ...
    '   set(findobj(''parent'', gcbf, ''tag'', ''tagedit''), ''string'', [ filepath filename ]);' ...
    'end;' ...
    'clear filename filepath tagtest;' ];

uigeom = { [1 2 0.5] };

result = inputgui( uigeom, uilist);


fprintf(result);

end