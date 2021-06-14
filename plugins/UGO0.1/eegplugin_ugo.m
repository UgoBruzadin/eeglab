% eegplugin_ugo() - Quick Lab plugin
function eegplugin_ugo(fig, try_strings, catch_strings)

supermenu = uimenu( fig, 'label', 'QuickLab');

plotmenu = uimenu (supermenu, 'label', 'Quick plot');

uimenu( plotmenu, 'label', 'Quick plot PCA/ICA', 'callback', ...
    ['EEG = pop_fastIClabel(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick Run N-1 PCA and plot', 'callback', ...
    ['EEG = pop_fastPCAandIClabel(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( supermenu, 'label', 'Run a pipeline', 'callback', ...
    ['EEG = runapipeline(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);







%supermenu;

%   supergui( 'geomhoriz', { [1 1] 1 1 }, 'uilist', { ...
%          { 'style', 'text', 'string', 'Enter some text' }, ...
%          { 'style', 'edit', 'string', 'Hello!' }, { }, ...
%          { 'style', 'pushbutton' , 'string', 'OK' 'callback' 'close(gcbf);' } } );


% function eegplugin_ugo(fig, try_strings, catch_strings)
%   uimenu( fig, 'label', 'QuickLab', 'callback', ...
%   ['EEG = pop_fastIClabel(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);
%   uimenu( submenu, 'label', 'Quick', 'callback', ...
%   [ try_strings.anyfield '[EEG LASTCOM] = pop_ugo(EEG);' ...
%   catch_strings.anyfield ]);
% %   supergui( 'geomhoriz', { [1 1] 1 1 }, 'uilist', { ...
% %          { 'style', 'text', 'string', 'Enter some text' }, ...
% %          { 'style', 'edit', 'string', 'Hello!' }, { }, ...
% %          { 'style', 'pushbutton' , 'string', 'OK' 'callback' 'close(gcbf);' } } );
%
% end
