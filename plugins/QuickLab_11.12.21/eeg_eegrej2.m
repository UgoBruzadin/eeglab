% eeg_eegrej2() - reject porition of continuous data in an EEGLAB
%                dataset
%
% Usage:
%   >> EEGOUT = eeg_eegrej2( EEGIN, regions, chanorcomp, tmprej);
%
% Inputs:
%   INEEG      - input dataset
%   regions    - array of regions to suppress. number x [beg end]  of
%                regions. 'beg' and 'end' are expressed in term of points
%                in the input dataset. Size of the array is
%                number x 2 of regions.
%
% Outputs:
%   INEEG      - output dataset with updated data, events latencies and
%                additional boundary events.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 8 August 2002
% Modified by Ugo Bruzadin Nunes
% See also: eeglab(), eegplot(), pop_rejepoch()

% Copyright (C) 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
% Copyright (C) 2021 Ugo Bruzadin Nunes
%
% This file is part of EEGLAB, see http://www.eeglab.org
% for the documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.

function [EEGOUT, com] = eeg_eegrej2( EEG, regions, chanorcomp, tmprej);

if nargin < 3
    tmprej = 0;
end

if ~isfield(EEG,'myVariables')
    EEG.myVariables = {0 0 '' 0};
end
if size(EEG.myVariables,2) > 1
    plotdiff = EEG.myVariables{2};
else
    plotdiff = 0;
end
if tmprej
    chansorcomps4removal = tmprej;
elseif size(EEG.myVariables,2) > 2
    chansorcomps4removal = EEG.myVariables{3};
else
    chansorcomps4removal = '';
end
if size(EEG.myVariables,2) > 3
    useText = EEG.myVariables{4};
else
    useText = 0;
end

if ~useText
    list_of_chans_or_comps = '';
else
    list_of_chans_or_comps = EEG.myVariables{1};
end

EEG.myVariables = {};

com = '';
if nargin < 2
    help eeg_eegrej;
    return;
end
if nargin< 3
    probadded = [];
    [compOrChan chanliststr] = pop_chansel( { EEG.chanlocs.labels } );
    %channels = inputdlg('choose which of channels to interpolate');
    %channels = str2num(channels{1});
end
if isempty(regions)
    regions = [1,EEG.pnts]
    %return;
end

% regions = sortrows(regions,3); % Arno and Ramon on 5/13/2014 for bug 1605

% Ramon on 5/29/2014 for bug 1619
if size(regions,2) > 2
    regions = sortrows(regions,3);
else
    regions = sortrows(regions,1);
end

% try
%     % For AMICA probabilities...Temporarily add model probabilities as channels
%     %-----------------------------------------------------
%     if isfield(EEG.etc, 'amica') && ~isempty(EEG.etc.amica) && isfield(EEG.etc.amica, 'v_smooth') && ~isempty(EEG.etc.amica.v_smooth) && ~isfield(EEG.etc.amica,'prob_added')
%         if isfield(EEG.etc.amica, 'num_models') && ~isempty(EEG.etc.amica.num_models)
%             if size(EEG.data,2) == size(EEG.etc.amica.v_smooth,2) && size(EEG.data,3) == size(EEG.etc.amica.v_smooth,3) && size(EEG.etc.amica.v_smooth,1) == EEG.etc.amica.num_models
%
%                 EEG = eeg_formatamica(EEG);
%                 %-------------------------------------------
%
%                 [EEG com] = eeg_eegrej(EEG,regions);
%
%                 %-------------------------------------------
%
%                 EEG = eeg_reformatamica(EEG);
%                 EEG = eeg_checkamica(EEG);
%                 return;
%             else
%                 disp('AMICA probabilities not compatible with size of data, probabilities cannot be epoched')
%                 disp('Load AMICA components before extracting epochs')
%                 disp('Resuming rejection...')
%             end
%         end
%
%     end
%     % ------------------------------------------------------
% catch
%     warnmsg = strcat('your dataset contains amica information, but the amica plugin is not installed.  Continuing and ignoring amica information.');
%     warning(warnmsg)
% end


if isfield(EEG.event, 'latency'),
    tmpevent = EEG.event;
    
    tmpdata = EEG.data; % REMOVE THIS, THIS IS FOR DEBUGGING %
    
    tmpalllatencies = [ tmpevent.latency ];
    
else tmpalllatencies = [];
end

% handle regions from eegplot
% ---------------------------
% MODIFIED BY UGO TO INTERPOLATE SELECTED CHANNELS OR COMPONENTS
%EEG.ugo.regions = regions;
%if useText
    %EEG.ugo.chancomp = list_of_chans_or_comps;
    % --- colect channels or components into numbers
%else

% --- start organizing channels and regions

%end

%distribute regions for rejetion and regions for interpolation between
%regions 2 and regions 3 variables

regions_for_interp = regions;
regions_for_rej = [];
rejcounter = 0;

% --- remove the rejection data from regions_for interp with not-green color and add it to
% ---- the variable regions_for_rej
for i=1:size(regions,1)
    if regions(i,3) ~= [0.7]  %check for green color of interpolation %needs to be better!!!
        regions_for_interp(i-rejcounter,:) = [];
        rejcounter = rejcounter + 1;
        regions_for_rej(rejcounter,:) = regions(i,:);
    end
end

chancounter = 0;

for i=1:size(regions_for_interp,1)
    channels = find(regions_for_interp(i,6:end));
    if channels ~= 0
        if ~isempty(list_of_chans_or_comps)
            list_of_chans_or_comps = strcat(list_of_chans_or_comps,';');
        end
        list_of_chans_or_comps = strcat(list_of_chans_or_comps,num2str(channels));
    else
         regions_for_interp(i-chancounter,:) = [];
         chancounter = chancounter + 1;
    end 
end


if size(regions_for_interp,2) > 2, regions_for_interp = regions_for_interp(:, 1:2); end

% if ndims(EEG.data) < 3
%     regions_for_interp = combineregions(regions_for_interp);
%     if (regions_for_interp(1) == 0) && (regions_for_interp(2) == 0)
%         regions_for_interp = regions;
%     end
% end

%Get the split divisions. This was originally made so that one could type
%the channels on a box, which was deprecated, but still installed in case
%needs to be used later.
divisors = strfind(list_of_chans_or_comps,';');
if isempty(divisors)
    divisors = strfind(list_of_chans_or_comps,',');
end

% --- fully interpolate channels or remove components selected (Ugo)
EEGOG = EEG;
EEGmod = EEG;

EEGinterp = EEG;
if ~isempty(list_of_chans_or_comps)
    % --- if only one channel or component was given %MODIFIED BY UGO NUNES JUL/2021
    if isempty(divisors)
        % get channel or component
        compOrChan = str2num(list_of_chans_or_comps);
        % interpolate component or channel for the selected intervals
        if chanorcomp == 1
            EEGinterp = pop_interp(EEG, [compOrChan], 'spherical');
            for i=1:size(regions_for_interp,1)
                
                fprintf(strcat('Interpolating channels(s) _', num2str(compOrChan),' for the period _',num2str(regions_for_interp(i,1)),' to _',num2str(regions_for_interp(i,2))), '\r' );
                EEGmod.data(compOrChan,regions_for_interp(i,1):regions_for_interp(i,2)) = EEGinterp.data(compOrChan,regions_for_interp(i,1):regions_for_interp(i,2));
                
            end
        else
            EEGinterp = pop_subcomp(EEG, [compOrChan]);
            for i=1:size(regions_for_interp,1)
                fprintf(strcat('Interpolating components(s) _', num2str(compOrChan),' for the period _',num2str(regions_for_interp(i,1)),' to _',num2str(regions_for_interp(i,2))), '\r' );
                EEGmod.data(:,regions_for_interp(i,1):regions_for_interp(i,2)) = EEGinterp.data(:,regions_for_interp(i,1):regions_for_interp(i,2));
                %EEGIN.icaact(thisChan,regions(i,1):regions(i,2)) = EEGIN.icaact(thisChan,regions(i,1):regions(i,2));
            end
        end
        
    else % --- else, runs through every region for every component given, assuming the same length
        % adds a 0 to the beggining of the divisions array to facilitate script
        divisors = cat(2,[0],divisors);
        % this is total number of channels selected
        numOfInts = length(divisors);
        % loops the number of channels/comps given and interpolates them
        for j = 1:numOfInts
            % if it's not the final number, collects the channels/components t
            % be interpolated for each selected period of time
            % if it is the final number, does the same for the last numbers
            if j ~= numOfInts
                compOrChan = str2num(list_of_chans_or_comps(divisors(j)+1:divisors(j+1)-1));
            else
                compOrChan = str2num(list_of_chans_or_comps(divisors(j)+1:end));
            end
            
            if chanorcomp == 1
                fprintf(strcat('Interpolating channels(s) _', num2str(compOrChan),' for the period _',num2str(regions_for_interp(j,1)),' to _',num2str(regions_for_interp(j,2))), '\r' );
                EEGinterp = pop_interp(EEG, [compOrChan], 'spherical');
                %for i=1:size(regions,1)
                EEGmod.data(compOrChan,regions_for_interp(j,1):regions_for_interp(j,2)) = EEGinterp.data(compOrChan,regions_for_interp(j,1):regions_for_interp(j,2));
                %end
            else
                fprintf(strcat('Interpolating components(s) _', num2str(compOrChan),' for the period _',num2str(regions_for_interp(j,1)),' to _',num2str(regions_for_interp(j,2))), '\r' );
                EEGinterp = pop_subcomp(EEG,[compOrChan]);
                %for i=1:size(regions,1)
                EEGmod.data(:,regions_for_interp(j,1):regions_for_interp(j,2)) = EEGinterp.data(:,regions_for_interp(j,1):regions_for_interp(j,2));
                %EEGIN.icaact(thisChan,regions(j,1):regions(j,2)) = EEGIN.icaact(thisChan,regions(i,1):regions(i,2));
                %end
            end
        end
    end
    % not using text,only clicks, useText    
end
EEGmod2 = EEGmod;

if ~isempty(chansorcomps4removal)
    if isstring(chansorcomps4removal)
        chansorcomps4removal = str2num(chansorcomps4removal);
    end
    if chanorcomp == 1
        fprintf(strcat('Interpolating channels(s) _', num2str(chansorcomps4removal),'\r' ));
        EEGmod2 = pop_interp(EEGmod, [chansorcomps4removal], 'spherical');
    else
        fprintf(strcat('Removing components(s) _', num2str(chansorcomps4removal),'\r' ));
        EEGmod2 = pop_subcomp(EEGmod, [chansorcomps4removal]);
    end
end

% for plotting the data difference

if plotdiff == 1
    EEGdiff = EEGOG.data - EEGmod2.data;
    eegplot_w2( EEGdiff, 'srate', EEG.srate, 'title', [ 'DIFFERENCE PRE AND POST CHANNEL/COMPONENT INTERPOLATION -- eegplot_w(): ' EEG.setname], ...
        'limits', [EEG.xmin EEG.xmax]*1000 )% , 'command', command, eegplotoptions{:}, varargin{:});
end

%final EEG!
EEGOUT = EEGmod2;

com = sprintf('EEGOUT = eeg_eegrej2( EEGOUT, %s );', vararg2str({ regions, list_of_chans_or_comps, chanorcomp, tmprej }));

%clear rejection variables from EEG variable
if chanorcomp == 1
    if isfield(EEGOUT,'chanrej')
        EEGOUT.chanrej = [];
    end
else
    if isfield(EEGOUT,'comprej')
        EEGOUT.comprej = [];
    end
end

% Run data rejection in case of rejection selected.
if ~isempty(regions_for_rej)
    [EEGOUT2,com] = eeg_eegrej( EEGOUT, regions_for_rej);
end


function res = issameevent(evt1, evt2)

res = true;
if isequal(evt1,evt2)
    return;
else
    if isfield(evt1, 'type') && isnumeric(evt2.type) && ~isnumeric(evt1.type)
        evt2.type = num2str(evt2.type);
        if isequal(evt1,evt2)
            return;
        end
    end
    if isfield(evt1, 'duration') && isfield(evt2, 'duration')
        if isnan(evt1.duration) && isnan(evt2.duration)
            evt1.duration = 1;
            evt2.duration = 1;
        end
        if abs( evt1.duration - evt2.duration) < 1e-10
            evt1.duration = 1;
            evt2.duration = 1;
        end
        if isequal(evt1,evt2)
            return;
        end
    end
    if isfield(evt1, 'latency') && isfield(evt2, 'latency')
        if abs( evt1.latency - evt2.latency) < 1e-10
            evt1.latency = 1;
            evt2.latency = 1;
        end
        if isequal(evt1,evt2)
            return;
        end
    end
end
res = false;
return;

function newregions = combineregions(regions)
% 9/1/2014 RMC
regions = sortrows(sort(regions,2)); % Sorting regions
allreg = [ regions(:,1)' regions(:,2)'; ones(1,numel(regions(:,1))) -ones(1,numel(regions(:,2)')) ].';
allreg = sortrows(allreg,1); % Sort all start and stop points (column 1),

mboundary = cumsum(allreg(:,2)); % Rationale: regions will start always with 1 and close with 0, since starts=1 end=-1
indx = 0; count = 1;

while indx ~= length(allreg)
    newregions(count,1) = allreg(indx+1,1);
    [tmp,I]= min(abs(mboundary(indx+1:end)));
    newregions(count,2) = allreg(I + indx,1);
    indx = indx + I ;
    count = count+1;
end

% Verbose
if size(regions,1) ~= size(newregions,1)
    disp('Warning: overlapping regions detected and fixed in eeg_eegrej');
end
