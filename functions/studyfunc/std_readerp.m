% std_readerp() - load ERP measures for data channels or 
%                  for all components of a specified cluster.
%                  Called by plotting functions
%                  std_envtopo(), std_erpplot(), std_erspplot(), ...
% Usage:
%         >> [STUDY, datavals, times, setinds, cinds] = ...
%                   std_readerp(STUDY, ALLEEG, varargin);
% Inputs:
%       STUDY - studyset structure containing some or all files in ALLEEG
%      ALLEEG - vector of loaded EEG datasets
%
% Optional inputs:
%  'design'    - [integer] read files from a specific STUDY design. Default
%                is empty (use current design in STUDY.currentdesign). Use
%                NaN to create a design with with all the data.
%  'channels'  - [cell] list of channels to import {default: none}
%  'clusters'  - [integer] list of clusters to import {[]|default: all but
%                the parent cluster (1) and any 'NotClust' clusters}
%  'singletrials' - ['on'|'off'] load single trials spectral data (if 
%                available). Default is 'off'.
%  'subject'   - [string] select a specific subject {default:all}
%  'component' - [integer] select a specific component in a cluster.
%                This is the index of the component in the cluster not the
%                component number {default:all}
%
% ERP specific optional inputs:
%  'timerange' - [min max] time range {default: whole measure range}
%  'componentpol' - ['on'|'off'] invert ERP component sign based on
%                   scalp map match with component scalp map centroid.
%                   {default:'on'}
%
% Output:
%  STUDY    - updated studyset structure
%  datavals  - [cell array] erp data (the cell array size is 
%             condition x groups)
%  times    - [float array] array of time values
%  setinds  - [cell array] datasets indices
%  cinds    - [cell array] channel or component indices
%
% Example:
%  std_precomp(STUDY, ALLEEG, { ALLEEG(1).chanlocs.labels }, 'erp', 'on');
%  [erp times] = std_readerp(STUDY, ALLEEG, 'channels', { ALLEEG(1).chanlocs(1).labels });
%
% Author: Arnaud Delorme, CERCO, 2006-

% Copyright (C) Arnaud Delorme, arno@salk.edu
%
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

function [STUDY, datavals, xvals] = std_readerp(STUDY, ALLEEG, varargin)

if nargin < 2
    help std_readerp;
    return;
end

STUDY = pop_erpparams(STUDY, 'default');
STUDY = pop_specparams(STUDY, 'default');
[opt moreopts] = finputcheck( varargin, { ...
    'design'        'integer' []             STUDY.currentdesign;
    'channels'      'cell'    []             {};
    'clusters'      'integer' []             [];
    'timerange'     'real'    []             STUDY.etc.erpparams.timerange;
    'freqrange'     'real'    []             STUDY.etc.specparams.freqrange;
    'datatype'      'string'  { 'erp','spec' } 'erp';
    'rmsubjmean'    'string'  { 'on','off' } 'off';
    'singletrials'  'string'  { 'on','off' } 'off';
    'componentpol'  'string'  { 'on','off' } 'on';
    'component'     'integer' []             [];
    'subject'       'string'  []             '' }, ...
    'std_readerp', 'ignore');
if isstr(opt), error(opt); end;

dtype = opt.datatype;

% get the file extension
% ----------------------
if ~isempty(opt.channels), fileExt = [ '.dat' opt.datatype ];
else                       fileExt = [ '.ica' opt.datatype ];
end;

% first subject data file
% -----------------------
testSubjectFile = fullfile(ALLEEG(1).filepath, [ ALLEEG(1).subject fileExt ]);

% list of subjects
% ----------------
allSubjects = { STUDY.datasetinfo.subject };
uniqueSubjects = unique(allSubjects);
STUDY.subject = uniqueSubjects;
if ischar(opt.subject) && ~isempty(opt.subject), subjectList = {opt.subject}; else subjectList = opt.subject; end;
if isempty(subjectList)
    if isnan(opt.design), subjectList = STUDY.subject;
    else subjectList = STUDY.design(opt.design).cases.value; 
    end;
end;

% options
% -------
if strcmpi(dtype, 'erp'), opts = { 'timelimits', opt.timerange };
else                      opts = { 'freqlimits', opt.freqrange };
end;
opts = { opts{:} 'singletrials' opt.singletrials };

for iSubj = 1:length(subjectList)
    
    % check cache
    bigstruct = [];
    if ~isempty(opt.channels), bigstruct.channel = opt.channels;
    else                       bigstruct.cluster = opt.clusters; % there can only be one cluster
    end;
    bigstruct.datatype     = opt.datatype;
    bigstruct.singletrials = opt.singletrials;
    bigstruct.subject      = subjectList{iSubj};
    bigstruct.component    = opt.component;
    bigstruct.options      = opts;
    if isnan(opt.design)
         bigstruct.design.variable = struct([]);
    else bigstruct.design.variable = STUDY.design(opt.design).variable;
    end;

    % find component indices
    % ----------------------
    if ~isempty(opt.clusters)
        datasetInds = strmatch(subjectList{iSubj}, { STUDY.datasetinfo.subject }, 'exact');
        compList    = [];
        for iDat = datasetInds(:)'
            indSet   = find(STUDY.cluster(opt.clusters).sets(1,:) == iDat); % each column contain info about the same subject
            compList = [ compList STUDY.cluster(opt.clusters).comps(indSet)' ]; % so we many only consider the first row
        end;
    end;
    
    % read all channels/components at once
    hashcode = gethashcode(std_serialize(bigstruct));
    [STUDY.cache tmpstruct] = eeg_cache(STUDY.cache, hashcode);

    if ~isempty(tmpstruct)
        dataTmp{iSubj}   = tmpstruct{1};
        xvals            = tmpstruct{2};
        eventsTmp{iSubj} = tmpstruct{3};
    else
        datInds = find(strncmp( subjectList{iSubj}, allSubjects, max(cellfun(@length, allSubjects))));
        fileName = fullfile(STUDY.datasetinfo(datInds(1)).filepath, [ subjectList{iSubj} fileExt ]);
        if ~isempty(opt.channels)
             [dataTmp{iSubj} params xvals tmp eventsTmp{iSubj} ] = std_readfile( fileName, 'designvar', bigstruct.design.variable, opts{:}, 'channels', opt.channels);
        else [dataTmp{iSubj} params xvals tmp eventsTmp{iSubj} ] = std_readfile( fileName, 'designvar', bigstruct.design.variable, opts{:}, 'components', compList);
        end;
        if strcmpi(opt.singletrials, 'off') && ~isempty(dataTmp{iSubj}{1})
            dataTmp{iSubj} = cellfun(@(x)squeeze(mean(x,2)), dataTmp{iSubj}, 'uniformoutput', false);
        end;
        STUDY.cache = eeg_cache(STUDY.cache, hashcode, { dataTmp{iSubj} xvals eventsTmp{iSubj} });
    end;
end;

% if single trials put channels in 2nd dim and trials in last dim
if strcmpi(opt.singletrials, 'on') && length(opt.channels) > 1
    for iCase = 1:length(dataTmp)
        for iItem = 1:length(dataTmp{1}(:))
            dataTmp{iCase}{iItem} = permute(dataTmp{iCase}{iItem}, [1 3 2]);
        end;
    end;
end;

% store data for all subjects
if length(opt.channels) > 1
    datavals = reorganizedata(dataTmp, 3);
else datavals = reorganizedata(dataTmp, 2);
end;

% fix component polarity if necessary
% -----------------------------------
componentPol = [];
if isempty(opt.channels) && strcmpi(dtype, 'erp') && isempty(opt.channels) && strcmpi(opt.componentpol, 'on')
    disp('Reading component scalp topo polarities - this is done to invert some ERP component polarities');
    STUDY = std_readtopoclust(STUDY, ALLEEG, opt.clusters);
    componentPol = STUDY.cluster(opt.clusters).topopol;
    if isempty(componentPol)
        disp('Cluster topographies absent - cannot adjust single component ERP polarities');
    end;
    for iItem = 1:length(datavals)
        datavals{iItem} = bsxfun(@times, datavals{iItem}, componentPol);
    end;
end;

return

%         
%     for ind2 = 1:length(finalinds)
%         bigstruct2.channel = opt.channels{ind2};
%         hashcode2 = gethashcode(std_serialize(bigstruct2));
%         tmpChanData  = cellfun(@(x)mean(x(:,:,2),2), dataTmp, 'uniformoutput', false);
%         tmpCache = eeg_cache(tmpCache, hashcode2, { tmpChanData eventsTmp });
%     end;
% end;


for ind = 1:length(finalinds) % scan channels or clusters

    % check if data is already here using hashcode
    % --------------------------------------------
    bigstruct = [];
    if ~isempty(opt.channels), bigstruct.channel = opt.channels{ind};
    else                       bigstruct.cluster = opt.clusters(ind);
    end;
    bigstruct.datatype     = opt.datatype;
    bigstruct.timerange    = opt.timerange;
    bigstruct.freqrange    = opt.freqrange;
    bigstruct.rmsubjmean   = opt.rmsubjmean;
    bigstruct.singletrials = opt.singletrials;
    bigstruct.subject      = opt.subject;
    bigstruct.component    = opt.component;
    if isnan(opt.design)
         bigstruct.design.variable    = struct([]);
    else bigstruct.design  = STUDY.design(opt.design);
    end;
    hashcode = gethashcode(std_serialize(bigstruct));
    [STUDY.cache tmpstruct] = eeg_cache(STUDY.cache, hashcode);
    
    if ~isempty(tmpstruct)
        if isempty(newstruct), newstruct = tmpstruct;
        else                   newstruct(ind) = tmpstruct;
        end;
    else

        % read and cache all data
        % -----------------------
%         if ind  == 1 && length(finalinds) > 5 && ~isempty(opt.channels) && ~isnan(opt.design) && strcmpi(opt.singletrials, 'off')
% 
%         end;
        
        % reading options
        % ---------------
        fprintf([ 'Reading ' dtype ' data...\n' ]);
        
        % get component polarity if necessary
        % -----------------------------------
        componentPol = [];
        if isempty(opt.channels) && strcmpi(dtype, 'erp') && isempty(opt.channels) && strcmpi(opt.componentpol, 'on')
            disp('Reading component scalp topo polarities - this is done to invert some ERP component polarities');
            STUDY = std_readtopoclust(STUDY, ALLEEG, finalinds(ind));
            componentPol = STUDY.cluster(finalinds(ind)).topopol;
            if isempty(componentPol)
                disp('Cluster topographies absent - cannot adjust single component ERP polarities');
            end;
        end;
        
        % read the data and select channels
        % ---------------------------------
        count = 1;
        tmpw = warning;
        warning off;
        for iSubj = 1:length(subjectList)
            datInds = find(strncmp( subjectList{iSubj}, allSubjects, max(cellfun(@length, allSubjects))));
            fileName = fullfile(STUDY.datasetinfo(datInds(1)).filepath, [ subjectList{iSubj} fileExt ]); 
            
            if ~isempty(opt.channels)
                [dataSubject{ iSubj } params xvals tmp events{ iSubj } ] = std_readfile( fileName, 'designvar', bigstruct.design.variable, opts{:}, 'channels', opt.channels(ind));
            else
                % find components for a given cluster and subject
                setInds = [];
                for iDat = 1:length(datInds), setInds = [setInds find(STUDY.cluster(finalinds(ind)).sets(1,:) == datInds(iDat))' ]; end;
                if ~isempty(opt.component), setInds = intersect(setInds, opt.component); end;
                for iComp = 1:length(setInds)
                    comps = STUDY.cluster(finalinds(ind)).comps( setInds(iComp) );
                    [dataSubject{ count } params xvals tmp events{ count } ] = std_readfile( fileName,  'designvar', bigstruct.design.variable, opts{:}, 'components', comps);
                    if ~isempty(componentPol), for iCell = 1:length(dataSubject{ count }(:)), dataSubject{ count }{ iCell } = dataSubject{ count }{ iCell }*componentPol(setInds(iComp)); end; end;
                    count = count+1;
                end;
            end;
        end;
        warning(tmpw);

        % concatenate data - compute average if not dealing with (processing) single trials
        % ---------------------------------------------------------------------------------
        if strcmpi(opt.singletrials, 'off')
            alldata = {};
            for iSubj = 1:length(dataSubject(:))
                for iCell = 1:length(dataSubject{1}(:))
%                     if isempty(dataSubject{ iSubj }{ iCell })
%                         error(sprintf('Subject %s missing one experimental condition, remove subject and try again'));
%                     end;
                    if isempty(dataSubject{ iSubj }{ iCell })
                        alldata{  iCell}(:,iSubj) = NaN;
                    else
                        meanData = mean(dataSubject{ iSubj }{ iCell },2);
                        if exist('alldata', 'var') && (iCell > length(alldata) || size(alldata{  iCell},1) ~= length(meanData))
                            alldata{  iCell} = zeros(length(meanData), length(dataSubject(:)))*NaN; % this is causing problems
                        end;
                        alldata{  iCell}(:,iSubj) = meanData;
                    end;
                    if ~isempty(events{iSubj}{iCell})
                         allevents{iCell}(:,iSubj) = mean(events{ iSubj }{ iCell },2);
                    else allevents{iCell} = [];
                    end;
                end;
            end;
        else
            % calculate dimensions
            alldim = zeros(size(dataSubject{1}));
            for iSubj = 1:length(subjectList)
                for iCell = 1:length(dataSubject{1}(:))
                    alldim(iCell) = alldim(iCell)+size(dataSubject{ iSubj }{ iCell },2);
                end;
            end;
            % initialize arrays
            for iCell = 1:length(dataSubject{1}(:))
                alldata{  iCell} = zeros(size(dataSubject{ 1 }{ 1 },1), alldim(iCell));
                allevents{iCell} = zeros(size(events{      1 }{ 1 },1), alldim(iCell));
            end;
            % populate arrays
            allcounts = zeros(size(dataSubject{1}));
            for iSubj = 1:length(subjectList)
                for iCell = 1:length(dataSubject{1}(:))
                    cols = size(dataSubject{ iSubj }{ iCell },2);
                    alldata{  iCell}(:,allcounts(iCell)+1:allcounts(iCell)+cols) = dataSubject{ iSubj }{ iCell };
                    if ~isempty(events{iSubj}{iCell})
                         allevents{iCell}(:,allcounts(iCell)+1:allcounts(iCell)+cols) = events{ iSubj }{ iCell };
                    else allevents{iCell} = [];
                    end;
                    allcounts(iCell) = allcounts(iCell)+cols;
                end;
            end;
        end;
        alldata   = reshape(alldata  , size(dataSubject{1}));
        allevents = reshape(allevents, size(events{1}));

        % remove mean of each subject across groups and conditions - HAVE TO CHECK HERE ABOUT THE NEW FRAMEWORK
        if strcmpi(dtype, 'spec') && strcmpi(opt.rmsubjmean, 'on') && ~isempty(opt.channels)
            disp('Removing subject''s average spectrum based on pairing settings');
            if strcmpi(paired1, 'on') && strcmpi(paired2, 'on') && (nc > 1 || ng > 1)
                disp('Removing average spectrum for both indep. variables');
                meanpowbase = computemeanspectrum(alldata(:), opt.singletrials);
                alldata     = removemeanspectrum(alldata, meanpowbase);
            elseif strcmpi(paired1, 'on') && ng > 1
                disp('Removing average spectrum for first indep. variables (second indep. var. is unpaired)');
                for g = 1:ng        % ng = number of groups
                    meanpowbase  = computemeanspectrum(alldata(:,g), opt.singletrials);
                    alldata(:,g) = removemeanspectrum(alldata(:,g), meanpowbase);
                end;
            elseif strcmpi(paired2, 'on') && nc > 1
                disp('Removing average spectrum for second indep. variables (first indep. var. is unpaired)');
                for c = 1:nc        % ng = number of groups
                    meanpowbase  = computemeanspectrum(alldata(c,:), opt.singletrials);
                    alldata(c,:) = removemeanspectrum(alldata(c,:), meanpowbase);
                end;
            else
                disp('Not removing average spectrum baseline (both indep. variables are unpaired');
            end;
        end;
        
        newstruct(ind).([ dtype 'data' ]) = alldata;
        newstruct(ind).([ dtype 'vars' ]) = allevents;
        if strcmpi(dtype, 'spec'), newstruct(ind).specfreqs = xvals;
        else                       newstruct(ind).erptimes  = xvals;
        end;
        STUDY.cache = eeg_cache(STUDY.cache, hashcode, newstruct(ind));
        
    end;
end;

% if several channels, agregate them
% ----------------------------------
allinds   = finalinds;
if strcmpi( dtype, 'spec'), xvals = newstruct(1).([ dtype 'freqs' ]);
else                        xvals = newstruct(1).([ dtype 'times' ]);
end;
if ~isempty(opt.channels)
    % concatenate channels if necessary
    datavals  = [];   
    for chan = length(finalinds):-1:1
        tmpdat = newstruct(chan).([ dtype 'data' ]); % only works for interpolated data
        for ind =  1:length(tmpdat(:))
            datavals{ind}(:,:,chan) = tmpdat{ind};
        end;
    end;
    datavals = reshape(datavals, size(tmpdat));
    
    for ind =  1:length(datavals(:))
        datavals{ind} = squeeze(permute(datavals{ind}, [1 3 2])); % time elec subjects
    end;
else
    % in practice clusters are read one by one
    % so it is fine to take the first element only
    datavals = newstruct(1).([ dtype 'data' ]);
end;

% compute mean spectrum
% ---------------------
function meanpowbase = computemeanspectrum(spectrum, singletrials)

    try
        len = length(spectrum(:));
        count = 0;
        for index = 1:len
            if ~isempty(spectrum{index})
                if strcmpi(singletrials, 'on')
                    if count == 0, meanpowbase = mean(spectrum{index},2);
                    else           meanpowbase = meanpowbase + mean(spectrum{index},2);
                    end;
                else
                    if count == 0, meanpowbase = spectrum{index};
                    else           meanpowbase = meanpowbase + spectrum{index};
                    end;
                end;
                count = count+1;
            end;
        end;
        meanpowbase = meanpowbase/count;
    catch,
        error([ 'Problem while subtracting mean spectrum.' 10 ...
                'Common spectrum subtraction is performed based on' 10 ...
                'pairing settings in your design. Most likelly, one' 10 ...
                'independent variable should not have its data paired.' ]);
    end;
        
% remove mean spectrum 
% --------------------
function spectrum = removemeanspectrum(spectrum, meanpowbase)
    for g = 1:size(spectrum,2)        % ng = number of groups
        for c = 1:size(spectrum,1)
            if ~isempty(spectrum{c,g}) && ~isempty(spectrum{c,g})
                if size(spectrum{c,g},2) ~= size(meanpowbase, 2)
                     tmpmeanpowbase = repmat(meanpowbase, [1 size(spectrum{c,g},2)]);
                else tmpmeanpowbase = meanpowbase;
                end;
                spectrum{c,g} = spectrum{c,g} - tmpmeanpowbase;
            end;
        end;
    end;

% reorganize data
% ---------------
function datavals = reorganizedata(dataTmp, dim)
    datavals = cell(size(dataTmp{1}));
    for iItem=1:length(dataTmp{1}(:)')
        numItems = sum(cellfun(@(x)size(x{iItem},dim), dataTmp));
        switch dim
            case 2, datavals{iItem} = zeros([ size(dataTmp{1}{iItem},1) numItems], 'single'); 
            case 3, datavals{iItem} = zeros([ size(dataTmp{1}{iItem},1) size(dataTmp{1}{iItem},2) numItems], 'single'); 
            case 4, datavals{iItem} = zeros([ size(dataTmp{1}{iItem},1) size(dataTmp{1}{iItem},2) size(dataTmp{1}{iItem},3) numItems], 'single'); 
        end;
    end;
    for iItem=1:length(dataTmp{1}(:)')
        count = 1;
        for iCase = 1:length(dataTmp)
            if ~isempty(dataTmp{iCase}{iItem})
                numItems = size(dataTmp{iCase}{iItem},dim);
                switch dim
                    case 2, datavals{iItem}(:,count:count+numItems-1) = dataTmp{iCase}{iItem}; 
                    case 3, datavals{iItem}(:,:,count:count+numItems-1) = dataTmp{iCase}{iItem}; 
                    case 4, datavals{iItem}(:,:,:,count:count+numItems-1) = dataTmp{iCase}{iItem};
                end;
                count = count+numItems;
            end;
        end;
    end;


   