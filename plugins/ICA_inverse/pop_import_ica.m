function [EEG,com] = pop_import_ica(EEG)

%warning: delete current ICA if not empty

% select file

[file,path] = uigetfile(['*.set'],'Select file to load ICA','MultiSelect','off');

% if .set, read EEG, get icaweights
% elseif .mat, load .mat
%e lseif .wth, read wths and load

%if file

if isempty(file) || isempty(path)
    return;
end

com = '';

EEGica = pop_loadset(file, path);

EEG.icaact = [];
EEG.icasphere = [];
EEG.icaweights = [];
EEG.icawinv = [];
%EEG.icachansind = [];
%EEG.icasplinefile = [];

EEG.icaweights = EEGica.icaweights;
EEG.icasphere  = EEGica.icasphere;
EEG.icawinv    = pinv(EEG.icaweights*EEG.icasphere);

ica = icaact(EEG.data,EEG.icaweights*EEG.icasphere);

EEG.icaact = reshape(ica,EEG.nbchan, EEG.pnts, EEG.trials);

EEG = eeg_checkset( EEG );

com = ['EEG = pop_import_ica(EEG)'];

