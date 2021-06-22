% eegplugin_ugo() - Quick Lab plugin
% this plugin was made by Ugo Bruzadin Nunes
% I modified original code from the EEGLAB
% such as viewprops and spectopo
% to speed up my data processing!

function eegplugin_ugo(fig, try_strings, catch_strings)

supermenu = uimenu(fig, 'label', 'QuickLab');

plotmenu = uimenu (supermenu, 'label', 'Quick plot');

pcamenu = uimenu (supermenu, 'label', 'Quick PCA');

toolsmenu = uimenu (supermenu, 'label', 'Quick tools');

epochsmenu = uimenu (toolsmenu, 'label', 'Quick epoch cleaning');

pcasmenu = uimenu (toolsmenu, 'label', 'Partial PCA cleaning');

channelmenu = uimenu (toolsmenu, 'label', 'Quick channel cleaning');

uimenu( plotmenu, 'label', 'Quick Plot Channel Spectra', 'callback', ...
    ['EEG = pop_fastspectra(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( toolsmenu, 'label', 'Quick Re-reference CZ', 'callback', ...
    ['EEG = pop_fastrerefcz(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( toolsmenu, 'label', 'Quick Re-reference AVG', 'callback', ...
    ['EEG = pop_fastrerefavg(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( channelmenu, 'label', 'Quick Reduce to 99 Channels (INL only)', 'callback', ...
    ['[EEG] = pop_HM99(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( channelmenu, 'label', 'Quick Interpolate Worse Channels by 3 STD', 'callback', ...
    ['EEG = pop_fastchannelinterp(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( channelmenu, 'label', 'Quick Interpolate Channels by Components', 'callback', ...
    ['[EEG] = channelIntByComps(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( plotmenu, 'label', 'Quick IClabel & plot', 'callback', ...
    ['EEG = pop_fastIClabel(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( pcamenu, 'label', 'Quick N-1 PCA', 'callback', ...
    ['EEG = pop_fastN1PCA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( pcamenu, 'label', 'Quick ICA', 'callback', ...
    ['EEG = pop_fastPCA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

for i=6:2:50
uimenu( pcamenu, 'label', strcat('Quick PCA ',num2str(i)), 'callback', ...
    ['EEG = pop_fastPCA(EEG,' num2str(i) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

uimenu( epochsmenu, 'label', 'Quick Epoch Rej. by Prob (5 sdv)', 'callback', ...
    ['EEG =  trialrejprob(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( pcasmenu, 'label', 'Partial Component Removal for Epoch Interpolation', 'callback', ...
    ['EEG =  pop_epochintbycompsbyvar(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( pcasmenu, 'label', 'Partial Component Removal for Channel Interpolation', 'callback', ...
    ['[EEG] = pop_epochandchannelintbycompsbyvar(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( supermenu, 'label', 'Run a pipeline', 'callback', ...
    ['EEG = runapipeline(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);




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
