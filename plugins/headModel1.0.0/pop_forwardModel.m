function EEG = pop_forwardModel(EEG, hmfile, conductivity, orientation, recompute)
% Input arguments:
%       conductivity: conductivity of each layer of tissue, scalp - skull - brain,
%                     default: 0.33-0.022-0.33 S/m. See [2, 3, 4] for details.
%        orientation: if true, computes the orientation free lead field, otherwise
%                     it constrain the dipoles to be normal to the cortical surface
            
if isempty(EEG.chanlocs)
    error('Empty EEG.chanlocs, you must load your electrode positions first.');
end

% Select template if not provided
resources = fullfile(fileparts(which('headModel.m')),'resources');
if nargin < 2
    [FileName,PathName,FilterIndex] = uigetfile({'*.mat'},'Select template',resources);
    if ~FilterIndex, return;end
    hmfile = fullfile(PathName,FileName);
elseif ~exist(hmfile,'file')
    [FileName,PathName,FilterIndex] = uigetfile({'*.mat'},'Select template',resources);
    if ~FilterIndex, return;end
    hmfile = fullfile(PathName,FileName);
end
if nargin < 2, conductivity = [0.33 0.022 0.33];end
if nargin < 3, orientation = true;end
if nargin < 4, recompute = true;end

hm = headModel.loadFromFile(hmfile);
labels = {EEG.chanlocs.labels};
xyz = [[EEG.chanlocs.X]' [EEG.chanlocs.Y]' [EEG.chanlocs.Z]'];
if length(labels) ~= size(xyz,1)
    % Some channels are missing their location
    labels = cell(EEG.nbchan,1);
    xyz = zeros(EEG.nbchan,3);
    for k=1:EEG.nbchan
        labels{k} = EEG.chanlocs(k).labels;
        if ~isempty(EEG.chanlocs(k).X)
            xyz(k,:) = [EEG.chanlocs(k).X, EEG.chanlocs(k).Y, EEG.chanlocs(k).Z];
        end
    end
    rmthis = find(sum(xyz,2)==0);
    xyz(rmthis,:) = [];
    labels(rmthis) = [];
    EEG = pop_select(EEG,'nochannel',rmthis);
end

[p,n] = fileparts(fullfile(EEG.filepath,EEG.filename));
hmfile = fullfile(p,[n '_hm.mat']);

[~,loc1,loc2] = intersect(lower(labels),lower(hm.labels),'stable');
if length(labels) == length(loc2)
    hm.labels = labels;
    hm.channelSpace = hm.channelSpace(loc2,:);
    if isempty(hm.channelSpace)
        disp('Cannot coregister based on channel labels, will redurn now!');
        return
    end
    EEG = pop_select(EEG,'channel',loc1);
    if ~isempty(hm.K)
        hm.K = hm.K(loc2,:);
    else
        hm.computeLeadFieldBEM(conductivity,orientation);
    end
elseif ~exist(hmfile,'file') || recompute
    hm.coregister(xyz, labels);
elseif exist(hmfile,'file')
    hm = headModel.loadFromFile(hmfile);
end

% Save the forward model
hm.saveToFile(hmfile);
EEG.etc.src.hmfile = hmfile;
EEG.history = char(EEG.history,'EEG = pop_forwardModel(EEG, hmfile, conductivity, orientation, recompute);');
disp('The forward model was saved in EEG.etc.src')
end