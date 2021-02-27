% eegplugin_pipeliner() - a pipeliner plug-in
function eegplugin_pipeliner( fig, try_strings, catch_strings)

% create menu
uimenu( fig, 'label', '[My function]', 'callback', ... 
    [ 'EEG = pipeliner(EEG); [ALLEEG EEG CURRENTSET] ... = eeg_store(ALLEEG, EEG, CURRENTSET);' ]);


uimenu( submenu, 'label', 'My function', 'callback', ... 
          [ try_strings.anyfield '[EEG LASTCOM] ... = pipeliner(EEG, ...);' arg3.anyfield ]);

toolsmenu = findobj(fig, 'tag', 'file');
submenu = uimenu( toolsmenu, 'label', 'Run new pipeline');

% build command for menu callback\\ cmd = [ '[tmp1 EEG.icawinv] = runpca(EEG.data(:,:));' ];
cmd = [ cmd 'EEG.icaweights = pinv(EEG.icawinv);' ];
cmd = [ cmd 'EEG.icasphere = eye(EEG.nbchan);' ];
cmd = [ cmd 'clear tmp1;' ];

finalcmd = [ try_strings.no_check cmd ];
finalcmd = [ finalcmd 'LASTCOM = ''' cmd ''';' ];
finalcmd = [ finalcmd catch_strings.store_and_hist ];

% add new submenu
uimenu( submenu, 'label', 'Run Pipeline', 'callback', finalcmd);

supergui( 'geomhoriz', { [1 1] 1 1 }, 'geomvert', [3 1 1], 'uilist', { ...
    { 'style', 'text', 'string', [ 'Make a choice' 10 10 10 ] }, ...
    { 'style', 'listbox', 'string', 'Choice 1|Choice 2|Choice 3' }, { }, ...
    { 'style', 'pushbutton' , 'string', 'OK' 'callback' 'close(gcbf);' } } );