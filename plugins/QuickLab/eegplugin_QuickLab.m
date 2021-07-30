% eegplugin_QuickLab() - QuickLab plugin version 0.1 for EEGLAB menu.
%                        QuickLab is a compilation of modified EEGLAB functions
%                        for experienced users that wish to speed up manual
%                        process, made by Ugo Bruzadin Nunes in
%                        colaboration with the INL lab in Carbondale, IL.

function vers = eegplugin_QuickLab(fig, try_strings, catch_strings)

vers = 0.1;
% --- QuickLab sumermenu placeholder
supermenu = uimenu(fig, 'label', 'QuickLab');

% --- first submenu: Quick plots
plotmenu = uimenu (supermenu, 'label', 'Quick Plots');

uimenu( plotmenu, 'label', 'Plot (epoched) Channel Scroll for Interpolation', 'callback', ...
    ['com = pop_eegplot_w3(EEG, 1, 1, 1);;[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Plot (continuous) Channel Scroll for Interpolation', 'callback', ...
    ['com = pop_eegplot_w2(EEG, 1, 1, 1);;[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Plot (epoched) Component Scroll for Interpolation', 'callback', ...
    ['com = pop_eegplot_w3(EEG, 2, 1, 1);;[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Plot (continuous) Component Scroll for Interpolation', 'callback', ...
    ['com = pop_eegplot_w2(EEG, 2, 1, 1);;[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick Plot Channel Spectra', 'callback', ...
    ['EEG = pop_fastspectra(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick IClabel & plot', 'callback', ...
    ['EEG = pop_fastIClabel(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick IClabel, DIPFIT & plot', 'callback', ...
    ['EEG = pop_fastIClabelDF(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

printmenu = uimenu (plotmenu, 'label', 'Quick Print'); 

uimenu( printmenu, 'label', 'Print Components', 'callback', ...
    ['pop_viewprops4( EEG, 0, [1:size(EEG.icawinv, 2)], { "freqrange", [2 80]}, {}, 2, "ICLabel" );[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( printmenu, 'label', 'Print Marked Components', 'callback', ...
    ['printRejComponents(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

% uimenu( printmenu, 'label', 'Print FFT', 'callback', ...
%     ['printFFT(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

% plot fft difference!

% --- second submenu: Quick ICA/PCAs
pcamenu = uimenu (supermenu, 'label', 'Quick PCA');

dipfitmenu = uimenu (pcamenu, 'label', 'Quick PCA and DipFit');

uimenu( dipfitmenu, 'label', 'Quick ICA & DF', 'callback', ...
    ['EEG = quick_PCADF(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( dipfitmenu, 'label', 'Quick N-1 PCA & DF', 'callback', ...
    ['EEG = quick_N1PCADF(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

for d=6:2:50
uimenu( dipfitmenu, 'label', strcat('Quick PCA ',num2str(d),' & DF'), 'callback', ...
    ['EEG = quick_PCADF(EEG,' num2str(d) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

uimenu( pcamenu, 'label', 'Quick ICA', 'callback', ...
    ['EEG = pop_fastPCA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( pcamenu, 'label', 'Quick N-1 PCA', 'callback', ...
    ['EEG = pop_fastN1PCA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

for i=6:2:50
uimenu( pcamenu, 'label', strcat('Quick PCA ',num2str(i)), 'callback', ...
    ['EEG = pop_fastPCA(EEG,' num2str(i) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

if gpuDeviceCount
cudamenu = uimenu (supermenu, 'label', 'Quick CUDAICA');

uimenu( cudamenu, 'label', 'Quick ICA', 'callback', ...
    ['EEG = cudafastPCA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( cudamenu, 'label', 'Quick N-1 PCA', 'callback', ...
    ['EEG = cudafastN1PCA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

for i=6:2:50
uimenu( cudamenu, 'label', strcat('Quick PCA ',num2str(i)), 'callback', ...
    ['EEG = cudafastPCA(EEG,' num2str(i) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end
end
% --- third submenu: Quick channel edits
channelmenu = uimenu (supermenu, 'label', 'Quick Channel Edit');

uimenu( channelmenu, 'label', 'Quick Re-reference CZ', 'callback', ...
    ['EEG = pop_fastrerefcz(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( channelmenu, 'label', 'Quick Re-reference AVG', 'callback', ...
    ['EEG = pop_fastrerefavg(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( channelmenu, 'label', 'Quick Re-reference Linked-Mastoids (129)', 'callback', ...
    ['EEG = pop_fastrerefavg(EEG,[55,100]);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( channelmenu, 'label', 'Quick Reduce to 98/99 Channels (NIDA 5)', 'callback', ...
    ['[EEG] = pop_HM99(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

interpmenu = uimenu( channelmenu, 'label', 'Quick channel interpolation');

for j=2:7
uimenu( interpmenu, 'label', strcat('By ',num2str(j),' SDV'), 'callback', ...
    ['EEG = pop_fastchannelinterp(EEG,' num2str(j) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

uimenu( channelmenu, 'label', 'Quick Interpolate Channels by Components', 'callback', ...
    ['[EEG] = channelIntByComps(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

filtermenu = uimenu (channelmenu, 'label', 'Quick Filter');

% for a=0.5:0.5:2.5
% uimenu( filtermenu, 'label', strcat('Quick High Pass ',num2str(a)), 'callback', ...
%     ['EEG = quick_lowpass(EEG,' num2str(a) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% end

for b=14:22
uimenu( filtermenu, 'label', strcat('Quick Low Pass ',num2str(b)), 'callback', ...
    ['EEG = quick_lowpass(EEG,' num2str(b) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

% --- 4th submenu: Quick epoch edits
epochsmenu = uimenu (supermenu, 'label', 'Quick Epoch edits');

for s = 1:5
uimenu( epochsmenu, 'label', strcat('Quick Epoch every_', num2str(s), '_seconds'), 'callback', ...
    ['EEG =  quick_epoch(EEG,',num2str(s), ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

uimenu( epochsmenu, 'label', 'Quick UN-Epoch (Back to Continuous', 'callback', ...
    ['EEG =  quick_unepoch(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( epochsmenu, 'label', 'Quick Epoch 0.400 2.448 (DotLoc)', 'callback', ...
    ['EEG =  quick_epoch(EEG,0.400,2.448);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( epochsmenu, 'label', 'Quick Epoch -1 3.096 (DotLoc)', 'callback', ...
    ['EEG =  quick_epoch(EEG,-1,3.096);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

rejmenu = uimenu( epochsmenu, 'label', 'Quick Epoch Rejection by probability');

for k=2:7
uimenu( rejmenu, 'label', strcat('By ',num2str(k),' SDV'), 'callback', ...
    ['EEG = quick_trialrejprob(EEG,' num2str(j) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

% --- 4th submenu: Quick PCA edits
pcasmenu = uimenu (supermenu, 'label', 'Quick PCA cleaning');

uimenu( pcasmenu, 'label', 'Interpolate Marked Components for Epochs > 3 sdvs', 'callback', ...
    ['EEG =  pop_epochintbycompsbyvar(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( pcasmenu, 'label', 'Interpolate Channels by Marked Components if 1 Channel only is above 2 sdv', 'callback', ...
    ['[EEG] = pop_epochandchannelintbycompsbyvar(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

% --- 5th submenu: QuickCorrmap
corrmenu = uimenu (supermenu, 'label', 'Quick CorrMap');

uimenu( corrmenu, 'label', 'Create/Change QuickCorrMaps folder', 'callback', ...
    ['savecorrmappath;[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( corrmenu, 'label', 'Quick Save Selected CorrMaps', 'callback', ...
    ['saveComponents(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( corrmenu, 'label', 'Quick Run CorrMap', 'callback', ...
    ['EEG = quickcorrmap(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw']);

% 
% % --- 6th submenu: Run a pipeline
% 
% uimenu( supermenu, 'label', 'Quick Pipeline', 'callback', ...
%     ['[UGO, EEG] = pop_runapipeline();eeglab redraw;']);

% --- 7th submenu: Run a pipeline

parmenu = uimenu( supermenu, 'label', 'Quick Parallel Processes');

uimenu( parmenu, 'label', 'Quick Par DipFit', 'callback', ...
    ['[EEG] = quick_dipfit(EEG); eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;']);


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
