% eegplugin_pca() - a pca plug-in
function eegplugin_pca( fig, try_strings, catch_strings);

% create menu
toolsmenu = findobj(fig, 'tag', 'tools');
submenu = uimenu( toolsmenu, 'label', 'Run Pipeline');

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