% eegplugin_InverseICA() - Alows one to export and import ICA weights
%                           to re use ICA components from clean or dirty
%                           files to less processed files and obtain a
%                           cleaner and bigger file.

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

function vers = eegplugin_InverseICA(fig, try_strings, catch_strings)

vers = 0.1;
% --- QuickLab sumermenu placeholder
supermenu = uimenu(fig, 'label', 'Inverse ICA');

uimenu( supermenu, 'label', 'Export ICA', 'callback', ...
    ['[EEG,LASTCOM] = pop_export_ica(EEG);' ...
    '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);' ...
    'ALLCOM{end+1} = LASTCOM;' ...
    'eeglab redraw']);

uimenu( supermenu, 'label', 'Import ICA', 'callback', ...
    ['[EEG,LASTCOM] = pop_import_ica(EEG);' ...
    '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);' ...
    'ALLCOM{end+1} = LASTCOM;' ...
    'eeglab redraw']);