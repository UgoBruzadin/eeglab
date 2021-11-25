% eegplugin_QuickLab() - QuickLab plugin version 0.1 for EEGLAB menu.
%                        QuickLab is a compilation of modified EEGLAB functions
%                        for experienced users that wish to speed up manual
%                        process, made by Ugo Bruzadin Nunes in
%                        colaboration with the INL lab in Carbondale, IL.
%
% Author: Ugo Bruzadin Nunes
%
% Copyright (C) 2021 Ugo Bruzadin Nunes
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software

% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
function vers = eegplugin_QuickLab(fig, try_strings, catch_strings)

vers = 0.1;
% --- QuickLab sumermenu placeholder
supermenu = uimenu(fig, 'label', 'QuickLab');

% --- first submenu: Quick plots
plotmenu = uimenu (supermenu, 'label', 'Quick Plots');

uimenu( plotmenu, 'label', 'Channel Scroll for Interpolation', 'callback', ...
    ['com = pop_eegplot_w2(EEG, 1, 2, 1, 2);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Component Scroll for Interpolation', 'callback', ...
    ['com = pop_eegplot_w2(EEG, 2, 2, 1, 2);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick IClabel & plot', 'callback', ...
    ['EEG = quick_IClabel(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick Plot Channel Spectra 2 to 40hz', 'callback', ...
    ['EEG = quick_spectra(EEG,40,2);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick Plot Channel Spectra as AVG', 'callback', ...
    ['EEG = quick_spectra(EEG,40,2);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

othermenu = uimenu (plotmenu, 'label', 'Other'); 

uimenu( othermenu, 'label', 'Quick IClabel, DIPFIT & plot', 'callback', ...
    ['[EEG,com] = quick_IClabel(EEG,2,55,''default'',1)',...
    '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( othermenu, 'label', 'Quick Plot Channel Spectra 2 to 22hz', 'callback', ...
    ['EEG = quick_spectra(EEG,22,2);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( othermenu, 'label', 'Quick Plot Channel Spectra 18 to 55hz', 'callback', ...
    ['EEG = quick_spectra(EEG,55,18);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( othermenu, 'label', 'Plot Data Difference', 'callback', ...
    ['plotDifference(ALLEEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);
    
printmenu = uimenu (plotmenu, 'label', 'Quick Print'); 

uimenu( printmenu, 'label', 'Print Components', 'callback', ...
    ['print_ICA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( printmenu, 'label', 'Print Marked Components', 'callback', ...
    ['print_RejComponents(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( printmenu, 'label', 'Print FFT', 'callback', ...
    ['print_FFT(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

% plot fft difference!

% --- second submenu: Quick ICA/PCAs
pcamenu = uimenu (supermenu, 'label', 'Quick PCA');

dipfitmenu = uimenu (pcamenu, 'label', 'Quick PCA and DipFit');

uimenu( dipfitmenu, 'label', 'Quick ICA & DipFit', 'callback', ...
    ['EEG = quick_PCA(EEG);EEG = quick_dipfit(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( dipfitmenu, 'label', 'Quick N-1 PCA & DipFit', 'callback', ...
    ['EEG = quick_PCA(EEG,''a'');EEG = quick_dipfit(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

for d=6:2:50
uimenu( dipfitmenu, 'label', strcat('PCA ',num2str(d),' & DipFit'), 'callback', ...
    ['EEG = quick_PCA(EEG,' num2str(d) ');EEG = quick_dipfit(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

uimenu( pcamenu, 'label', 'ICA', 'callback', ...
    ['[EEG,com] = quick_PCA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( pcamenu, 'label', 'N-1 PCA', 'callback', ...
    ['[EEG,com] = quick_PCA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

for i=4:35
uimenu( pcamenu, 'label', strcat('PCA ',num2str(i)), 'callback', ...
    ['[EEG,com] = quick_PCA(EEG,' num2str(i) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end
for i=36:2:50
uimenu( pcamenu, 'label', strcat('PCA ',num2str(i)), 'callback', ...
    ['[EEG,com] = quick_PCA(EEG,' num2str(i) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

secondpcamenu = uimenu (pcamenu, 'label', 'MORE PCAs');
for g=51:75
    uimenu( secondpcamenu, 'label', strcat('PCA ',num2str(g)), 'callback', ...
        ['[EEG,com] = quick_PCA(EEG,' num2str(g) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

try
    if gpuDeviceCount
        cudamenu = uimenu (supermenu, 'label', 'Quick CUDAICA');
        
        uimenu( cudamenu, 'label', 'ICA', 'callback', ...
            ['EEG = quick_PCA(EEG,[],''cudaica'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
        
        uimenu( cudamenu, 'label', 'N-1 PCA', 'callback', ...
            ['EEG = quick_PCA(EEG,EEG,size(EEG.icaact,1)-1),''cudaica'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
        
        for i=4:35
            uimenu( cudamenu, 'label', strcat('PCA ',num2str(i)), 'callback', ...
                ['EEG = quick_PCA(EEG,' num2str(i) ',''cudaica'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
        end
        for i=36:2:50
            uimenu( cudamenu, 'label', strcat('PCA ',num2str(i)), 'callback', ...
                ['EEG = quick_PCA(EEG,' num2str(i) ',''cudaica'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
        end
        
        secondcudamenu = uimenu (cudamenu, 'label', 'MORE PCAs');
        for g=51:75
            uimenu( secondcudamenu, 'label', strcat('PCA ',num2str(g)), 'callback', ...
                ['EEG = quick_PCA(EEG,' num2str(g) ',''cudaica'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
        end
    end
catch
end
% --- third submenu: Quick BSS
uimenu (supermenu, 'label', 'Quick BSS', 'callback', ...
    ['[EEG,com] = quick_bss(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

% uimenu (supermenu, 'label', 'Quick BSS full window', 'callback', ...
%     ['[EEG,com] = quick_bss(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% 

% --- third submenu: Quick channel edits
channelmenu = uimenu (supermenu, 'label', 'Quick Channel Edit');
% - not working yet
% uimenu( channelmenu, 'label', 'Quick Re-reference CZ', 'callback', ...
%     ['[EEG,com] = pop_fastrerefcz(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( channelmenu, 'label', 'Quick Re-reference AVG', 'callback', ...
    ['[EEG,com] = pop_fastrerefavg(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% - not working yet
% uimenu( channelmenu, 'label', 'Quick Re-reference Linked-Mastoids (129)', 'callback', ...
%     ['[EEG,com] = pop_fastrerefavg(EEG,[55,100]);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( channelmenu, 'label', 'Quick Reduce to 98/99 Channels (NIDA 5)', 'callback', ...
    ['[EEG,com] = quick_HM99(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% 
% interpmenu = uimenu( channelmenu, 'label', 'Quick channel interpolation');
% 
% for j=2:7
% uimenu( interpmenu, 'label', strcat('By ',num2str(j),' SDV'), 'callback', ...
%     ['EEG = pop_fastchannelinterp(EEG,' num2str(j) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% end
% 
% uimenu( channelmenu, 'label', 'Quick Interpolate Channels by Components', 'callback', ...
%     ['[EEG] = channelIntByComps(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

filtermenu = uimenu (channelmenu, 'label', 'Quick Filter');

 for a=0.5:0.5:22
 uimenu( filtermenu, 'label', strcat('Quick High Pass ',num2str(a)), 'callback', ...
     ['EEG = quick_lowpass(EEG,' num2str(a) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
 end

for b=14:40
uimenu( filtermenu, 'label', strcat('Quick Low Pass ',num2str(b)), 'callback', ...
    ['EEG = quick_lowpass(EEG,' num2str(b) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

% --- 4th submenu: Quick epoch edits
epochsmenu = uimenu (supermenu, 'label', 'Quick Epoch edits');

for s = 1:5
uimenu( epochsmenu, 'label', strcat('Epoch every_', num2str(s), '_seconds'), 'callback', ...
    ['EEG =  quick_epoch(EEG,',num2str(s), ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

uimenu( epochsmenu, 'label', 'UN-Epoch (Back to Continuous)', 'callback', ...
    ['[EEG,com] =  quick_unepoch(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( epochsmenu, 'label', 'Quick Epoch 0.400 2.448 (DotLoc)', 'callback', ...
    ['[EEG,com] =  quick_epoch(EEG,0.400,2.448);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( epochsmenu, 'label', 'Quick Epoch -1 3.096 (DotLoc)', 'callback', ...
    ['[EEG,com] =  quick_epoch(EEG,-1,3.096);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

rejmenu = uimenu( epochsmenu, 'label', 'Epoch Rejection by probability');

for k=2:7
uimenu( rejmenu, 'label', strcat('By ',num2str(k),' SDV'), 'callback', ...
    ['EEG = quick_trialrejprob(EEG,' num2str(k) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
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
    ['save_corrmappath;[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( corrmenu, 'label', 'Quick Save Selected CorrMaps', 'callback', ...
    ['save_corrmaps(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( corrmenu, 'label', 'Quick Run CorrMap', 'callback', ...
    ['EEG = quick_corrmap(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw']);

% 
% % --- 6th submenu: Run a pipeline
% 
% uimenu( supermenu, 'label', 'Quick Pipeline', 'callback', ...
%     ['[UGO, EEG] = pop_runapipeline();eeglab redraw;']);

% --- 7th submenu: Run a pipeline

parmenu = uimenu( supermenu, 'label', 'Quick Parallel Processes');

uimenu( parmenu, 'label', 'Parallel DipFit 1 Dipole', 'callback', ...
    ['[EEG] = quick_dipfit(EEG); eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;']);

uimenu( parmenu, 'label', 'Parallel DipFit 2 Dipoles', 'callback', ...
    ['[EEG] = quick_dipfit(EEG,[],2); eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;']);

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
