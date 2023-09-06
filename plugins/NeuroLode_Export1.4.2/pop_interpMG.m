
% pop_interp() - interpolate data channels
%
% Usage: EEGOUT = pop_interp(EEG, badchans, method);
%
% Inputs:
%     EEG      - EEGLAB dataset badchans - [integer array] indices of
%     channels to interpolate.
%                For instance, these channels might be bad. [chanlocs
%                structure] channel location structure containing either
%                locations of channels to interpolate or a full channel
%                structure (missing channels in the current dataset are
%                interpolated).
%     method   - [string] method used for interpolation (default is
%     'spherical').
%                'invdist'/'v4' uses inverse distance on the scalp
%                'spherical' uses superfast spherical interpolation.
%                'spacetime' uses griddata3 to interpolate both in space
%                and time (very slow and cannot be interrupted).
% Output:
%     EEGOUT   - data set with bad electrode data replaced by
%                interpolated data
%
% Author: Arnaud Delorme, CERCO, CNRS, 2009-

% Copyright (C) Arnaud Delorme, CERCO, 2009, arno@salk.edu
%
% This file is part of EEGLAB, see http://www.eeglab.org for the
% documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function [EEG com] = pop_interpMG(EEG, bad_elec, method)

com = '';
if nargin < 1
    help pop_interp;
    return;
end

if nargin < 2
    disp('Warning: interpolation can be done on the fly in studies');
    disp('         this function will actually create channels in the dataset');
    disp('Warning: do not interpolate channels before running ICA');
    disp('You may define channel location to interpolate in the channel');
    disp('editor and declare such channels as non-data channels');
    
    enablenondat = 'off';
    if isfield(EEG.chaninfo, 'nodatchans')
        if ~isempty(EEG.chaninfo.nodatchans)
            enablenondat = 'on';
        end
    end
    
    uilist = { { 'Style' 'text' 'string' 'What channel(s) do you want to interpolate' 'fontweight' 'bold' } ...
        { 'style' 'text' 'string' 'none selected' 'tag' 'chanlist' } ...
        { 'style' 'pushbutton' 'string' 'Select from removed channels' 'callback' 'pop_interp(''nondatchan'',gcbf);' 'enable' enablenondat } ...
        { 'style' 'pushbutton' 'string' 'Select from data channels'    'callback' 'pop_interp(''datchan'',gcbf);' } ...
        { 'style' 'pushbutton' 'string' 'Use specific channels of other dataset' 'callback' 'pop_interp(''selectchan'',gcbf);'} ...
        { 'style' 'pushbutton' 'string' 'Use all channels from other dataset' 'callback' 'pop_interp(''uselist'',gcbf);'} ...
        { } ...
        { 'style' 'text'  'string' 'Interpolation method'} ...
        { 'style' 'popupmenu'  'string' 'Spherical|Planar (slow)'  'tag' 'method' } ...
        };
    
    geom = { 1 1 1 1 1 1 1 [1.1 1] };
    [res userdata tmp restag ] = inputgui( 'uilist', uilist, 'title', 'Interpolate channel(s) -- pop_interp()', 'geometry', geom, 'helpcom', 'pophelp(''pop_interp'')');
    if isempty(res) || isempty(userdata), return; end
    
    if restag.method == 1
        method = 'spherical';
    else method = 'invdist';
    end
    bad_elec = userdata.chans;
    
    com = sprintf('EEG = pop_interp(EEG, %s, %s);', userdata.chanstr, method);
    if ~isempty(findstr('nodatchans', userdata.chanstr))
        eval( [ userdata.chanstr '=[];' ] );
    end
    
elseif ischar(EEG)
    command = EEG;
    clear EEG;
    fig = bad_elec;
    userdata = get(fig, 'userdata');
    
    if strcmpi(command, 'nondatchan')
        global EEG;
        tmpchaninfo = EEG.chaninfo;
        [chanlisttmp chanliststr] = pop_chansel( { tmpchaninfo.nodatchans.labels } );
        if ~isempty(chanlisttmp),
            userdata.chans   = EEG.chaninfo.nodatchans(chanlisttmp);
            userdata.chanstr = [ 'EEG.chaninfo.nodatchans([' num2str(chanlisttmp) '])' ];
            set(fig, 'userdata', userdata);
            set(findobj(fig, 'tag', 'chanlist'), 'string', chanliststr);
        end
    elseif strcmpi(command, 'datchan')
        global EEG;
        tmpchaninfo = EEG.chanlocs;
        [chanlisttmp chanliststr] = pop_chansel( { tmpchaninfo.labels } );
        if ~isempty(chanlisttmp),
            userdata.chans   = chanlisttmp;
            userdata.chanstr = [ '[' num2str(chanlisttmp) ']' ];
            set(fig, 'userdata', userdata);
            set(findobj(fig, 'tag', 'chanlist'), 'string', chanliststr);
        end
    else
        global ALLEEG EEG;
        tmpanswer = inputdlg2({ 'Dataset index' }, 'Choose dataset', 1, { '' });
        if ~isempty(tmpanswer),
            tmpanswernum = round(str2num(tmpanswer{1}));
            if ~isempty(tmpanswernum),
                if tmpanswernum > 0 && tmpanswernum <= length(ALLEEG),
                    TMPEEG = ALLEEG(tmpanswernum);
                    
                    tmpchans1 = TMPEEG.chanlocs;
                    if strcmpi(command, 'selectchan')
                        chanlist = pop_chansel( { tmpchans1.labels } );
                    else
                        chanlist = 1:length(TMPEEG.chanlocs); % use all channels
                    end
                    
                    % look at what new channels are selected
                    tmpchans2 = EEG.chanlocs;
                    [tmpchanlist chaninds] = setdiff_bc( { tmpchans1(chanlist).labels }, { tmpchans2.labels } );
                    if ~isempty(tmpchanlist),
                        if length(chanlist) == length(TMPEEG.chanlocs)
                            userdata.chans   = TMPEEG.chanlocs;
                            userdata.chanstr = [ 'ALLEEG(' tmpanswer{1} ').chanlocs' ];
                        else
                            userdata.chans   = TMPEEG.chanlocs(chanlist(sort(chaninds)));
                            userdata.chanstr = [ 'ALLEEG(' tmpanswer{1} ').chanlocs([' num2str(chanlist(sort(chaninds))) '])' ];
                        end
                        set(fig, 'userdata', userdata);
                        tmpchanlist(2,:) = { ' ' };
                        set(findobj(gcbf, 'tag', 'chanlist'), 'string', [ tmpchanlist{:} ]);
                    else
                        warndlg2('No new channels selected');
                    end
                else
                    warndlg2('Wrong index');
                end
            end
        end
    end
    return;
end

EEG = eeg_interpMG(EEG, bad_elec, method);



% eeg_interp() - interpolate data channels
%
% Usage: EEGOUT = eeg_interp(EEG, badchans, method);
%
% Inputs:
%     EEG      - EEGLAB dataset badchans - [integer array] indices of
%     channels to interpolate.
%                For instance, these channels might be bad. [chanlocs
%                structure] channel location structure containing either
%                locations of channels to interpolate or a full channel
%                structure (missing channels in the current dataset are
%                interpolated).
%     method   - [string] method used for interpolation (default is
%     'spherical').
%                'invdist'/'v4' uses inverse distance on the scalp
%                'spherical' uses superfast spherical interpolation.
%                'spacetime' uses griddata3 to interpolate both in space
%                and time (very slow and cannot be interrupted).
% Output:
%     EEGOUT   - data set with bad electrode data replaced by
%                interpolated data
%
% Author: Arnaud Delorme, CERCO, CNRS, Mai 2006-

% Copyright (C) Arnaud Delorme, CERCO, 2006, arno@salk.edu
%
% This file is part of EEGLAB, see http://www.eeglab.org for the
% documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function EEG = eeg_interpMG(ORIEEG, bad_elec, method)

if nargin < 2
    help eeg_interp;
    return;
end
EEG = ORIEEG;

if nargin < 3
    disp('Using spherical interpolation');
    method = 'spherical';
end

% check channel structure
tmplocs = ORIEEG.chanlocs;
if isempty(tmplocs) || isempty([tmplocs.X])
    error('Interpolation require channel location');
end

if isstruct(bad_elec)
    
    % add missing channels in interpolation structure
    % -----------------------------------------------
    lab1 = { bad_elec.labels };
    tmpchanlocs = EEG.chanlocs;
    lab2 = { tmpchanlocs.labels };
    [tmp tmpchan] = setdiff_bc( lab2, lab1);
    tmpchan = sort(tmpchan);
    
    % From 'bad_elec' using only fields present on EEG.chanlocs
    fields = fieldnames(bad_elec);
    [tmp, indx1] = setxor(fields,fieldnames(EEG.chanlocs)); clear tmp;
    if ~isempty(indx1)
        bad_elec = rmfield(bad_elec,fields(indx1));
        fields = fieldnames(bad_elec);
    end
    
    if ~isempty(tmpchan)
        newchanlocs = [];
        for index = 1:length(fields)
            if isfield(bad_elec, fields{index})
                for cind = 1:length(tmpchan)
                    fieldval = getfield( EEG.chanlocs, { tmpchan(cind) },  fields{index});
                    newchanlocs = setfield(newchanlocs, { cind }, fields{index}, fieldval);
                end
            end
        end
        newchanlocs(end+1:end+length(bad_elec)) = bad_elec;
        bad_elec = newchanlocs;
    end
    if length(EEG.chanlocs) == length(bad_elec), return; end
    
    lab1 = { bad_elec.labels };
    tmpchanlocs = EEG.chanlocs;
    lab2 = { tmpchanlocs.labels };
    [tmp badchans] = setdiff_bc( lab1, lab2);
    %fprintf('Interpolating %d channels...\n', length(badchans));
    if length(badchans) == 0, return; end
    goodchans      = sort(setdiff(1:length(bad_elec), badchans));
    
    % re-order good channels ----------------------
    [tmp1 tmp2 neworder] = intersect_bc( lab1, lab2 );
    [tmp1 ordertmp2] = sort(tmp2);
    neworder = neworder(ordertmp2);
    EEG.data = EEG.data(neworder, :, :);
    
    % looking at channels for ICA ---------------------------
    %[tmp sorti] = sort(neworder);
    %{ EEG.chanlocs(EEG.icachansind).labels; bad_elec(goodchans(sorti(EEG.icachansind))).labels }
    
    % update EEG dataset (add blank channels)
    % ---------------------------------------
    if ~isempty(EEG.icasphere)
        
        [tmp sorti] = sort(neworder);
        EEG.icachansind = sorti(EEG.icachansind);
        EEG.icachansind = goodchans(EEG.icachansind);
        EEG.chaninfo.icachansind = EEG.icachansind;
        
        % TESTING SORTING
        %icachansind = [ 3 4 5 7 8] data = round(rand(8,10)*10) neworder =
        %shuffle(1:8) data2 = data(neworder,:) icachansind2 =
        %sorti(icachansind) data(icachansind,:) data2(icachansind2,:)
    end
    % { EEG.chanlocs(neworder).labels; bad_elec(sort(goodchans)).labels }
    %tmpdata                  = zeros(length(bad_elec), size(EEG.data,2),
    %size(EEG.data,3)); tmpdata(goodchans, :, :) = EEG.data;
    
    % looking at the data -------------------
    %tmp1 = mattocell(EEG.data(sorti,1)); tmp2 =
    %mattocell(tmpdata(goodchans,1));
    %{ EEG.chanlocs.labels; bad_elec(goodchans).labels; tmp1{:}; tmp2{:} }
    %EEG.data      = tmpdata;
    
    EEG.chanlocs  = bad_elec;
    
else
    badchans  = bad_elec;
    goodchans = setdiff_bc(1:EEG.nbchan, badchans);
    oldelocs  = EEG.chanlocs;
    EEG       = pop_selectMG(EEG, 'nochannel', badchans);
    EEG.chanlocs = oldelocs;
    %    disp('Interpolating missing channels...');
end

% find non-empty good channels ----------------------------
origoodchans = goodchans;
chanlocs     = EEG.chanlocs;
nonemptychans = find(~cellfun('isempty', { chanlocs.theta }));
[tmp indgood ] = intersect_bc(goodchans, nonemptychans);
goodchans = goodchans( sort(indgood) );
datachans = getdatachans(goodchans,badchans);
badchans  = intersect_bc(badchans, nonemptychans);
if isempty(badchans), return; end

% scan data points ----------------
if strcmpi(method, 'spherical')
    % get theta, rad of electrodes ----------------------------
    tmpgoodlocs = EEG.chanlocs(goodchans);
    xelec = [ tmpgoodlocs.X ];
    yelec = [ tmpgoodlocs.Y ];
    zelec = [ tmpgoodlocs.Z ];
    rad = sqrt(xelec.^2+yelec.^2+zelec.^2); %MG: Finds raduis (Sphere) of all channels
    xelec = xelec./rad;
    yelec = yelec./rad;
    zelec = zelec./rad;
    tmpbadlocs = EEG.chanlocs(badchans);
    xbad = [ tmpbadlocs.X ];
    ybad = [ tmpbadlocs.Y ];
    zbad = [ tmpbadlocs.Z ];
    rad = sqrt(xbad.^2+ybad.^2+zbad.^2); %MG: Finds raduis (Sphere) of specfic channels
    %MG: So you back here. Hi :) -2016
    xbad = xbad./rad;
    ybad = ybad./rad;
    zbad = zbad./rad;
    
    EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts*EEG.trials);
    %[tmp1 tmp2 tmp3 tmpchans] = spheric_spline_old( xelec, yelec, zelec,
    %EEG.data(goodchans,1)); max(tmpchans(:,1)), std(tmpchans(:,1)), [tmp1
    %tmp2 tmp3 EEG.data(badchans,:)] = spheric_spline( xelec, yelec, zelec,
    %xbad, ybad, zbad, EEG.data(goodchans,:));
    [tmp1 tmp2 tmp3 badchansdata] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, EEG.data(datachans,:));
    %max(EEG.data(goodchans,1)), std(EEG.data(goodchans,1))
    %max(EEG.data(badchans,1)), std(EEG.data(badchans,1))
    EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, EEG.trials);
elseif strcmpi(method, 'spacetime') % 3D interpolation, works but x10 times slower
    disp('Warning: if processing epoch data, epoch boundary are ignored...');
    disp('3-D interpolation, this can take a long (long) time...');
    tmpgoodlocs = EEG.chanlocs(goodchans);
    tmpbadlocs = EEG.chanlocs(badchans);
    [xbad ,ybad]  = pol2cart([tmpbadlocs.theta],[tmpbadlocs.radius]);
    [xgood,ygood] = pol2cart([tmpgoodlocs.theta],[tmpgoodlocs.radius]);
    pnts = size(EEG.data,2)*size(EEG.data,3);
    zgood = [1:pnts];
    zgood = repmat(zgood, [length(xgood) 1]);
    zgood = reshape(zgood,prod(size(zgood)),1);
    xgood = repmat(xgood, [1 pnts]); xgood = reshape(xgood,prod(size(xgood)),1);
    ygood = repmat(ygood, [1 pnts]); ygood = reshape(ygood,prod(size(ygood)),1);
    tmpdata = reshape(EEG.data, prod(size(EEG.data)),1);
    zbad = 1:pnts;
    zbad = repmat(zbad, [length(xbad) 1]);
    zbad = reshape(zbad,prod(size(zbad)),1);
    xbad = repmat(xbad, [1 pnts]); xbad = reshape(xbad,prod(size(xbad)),1);
    ybad = repmat(ybad, [1 pnts]); ybad = reshape(ybad,prod(size(ybad)),1);
    badchansdata = griddata3(ygood, xgood, zgood, tmpdata,...
        ybad, xbad, zbad, 'nearest'); % interpolate data
else
    % get theta, rad of electrodes ----------------------------
    tmpchanlocs = EEG.chanlocs;
    [xbad ,ybad]  = pol2cart([tmpchanlocs( badchans).theta],[tmpchanlocs( badchans).radius]);
    [xgood,ygood] = pol2cart([tmpchanlocs(goodchans).theta],[tmpchanlocs(goodchans).radius]);
    
    fprintf('Points (/%d):', size(EEG.data,2)*size(EEG.data,3));
    badchansdata = zeros(length(badchans), size(EEG.data,2)*size(EEG.data,3));
    
    for t=1:(size(EEG.data,2)*size(EEG.data,3)) % scan data points
        if mod(t,100) == 0, fprintf('%d ', t); end
        if mod(t,1000) == 0, fprintf('\n'); end;
        
        %for c = 1:length(badchans)
        %   [h EEG.data(badchans(c),t)]=
        %   topoplot(EEG.data(goodchans,t),EEG.chanlocs(goodchans),'noplot',
        %   ...
        %        [EEG.chanlocs( badchans(c)).radius EEG.chanlocs(
        %        badchans(c)).theta]);
        %end
        tmpdata = reshape(EEG.data, size(EEG.data,1), size(EEG.data,2)*size(EEG.data,3) );
        if strcmpi(method, 'invdist'), method = 'v4'; end
        [Xi,Yi,badchansdata(:,t)] = griddata(ygood, xgood , double(tmpdata(datachans,t)'),...
            ybad, xbad, method); % interpolate data
    end
    fprintf('\n');
end

tmpdata               = zeros(length(bad_elec), EEG.pnts, EEG.trials);
tmpdata(origoodchans, :,:) = EEG.data;
%if input data are epoched reshape badchansdata for Octave compatibility...
if length(size(tmpdata))==3
    badchansdata = reshape(badchansdata,length(badchans),size(tmpdata,2),size(tmpdata,3));
end
tmpdata(badchans,:,:) = badchansdata;
EEG.data = tmpdata;
EEG.nbchan = size(EEG.data,1);
EEG = eeg_checksetMG(EEG);
% get data channels -----------------
function datachans = getdatachans(goodchans, badchans);
datachans = goodchans;
badchans  = sort(badchans);
for index = length(badchans):-1:1
    datachans(find(datachans > badchans(index))) = datachans(find(datachans > badchans(index)))-1;
end

% ----------------- spherical splines -----------------
function [x, y, z, Res] = spheric_spline_old( xelec, yelec, zelec, values);

SPHERERES = 20;
[x,y,z] = sphere(SPHERERES);
x(1:(length(x)-1)/2,:) = []; x = [ x(:)' ];
y(1:(length(y)-1)/2,:) = []; y = [ y(:)' ];
z(1:(length(z)-1)/2,:) = []; z = [ z(:)' ];

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(x,y,z,xelec,yelec,zelec);

% equations are Gelec*C + C0  = Potential (C unknow) Sum(c_i) = 0 so
%             [c_1]
%      *      [c_2]
%             [c_ ]
%    xelec    [c_n]
% [x x x x x]         [potential_1] [x x x x x]         [potential_ ] [x x
% x x x]       = [potential_ ] [x x x x x]         [potential_4] [1 1 1 1
% 1]         [0]

% compute solution for parameters C ---------------------------------
meanvalues = mean(values);
values = values - meanvalues; % make mean zero
C = pinv([Gelec;ones(1,length(Gelec))]) * [values(:);0];

% apply results -------------
Res = zeros(1,size(Gsph,1));
for j = 1:size(Gsph,1)
    Res(j) = sum(C .* Gsph(j,:)');
end
Res = Res + meanvalues;
Res = reshape(Res, length(x(:)),1);



function [xbad, ybad, zbad, allres] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, values);

newchans = length(xbad);
numpoints = size(values,2);

%SPHERERES = 20; [x,y,z] = sphere(SPHERERES); x(1:(length(x)-1)/2,:) = [];
%xbad = [ x(:)']; y(1:(length(x)-1)/2,:) = []; ybad = [ y(:)'];
%z(1:(length(x)-1)/2,:) = []; zbad = [ z(:)'];

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(xbad,ybad,zbad,xelec,yelec,zelec);

% compute solution for parameters C ---------------------------------
meanvalues = mean(values);
values = values - repmat(meanvalues, [size(values,1) 1]); % make mean zero

values = [values;zeros(1,numpoints)];
C = pinv([Gelec;ones(1,length(Gelec))]) * values;
clear values;
allres = zeros(newchans, numpoints);

% apply results -------------
for j = 1:size(Gsph,1)
    allres(j,:) = sum(C .* repmat(Gsph(j,:)', [1 size(C,2)]));
end
allres = allres + repmat(meanvalues, [size(allres,1) 1]);



% compute G function ------------------
function g = computeg(x,y,z,xelec,yelec,zelec)

unitmat = ones(length(x(:)),length(xelec));
EI = unitmat - sqrt((repmat(x(:),1,length(xelec)) - repmat(xelec,length(x(:)),1)).^2 +...
    (repmat(y(:),1,length(xelec)) - repmat(yelec,length(x(:)),1)).^2 +...
    (repmat(z(:),1,length(xelec)) - repmat(zelec,length(x(:)),1)).^2);

g = zeros(length(x(:)),length(xelec));
%dsafds
m = 4; % 3 is linear, 4 is best according to Perrin's curve
for n = 1:7
    if ismatlab
        L = legendre(n,EI);
    else % Octave legendre function cannot process 2-D matrices
        for icol = 1:size(EI,2)
            tmpL = legendre(n,EI(:,icol));
            if icol == 1, L = zeros([ size(tmpL) size(EI,2)]); end
            L(:,:,icol) = tmpL;
        end
    end
    g = g + ((2*n+1)/(n^m*(n+1)^m))*squeeze(L(1,:,:));
end
g = g/(4*pi);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [EEG] = export2formatI(EEG, List)
DataSheet1 = List;
t = datestr(now, 'mm_dd_yyyy-HHMM');
t = string(t);
t = t(1,1);
Report_Name = strcat('InterpMapAutoBased',t);

T = cell2table(List,...
    'VariableNames',{'Center Electrode'...
    'Surrounding Ele Colm 1'...
    'Surrounding Ele Colm 2'...
    'Surrounding Ele Colm 3'...
    'Surrounding Ele Colm 4'...
    'Surrounding Ele Colm 5'...
    'Surrounding Ele Colm 6'...
    'Surrounding Ele Colm 7'...
    'Surrounding Ele Colm 8'...
    'Surrounding Ele Colm 9'...
    });
try
    Report_Name = char(Report_Name);
    Report_Name0 = strcat(Report_Name,'.xlsx');
    writetable(T,Report_Name0,'WriteVariableNames',false);
catch
    Report_Name = char(Report_Name);
    Report_Name0 = strcat(Report_Name,'.dat');
    writetable(T,Report_Name);
end
return
function [handle,Zi,grid,Xi,Yi] = topoplot(Values,loc_file,varargin)

%
%%%%%%%%%%%%%%%%%%%%%%%% Set defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
icadefs                 % read defaults MAXTOPOPLOTCHANS and DEFAULT_ELOC and BACKCOLOR
if ~exist('BACKCOLOR')  % if icadefs.m does not define BACKCOLOR
    BACKCOLOR = [.93 .96 1];  % EEGLAB standard
end
whitebk = 'off';  % by default, make gridplot background color = EEGLAB screen background color

persistent warningInterp;

plotgrid = 'off';
plotchans = [];
noplot  = 'off';
handle = [];
Zi = [];
chanval = NaN;
rmax = 0.5;             % actual head radius - Don't change this!
INTERPLIMITS = 'head';  % head, electrodes
INTSQUARE = 'on';       % default, interpolate electrodes located though the whole square containing
% the plotting disk
default_intrad = 1;     % indicator for (no) specified intrad
MAPLIMITS = 'absmax';   % absmax, maxmin, [values]
GRID_SCALE = 67;        % plot map on a 67X67 grid
CIRCGRID   = 201;       % number of angles to use in drawing circles
AXHEADFAC = 1.3;        % head to axes scaling factor
CONTOURNUM = 6;         % number of contour levels to plot
STYLE = 'both';         % default 'style': both,straight,fill,contour,blank
HEADCOLOR = [0 0 0];    % default head color (black)
CCOLOR = [0.2 0.2 0.2]; % default contour color
ELECTRODES = [];        % default 'electrodes': on|off|label - set below
MAXDEFAULTSHOWLOCS = 64;% if more channels than this, don't show electrode locations by default
EMARKER = '.';          % mark electrode locations with small disks
ECOLOR = [0 0 0];       % default electrode color = black
EMARKERSIZE = [];       % default depends on number of electrodes, set in code
EMARKERLINEWIDTH = 1;   % default edge linewidth for emarkers
EMARKERSIZE1CHAN = 20;  % default selected channel location marker size
EMARKERCOLOR1CHAN = 'red'; % selected channel location marker color
EMARKER2CHANS = [];      % mark subset of electrode locations with small disks
EMARKER2 = 'o';          % mark subset of electrode locations with small disks
EMARKER2COLOR = 'r';     % mark subset of electrode locations with small disks
EMARKERSIZE2 = 10;      % default selected channel location marker size
EMARKER2LINEWIDTH = 1;
EFSIZE = get(0,'DefaultAxesFontSize'); % use current default fontsize for electrode labels
HLINEWIDTH = 2;         % default linewidth for head, nose, ears
BLANKINGRINGWIDTH = .035;% width of the blanking ring
HEADRINGWIDTH    = .007;% width of the cartoon head ring
SHADING = 'flat';       % default 'shading': flat|interp
shrinkfactor = [];      % shrink mode (dprecated)
intrad       = [];      % default interpolation square is to outermost electrode (<=1.0)
plotrad      = [];      % plotting radius ([] = auto, based on outermost channel location)
headrad      = [];      % default plotting radius for cartoon head is 0.5
squeezefac = 1.0;
MINPLOTRAD = 0.15;      % can't make a topoplot with smaller plotrad (contours fail)
VERBOSE = 'off';
MASKSURF = 'off';
CONVHULL = 'off';       % dont mask outside the electrodes convex hull
DRAWAXIS = 'off';
PLOTDISK = 'off';
ContourVals = Values;
PMASKFLAG   = 0;
COLORARRAY  = { [1 0 0] [0.5 0 0] [0 0 0] };
%COLORARRAY2 = { [1 0 0] [0.5 0 0] [0 0 0] };
gb = [0 0];
COLORARRAY2 = { [gb 0] [gb 1/4] [gb 2/4] [gb 3/4] [gb 1] };

%%%%%% Dipole defaults %%%%%%%%%%%%
DIPOLE  = [];
DIPNORM   = 'on';
DIPNORMMAX = 'off';
DIPSPHERE = 85;
DIPLEN    = 1;
DIPSCALE  = 1;
DIPORIENT  = 1;
DIPCOLOR  = [0 0 0];
NOSEDIR   = '+X';
CHANINFO  = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%%%%%%%%%%%%%%%%%%%%%%% Handle arguments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin< 1
    help topoplot;
    return
end

% calling topoplot from Fieldtrip
% -------------------------------
fieldtrip = 0;
if nargin < 2, loc_file = []; end
if isstruct(Values) || ~isstruct(loc_file), fieldtrip == 1; end
if ischar(loc_file), if exist(loc_file) ~= 2, fieldtrip == 1; end; end
if fieldtrip
    error('Wrong calling format, are you trying to use the topoplot Fieldtrip function?');
end

nargs = nargin;
if nargs == 1
    if ischar(Values)
        if any(strcmp(lower(Values),{'example','demo'}))
            fprintf(['This is an example of an electrode location file,\n',...
                'an ascii file consisting of the following four columns:\n',...
                ' channel_number degrees arc_length channel_name\n\n',...
                'Example:\n',...
                ' 1               -18    .352       Fp1 \n',...
                ' 2                18    .352       Fp2 \n',...
                ' 5               -90    .181       C3  \n',...
                ' 6                90    .181       C4  \n',...
                ' 7               -90    .500       A1  \n',...
                ' 8                90    .500       A2  \n',...
                ' 9              -142    .231       P3  \n',...
                '10               142    .231       P4  \n',...
                '11                 0    .181       Fz  \n',...
                '12                 0    0          Cz  \n',...
                '13               180    .181       Pz  \n\n',...
                ...
                'In topoplot() coordinates, 0 deg. points to the nose, positive\n',...
                'angles point to the right hemisphere, and negative to the left.\n',...
                'The model head sphere has a circumference of 2; the vertex\n',...
                '(Cz) has arc_length 0. Locations with arc_length > 0.5 are below\n',...
                'head center and are plotted outside the head cartoon.\n',...
                'Option plotrad controls how much of this lower-head "skirt" is shown.\n',...
                'Option headrad controls if and where the cartoon head will be drawn.\n',...
                'Option intrad controls how many channels will be included in the interpolation.\n',...
                ])
            return
        end
    end
end
if nargs < 2
    loc_file = DEFAULT_ELOC;
    if ~exist(loc_file)
        fprintf('default locations file "%s" not found - specify chan_locs in topoplot() call.\n',loc_file)
        error(' ')
    end
end
if isempty(loc_file)
    loc_file = 0;
end
if isnumeric(loc_file) && loc_file == 0
    loc_file = DEFAULT_ELOC;
end

if nargs > 2
    if ~(round(nargs/2) == nargs/2)
        error('Odd number of input arguments??')
    end
    for i = 1:2:length(varargin)
        Param = varargin{i};
        Value = varargin{i+1};
        if ~ischar(Param)
            error('Flag arguments must be strings')
        end
        Param = lower(Param);
        switch Param
            case 'conv'
                CONVHULL = lower(Value);
                if ~strcmp(CONVHULL,'on') && ~strcmp(CONVHULL,'off')
                    error('Value of ''conv'' must be ''on'' or ''off''.');
                end
            case 'colormap'
                if size(Value,2)~=3
                    error('Colormap must be a n x 3 matrix')
                end
                colormap(Value)
            case 'gridscale'
                GRID_SCALE = Value;
            case 'plotdisk'
                PLOTDISK = lower(Value);
                if ~strcmp(PLOTDISK,'on') && ~strcmp(PLOTDISK,'off')
                    error('Value of ''plotdisk'' must be ''on'' or ''off''.');
                end
            case 'intsquare'
                INTSQUARE = lower(Value);
                if ~strcmp(INTSQUARE,'on') && ~strcmp(INTSQUARE,'off')
                    error('Value of ''intsquare'' must be ''on'' or ''off''.');
                end
            case 'emarkercolors'
                COLORARRAY = Value;
            case {'interplimits','headlimits'}
                if ~ischar(Value)
                    error('''interplimits'' value must be a string')
                end
                Value = lower(Value);
                if ~strcmp(Value,'electrodes') && ~strcmp(Value,'head')
                    error('Incorrect value for interplimits')
                end
                INTERPLIMITS = Value;
            case 'verbose'
                VERBOSE = Value;
            case 'nosedir'
                NOSEDIR = Value;
                if isempty(strmatch(lower(NOSEDIR), { '+x', '-x', '+y', '-y' }))
                    error('Invalid nose direction');
                end
            case 'chaninfo'
                CHANINFO = Value;
                if isfield(CHANINFO, 'nosedir'), NOSEDIR      = CHANINFO.nosedir; end
                if isfield(CHANINFO, 'shrink' ), shrinkfactor = CHANINFO.shrink;  end
                if isfield(CHANINFO, 'plotrad') && isempty(plotrad), plotrad = CHANINFO.plotrad; end
            case 'chantype'
            case 'drawaxis'
                DRAWAXIS = Value;
            case 'maplimits'
                MAPLIMITS = Value;
            case 'masksurf'
                MASKSURF = Value;
            case 'circgrid'
                CIRCGRID = Value;
                if ischar(CIRCGRID) || CIRCGRID<100
                    error('''circgrid'' value must be an int > 100');
                end
            case 'style'
                STYLE = lower(Value);
            case 'numcontour'
                CONTOURNUM = Value;
            case 'electrodes'
                ELECTRODES = lower(Value);
                if strcmpi(ELECTRODES,'pointlabels') || strcmpi(ELECTRODES,'ptslabels') ...
                        | strcmpi(ELECTRODES,'labelspts') | strcmpi(ELECTRODES,'ptlabels') ...
                        | strcmpi(ELECTRODES,'labelpts')
                    ELECTRODES = 'labelpoint'; % backwards compatability
                elseif strcmpi(ELECTRODES,'pointnumbers') || strcmpi(ELECTRODES,'ptsnumbers') ...
                        | strcmpi(ELECTRODES,'numberspts') | strcmpi(ELECTRODES,'ptnumbers') ...
                        | strcmpi(ELECTRODES,'numberpts')  | strcmpi(ELECTRODES,'ptsnums')  ...
                        | strcmpi(ELECTRODES,'numspts')
                    ELECTRODES = 'numpoint'; % backwards compatability
                elseif strcmpi(ELECTRODES,'nums')
                    ELECTRODES = 'numbers'; % backwards compatability
                elseif strcmpi(ELECTRODES,'pts')
                    ELECTRODES = 'on'; % backwards compatability
                elseif ~strcmp(ELECTRODES,'off') ...
                        & ~strcmpi(ELECTRODES,'on') ...
                        & ~strcmp(ELECTRODES,'labels') ...
                        & ~strcmpi(ELECTRODES,'numbers') ...
                        & ~strcmpi(ELECTRODES,'labelpoint') ...
                        & ~strcmpi(ELECTRODES,'numpoint')
                    error('Unknown value for keyword ''electrodes''');
                end
            case 'dipole'
                DIPOLE = Value;
            case 'dipsphere'
                DIPSPHERE = Value;
            case {'dipnorm', 'dipnormmax'}
                if strcmp(Param,'dipnorm')
                    DIPNORM = Value;
                    if strcmpi(Value,'on')
                        DIPNORMMAX = 'off';
                    end
                else
                    DIPNORMMAX = Value;
                    if strcmpi(Value,'on')
                        DIPNORM = 'off';
                    end
                end
                
            case 'diplen'
                DIPLEN = Value;
            case 'dipscale'
                DIPSCALE = Value;
            case 'contourvals'
                ContourVals = Value;
            case 'pmask'
                ContourVals = Value;
                PMASKFLAG   = 1;
            case 'diporient'
                DIPORIENT = Value;
            case 'dipcolor'
                DIPCOLOR = Value;
            case 'emarker'
                if ischar(Value)
                    EMARKER = Value;
                elseif ~iscell(Value) || length(Value) > 4
                    error('''emarker'' argument must be a cell array {marker color size linewidth}')
                else
                    EMARKER = Value{1};
                end
                if length(Value) > 1
                    ECOLOR = Value{2};
                end
                if length(Value) > 2
                    EMARKERSIZE = Value{3};
                end
                if length(Value) > 3
                    EMARKERLINEWIDTH = Value{4};
                end
            case 'emarker2'
                if ~iscell(Value) || length(Value) > 5
                    error('''emarker2'' argument must be a cell array {chans marker color size linewidth}')
                end
                EMARKER2CHANS = abs(Value{1}); % ignore channels < 0
                if length(Value) > 1
                    EMARKER2 = Value{2};
                end
                if length(Value) > 2
                    EMARKER2COLOR = Value{3};
                end
                if length(Value) > 3
                    EMARKERSIZE2 = Value{4};
                end
                if length(Value) > 4
                    EMARKER2LINEWIDTH = Value{5};
                end
            case 'shrink'
                shrinkfactor = Value;
            case 'intrad'
                intrad = Value;
                if ischar(intrad) || (intrad < MINPLOTRAD || intrad > 1)
                    error('intrad argument should be a number between 0.15 and 1.0');
                end
            case 'plotrad'
                plotrad = Value;
                if ~isempty(plotrad) && (ischar(plotrad) || (plotrad < MINPLOTRAD || plotrad > 1))
                    error('plotrad argument should be a number between 0.15 and 1.0');
                end
            case 'headrad'
                headrad = Value;
                if ischar(headrad) && ( strcmpi(headrad,'off') || strcmpi(headrad,'none') )
                    headrad = 0;       % undocumented 'no head' alternatives
                end
                if isempty(headrad) % [] -> none also
                    headrad = 0;
                end
                if ~ischar(headrad)
                    if ~(headrad==0) && (headrad < MINPLOTRAD || headrad>1)
                        error('bad value for headrad');
                    end
                elseif  ~strcmpi(headrad,'rim')
                    error('bad value for headrad');
                end
            case {'headcolor','hcolor'}
                HEADCOLOR = Value;
            case {'contourcolor','ccolor'}
                CCOLOR = Value;
            case {'electcolor','ecolor'}
                ECOLOR = Value;
            case {'emarkersize','emsize'}
                EMARKERSIZE = Value;
            case {'emarkersize1chan','emarkersizemark'}
                EMARKERSIZE1CHAN= Value;
            case {'efontsize','efsize'}
                EFSIZE = Value;
            case 'shading'
                SHADING = lower(Value);
                if ~any(strcmp(SHADING,{'flat','interp'}))
                    error('Invalid shading parameter')
                end
                if strcmpi(SHADING,'interp') && isempty(warningInterp)
                    warning('Using interpolated shading in scalp topographies prevent to export them as vectorized figures');
                    warningInterp = 1;
                end
            case 'noplot'
                noplot = Value;
                if ~ischar(noplot)
                    if length(noplot) ~= 2
                        error('''noplot'' location should be [radius, angle]')
                    else
                        chanrad = noplot(1);
                        chantheta = noplot(2);
                        noplot = 'on';
                    end
                end
            case 'gridscale'
                GRID_SCALE = Value;
                if ischar(GRID_SCALE) || GRID_SCALE ~= round(GRID_SCALE) || GRID_SCALE < 32
                    error('''gridscale'' value must be integer > 32.');
                end
            case {'plotgrid','gridplot'}
                plotgrid = 'on';
                gridchans = Value;
            case 'plotchans'
                plotchans = Value(:);
                if find(plotchans<=0)
                    error('''plotchans'' values must be > 0');
                end
                % if max(abs(plotchans))>max(Values) | max(abs(plotchans))>length(Values) -sm ???
            case {'whitebk','whiteback','forprint'}
                whitebk = Value;
            case {'iclabel'} % list of options to ignore
            otherwise
                error(['Unknown input parameter ''' Param ''' ???'])
        end
    end
end

if strcmpi(whitebk, 'on')
    BACKCOLOR = [ 1 1 1 ];
end

if isempty(find(strcmp(varargin,'colormap')))
    if exist('DEFAULT_COLORMAP','var')
        cmap = colormap(DEFAULT_COLORMAP);
    else
        cmap = parula;
    end
else
    cmap = colormap;
end
if strcmp(noplot,'on'), close(gcf); end
cmaplen = size(cmap,1);

if strcmp(STYLE,'blank')    % else if Values holds numbers of channels to mark
    if length(Values) < length(loc_file)
        ContourVals = zeros(1,length(loc_file));
        ContourVals(Values) = 1;
        Values = ContourVals;
    end
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%% test args for plotting an electrode grid %%%%%%%%%%%%%%%%%%%%%%
%
if strcmp(plotgrid,'on')
    STYLE = 'grid';
    gchans = sort(find(abs(gridchans(:))>0));
    
    % if setdiff(gchans,unique(gchans))
    %      fprintf('topoplot() warning: ''plotgrid'' channel matrix has duplicate channels\n');
    % end
    
    if ~isempty(plotchans)
        if intersect(gchans,abs(plotchans))
            fprintf('topoplot() warning: ''plotgrid'' and ''plotchans'' have channels in common\n');
        end
    end
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%% misc arg tests %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if isempty(ELECTRODES)                     % if electrode labeling not specified
    if length(Values) > MAXDEFAULTSHOWLOCS   % if more channels than default max
        ELECTRODES = 'off';                    % don't show electrodes
    else                                     % else if fewer chans,
        ELECTRODES = 'on';                     % do
    end
end

if isempty(Values)
    STYLE = 'blank';
end
[r,c] = size(Values);
if r>1 && c>1,
    error('input data must be a single vector');
end
Values = Values(:); % make Values a column vector
ContourVals = ContourVals(:); % values for contour

if ~isempty(intrad) && ~isempty(plotrad) && intrad < plotrad
    error('intrad must be >= plotrad');
end

if ~strcmpi(STYLE,'grid')                     % if not plot grid only
    
    %
    %%%%%%%%%%%%%%%%%%%% Read the channel location information %%%%%%%%%%%%%%%%%%%%%%%%
    %
    if ischar(loc_file)
        [tmpeloc labels Th Rd indices] = readlocs( loc_file);
    elseif isstruct(loc_file) % a locs struct
        [tmpeloc labels Th Rd indices] = readlocs( loc_file );
        % Note: Th and Rd correspond to indices channels-with-coordinates only
    else
        error('loc_file must be a EEG.locs struct or locs filename');
    end
    Th = pi/180*Th;                              % convert degrees to radians
    allchansind = 1:length(Th);
    
    
    if ~isempty(plotchans)
        if max(plotchans) > length(Th)
            error('''plotchans'' values must be <= max channel index');
        end
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% channels to plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if ~isempty(plotchans)
        plotchans = intersect_bc(plotchans, indices);
    end
    if ~isempty(Values) && ~strcmpi( STYLE, 'blank') && isempty(plotchans)
        plotchans = indices;
    end
    if isempty(plotchans) && strcmpi( STYLE, 'blank')
        plotchans = indices;
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%% filter channels used for components %%%%%%%%%%%%%%%%%%%%%
    %
    if isfield(CHANINFO, 'icachansind') && ~isempty(Values) && length(Values) ~= length(tmpeloc)
        
        % test if ICA component
        % ---------------------
        if length(CHANINFO.icachansind) == length(Values)
            
            % if only a subset of channels are to be plotted
            % and ICA components also use a subject of channel
            % we must find the new indices for these channels
            
            plotchans = intersect_bc(CHANINFO.icachansind, plotchans);
            tmpvals   = zeros(1, length(tmpeloc));
            tmpvals(CHANINFO.icachansind) = Values;
            Values    = tmpvals;
            tmpvals   = zeros(1, length(tmpeloc));
            tmpvals(CHANINFO.icachansind) = ContourVals;
            ContourVals = tmpvals;
            
        end
    end
    
    %
    %%%%%%%%%%%%%%%%%%% last channel is reference? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if length(tmpeloc) == length(Values) + 1 % remove last channel if necessary
        % (common reference channel)
        if plotchans(end) == length(tmpeloc)
            plotchans(end) = [];
        end
        
    end
    
    %
    %%%%%%%%%%%%%%%%%%% remove infinite and NaN values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if length(Values) > 1
        inds          = union_bc(find(isnan(Values)), find(isinf(Values))); % NaN and Inf values
        plotchans     = setdiff_bc(plotchans, inds);
    end
    if strcmp(plotgrid,'on')
        plotchans = setxor(plotchans,gchans);   % remove grid chans from head plotchans
    end
    
    [x,y]     = pol2cart(Th,Rd);  % transform electrode locations from polar to cartesian coordinates
    plotchans = abs(plotchans);   % reverse indicated channel polarities
    allchansind = allchansind(plotchans);
    Th        = Th(plotchans);
    Rd        = Rd(plotchans);
    x         = x(plotchans);
    y         = y(plotchans);
    labels    = labels(plotchans); % remove labels for electrodes without locations
    labels    = strvcat(labels); % make a label string matrix
    if ~isempty(Values) && length(Values) > 1
        Values      = Values(plotchans);
        ContourVals = ContourVals(plotchans);
    end
    
    %
    %%%%%%%%%%%%%%%%%% Read plotting radius from chanlocs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if isempty(plotrad) && isfield(tmpeloc, 'plotrad'),
        plotrad = tmpeloc(1).plotrad;
        if ischar(plotrad)                        % plotrad shouldn't be a string
            plotrad = str2num(plotrad)           % just checking
        end
        if plotrad < MINPLOTRAD || plotrad > 1.0
            fprintf('Bad value (%g) for plotrad.\n',plotrad);
            error(' ');
        end
        if strcmpi(VERBOSE,'on') && ~isempty(plotrad)
            fprintf('Plotting radius plotrad (%g) set from EEG.chanlocs.\n',plotrad);
        end
    end
    if isempty(plotrad)
        plotrad = min(1.0,max(Rd)*1.02);            % default: just outside the outermost electrode location
        plotrad = max(plotrad,0.5);                 % default: plot out to the 0.5 head boundary
    end                                           % don't plot channels with Rd > 1 (below head)
    
    if isempty(intrad)
        default_intrad = 1;     % indicator for (no) specified intrad
        intrad = min(1.0,max(Rd)*1.02);             % default: just outside the outermost electrode location
    else
        default_intrad = 0;                         % indicator for (no) specified intrad
        if plotrad > intrad
            plotrad = intrad;
        end
    end                                           % don't interpolate channels with Rd > 1 (below head)
    if ischar(plotrad) || plotrad < MINPLOTRAD || plotrad > 1.0
        error('plotrad must be between 0.15 and 1.0');
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%%%% Set radius of head cartoon %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if isempty(headrad)  % never set -> defaults
        if plotrad >= rmax
            headrad = rmax;  % (anatomically correct)
        else % if plotrad < rmax
            headrad = 0;    % don't plot head
            if strcmpi(VERBOSE, 'on')
                fprintf('topoplot(): not plotting cartoon head since plotrad (%5.4g) < 0.5\n',...
                    plotrad);
            end
        end
    elseif strcmpi(headrad,'rim') % force plotting at rim of map
        headrad = plotrad;
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Shrink mode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if ~isempty(shrinkfactor) || isfield(tmpeloc, 'shrink'),
        if isempty(shrinkfactor) && isfield(tmpeloc, 'shrink'),
            shrinkfactor = tmpeloc(1).shrink;
            if strcmpi(VERBOSE,'on')
                if ischar(shrinkfactor)
                    fprintf('Automatically shrinking coordinates to lie above the head perimter.\n');
                else
                    fprintf('Automatically shrinking coordinates by %3.2f\n', shrinkfactor);
                end
            end
        end
        
        if ischar(shrinkfactor)
            if strcmpi(shrinkfactor, 'on') || strcmpi(shrinkfactor, 'force') || strcmpi(shrinkfactor, 'auto')
                if abs(headrad-rmax) > 1e-2
                    fprintf('     NOTE -> the head cartoon will NOT accurately indicate the actual electrode locations\n');
                end
                if strcmpi(VERBOSE,'on')
                    fprintf('     Shrink flag -> plotting cartoon head at plotrad\n');
                end
                headrad = plotrad; % plot head around outer electrodes, no matter if 0.5 or not
            end
        else % apply shrinkfactor
            plotrad = rmax/(1-shrinkfactor);
            headrad = plotrad;  % make deprecated 'shrink' mode plot
            if strcmpi(VERBOSE,'on')
                fprintf('    %g%% shrink  applied.');
                if abs(headrad-rmax) > 1e-2
                    fprintf(' Warning: With this "shrink" setting, the cartoon head will NOT be anatomically correct.\n');
                else
                    fprintf('\n');
                end
            end
        end
    end; % if shrink
    
    %
    %%%%%%%%%%%%%%%%% Issue warning if headrad ~= rmax  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    
    if headrad ~= 0.5 && strcmpi(VERBOSE, 'on')
        fprintf('     NB: Plotting map using ''plotrad'' %-4.3g,',plotrad);
        fprintf(    ' ''headrad'' %-4.3g\n',headrad);
        fprintf('Warning: The plotting radius of the cartoon head is NOT anatomically correct (0.5).\n')
    end
    %
    %%%%%%%%%%%%%%%%%%%%% Find plotting channels  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    
    pltchans = find(Rd <= plotrad); % plot channels inside plotting circle
    
    if strcmpi(INTSQUARE,'on') % interpolate channels in the radius intrad square
        intchans = find(x <= intrad & y <= intrad); % interpolate and plot channels inside interpolation square
    else
        intchans = find(Rd <= intrad); % interpolate channels in the radius intrad circle only
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%% Eliminate channels not plotted  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    
    allx      = x;
    ally      = y;
    intchans; % interpolate using only the 'intchans' channels
    pltchans; % plot using only indicated 'plotchans' channels
    
    if length(pltchans) < length(Rd) && strcmpi(VERBOSE, 'on')
        fprintf('Interpolating %d and plotting %d of the %d scalp electrodes.\n', ...
            length(intchans),length(pltchans),length(Rd));
    end;
    
    
    % fprintf('topoplot(): plotting %d channels\n',length(pltchans));
    if ~isempty(EMARKER2CHANS)
        if strcmpi(STYLE,'blank')
            error('emarker2 not defined for style ''blank'' - use marking channel numbers in place of data');
        else % mark1chans and mark2chans are subsets of pltchans for markers 1 and 2
            [tmp1, mark1chans, tmp2] = setxor(pltchans,EMARKER2CHANS);
            [tmp3, tmp4, mark2chans] = intersect_bc(EMARKER2CHANS,pltchans);
        end
    end
    
    if ~isempty(Values)
        if length(Values) == length(Th)  % if as many map Values as channel locs
            intValues      = Values(intchans);
            intContourVals = ContourVals(intchans);
            Values         = Values(pltchans);
            ContourVals    = ContourVals(pltchans);
        end;
    end;   % now channel parameters and values all refer to plotting channels only
    
    allchansind = allchansind(pltchans);
    intTh = Th(intchans);           % eliminate channels outside the interpolation area
    intRd = Rd(intchans);
    intx  = x(intchans);
    inty  = y(intchans);
    Th    = Th(pltchans);              % eliminate channels outside the plotting area
    Rd    = Rd(pltchans);
    x     = x(pltchans);
    y     = y(pltchans);
    
    labels= labels(pltchans,:);
    %
    %%%%%%%%%%%%%%% Squeeze channel locations to <= rmax %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    
    squeezefac = rmax/plotrad;
    intRd = intRd*squeezefac; % squeeze electrode arc_lengths towards the vertex
    Rd = Rd*squeezefac;       % squeeze electrode arc_lengths towards the vertex
    % to plot all inside the head cartoon
    intx = intx*squeezefac;
    inty = inty*squeezefac;
    x    = x*squeezefac;
    y    = y*squeezefac;
    allx    = allx*squeezefac;
    ally    = ally*squeezefac;
    % Note: Now outermost channel will be plotted just inside rmax
    
else % if strcmpi(STYLE,'grid')
    intx = rmax; inty=rmax;
end % if ~strcmpi(STYLE,'grid')

%
%%%%%%%%%%%%%%%% rotate channels based on chaninfo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if strcmpi(lower(NOSEDIR), '+x')
    rotate = 0;
else
    if strcmpi(lower(NOSEDIR), '+y')
        rotate = 3*pi/2;
    elseif strcmpi(lower(NOSEDIR), '-x')
        rotate = pi;
    else rotate = pi/2;
    end
    allcoords = (inty + intx*sqrt(-1))*exp(sqrt(-1)*rotate);
    intx = imag(allcoords);
    inty = real(allcoords);
    allcoords = (ally + allx*sqrt(-1))*exp(sqrt(-1)*rotate);
    allx = imag(allcoords);
    ally = real(allcoords);
    allcoords = (y + x*sqrt(-1))*exp(sqrt(-1)*rotate);
    x = imag(allcoords);
    y = real(allcoords);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Make the plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if ~strcmpi(STYLE,'blank') % if draw interpolated scalp map
    if ~strcmpi(STYLE,'grid') %  not a rectangular channel grid
        %
        %%%%%%%%%%%%%%%% Find limits for interpolation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        if default_intrad % if no specified intrad
            if strcmpi(INTERPLIMITS,'head') % intrad is 'head'
                xmin = min(-rmax,min(intx)); xmax = max(rmax,max(intx));
                ymin = min(-rmax,min(inty)); ymax = max(rmax,max(inty));
                
            else % INTERPLIMITS = rectangle containing electrodes -- DEPRECATED OPTION!
                xmin = max(-rmax,min(intx)); xmax = min(rmax,max(intx));
                ymin = max(-rmax,min(inty)); ymax = min(rmax,max(inty));
            end
        else % some other intrad specified
            xmin = -intrad*squeezefac; xmax = intrad*squeezefac;   % use the specified intrad value
            ymin = -intrad*squeezefac; ymax = intrad*squeezefac;
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%% Interpolate scalp map data %%%%%%%%%%%%%%%%%%%%%%%%
        %
        xi = linspace(xmin,xmax,GRID_SCALE);   % x-axis description (row vector)
        yi = linspace(ymin,ymax,GRID_SCALE);   % y-axis description (row vector)
        
        try
            [Xi,Yi,Zi] = griddata(inty,intx,double(intValues),yi',xi,'v4'); % interpolate data
            [Xi,Yi,ZiC] = griddata(inty,intx,double(intContourVals),yi',xi,'v4'); % interpolate data
        catch,
            [Xi,Yi] = meshgrid(yi',xi);
            Zi  = gdatav4(inty,intx,double(intValues), Xi, Yi);
            ZiC = gdatav4(inty,intx,double(intContourVals), Xi, Yi);
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%% Mask out data outside the head %%%%%%%%%%%%%%%%%%%%%
        %
        mask = (sqrt(Xi.^2 + Yi.^2) <= rmax); % mask outside the plotting circle
        ii = find(mask == 0);
        Zi(ii)  = NaN;                         % mask non-plotting voxels with NaNs
        ZiC(ii) = NaN;                         % mask non-plotting voxels with NaNs
        grid = plotrad;                       % unless 'noplot', then 3rd output arg is plotrad
        %
        %%%%%%%%%% Return interpolated value at designated scalp location %%%%%%%%%%
        %
        if exist('chanrad')   % optional first argument to 'noplot'
            chantheta = (chantheta/360)*2*pi;
            chancoords = round(ceil(GRID_SCALE/2)+GRID_SCALE/2*2*chanrad*[cos(-chantheta),...
                -sin(-chantheta)]);
            if chancoords(1)<1 ...
                    || chancoords(1) > GRID_SCALE ...
                    || chancoords(2)<1 ...
                    || chancoords(2)>GRID_SCALE
                error('designated ''noplot'' channel out of bounds')
            else
                chanval = Zi(chancoords(1),chancoords(2));
                grid = Zi;
                Zi = chanval;  % return interpolated value instead of Zi
            end
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%% Return interpolated image only  %%%%%%%%%%%%%%%%%
        %
        if strcmpi(noplot, 'on')
            if strcmpi(VERBOSE,'on')
                fprintf('topoplot(): no plot requested.\n')
            end
            return;
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%% Calculate colormap limits %%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        if ischar(MAPLIMITS)
            if strcmp(MAPLIMITS,'absmax')
                amax = max(max(abs(Zi)));
                amin = -amax;
            elseif strcmp(MAPLIMITS,'maxmin') || strcmp(MAPLIMITS,'minmax')
                amin = min(min(Zi));
                amax = max(max(Zi));
            else
                error('unknown ''maplimits'' value.');
            end
        elseif length(MAPLIMITS) == 2
            amin = MAPLIMITS(1);
            amax = MAPLIMITS(2);
        else
            error('unknown ''maplimits'' value');
        end
        delta = xi(2)-xi(1); % length of grid entry
        
    end % if ~strcmpi(STYLE,'grid')
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%% Scale the axes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %cla  % clear current axis
    hold on
    h = gca; % uses current axes
    
    % instead of default larger AXHEADFAC
    if squeezefac<0.92 && plotrad-headrad > 0.05  % (size of head in axes)
        AXHEADFAC = 1.05;     % do not leave room for external ears if head cartoon
        % shrunk enough by the 'skirt' option
    end
    
    set(gca,'Xlim',[-rmax rmax]*AXHEADFAC,'Ylim',[-rmax rmax]*AXHEADFAC);
    % specify size of head axes in gca
    
    unsh = (GRID_SCALE+1)/GRID_SCALE; % un-shrink the effects of 'interp' SHADING
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%% Plot grid only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if strcmpi(STYLE,'grid')                     % plot grid only
        
        %
        % The goal below is to make the grid cells square - not yet achieved in all cases? -sm
        %
        g1 = size(gridchans,1);
        g2 = size(gridchans,2);
        gmax = max([g1 g2]);
        Xi = linspace(-rmax*g2/gmax,rmax*g2/gmax,g1+1);
        Xi = Xi+rmax/g1; Xi = Xi(1:end-1);
        Yi = linspace(-rmax*g1/gmax,rmax*g1/gmax,g2+1);
        Yi = Yi+rmax/g2; Yi = Yi(1:end-1); Yi = Yi(end:-1:1); % by trial and error!
        %
        %%%%%%%%%%% collect the gridchans values %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        gridvalues = zeros(size(gridchans));
        for j=1:size(gridchans,1)
            for k=1:size(gridchans,2)
                gc = gridchans(j,k);
                if gc > 0
                    gridvalues(j,k) = Values(gc);
                elseif gc < 0
                    gridvalues(j,k) = -Values(abs(gc));
                else
                    gridvalues(j,k) = nan; % not-a-number = no value
                end
            end
        end
        %
        %%%%%%%%%%% reset color limits for grid plot %%%%%%%%%%%%%%%%%%%%%%%%%
        %
        if ischar(MAPLIMITS)
            if strcmp(MAPLIMITS,'maxmin') || strcmp(MAPLIMITS,'minmax')
                amin = min(min(gridvalues(~isnan(gridvalues))));
                amax = max(max(gridvalues(~isnan(gridvalues))));
            elseif strcmp(MAPLIMITS,'absmax')
                % 11/21/2005 Toby edit
                % This should now work as specified. Before it only crashed (using
                % "plotgrid" and "maplimits>absmax" options).
                amax = max(max(abs(gridvalues(~isnan(gridvalues)))));
                amin = -amax;
                %amin = -max(max(abs([amin amax])));
                %amax = max(max(abs([amin amax])));
            else
                error('unknown ''maplimits'' value');
            end
        elseif length(MAPLIMITS) == 2
            amin = MAPLIMITS(1);
            amax = MAPLIMITS(2);
        else
            error('unknown ''maplimits'' value');
        end
        %
        %%%%%%%%%% explicitly compute grid colors, allowing BACKCOLOR  %%%%%%
        %
        gridvalues = 1+floor(cmaplen*(gridvalues-amin)/(amax-amin));
        gridvalues(find(gridvalues == cmaplen+1)) = cmaplen;
        gridcolors = zeros([size(gridvalues),3]);
        for j=1:size(gridchans,1)
            for k=1:size(gridchans,2)
                if ~isnan(gridvalues(j,k))
                    gridcolors(j,k,:) = cmap(gridvalues(j,k),:);
                else
                    if strcmpi(whitebk,'off')
                        gridcolors(j,k,:) = BACKCOLOR; % gridchans == 0 -> background color
                        % This allows the plot to show 'space' between separate sub-grids or strips
                    else % 'on'
                        gridcolors(j,k,:) = [1 1 1]; BACKCOLOR; % gridchans == 0 -> white for printing
                    end
                end
            end
        end
        
        %
        %%%%%%%%%% draw the gridplot image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        handle=imagesc(Xi,Yi,gridcolors); % plot grid with explicit colors
        axis square
        %
        %%%%%%%%%%%%%%%%%%%%%%%% Plot map contours only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(STYLE,'contour')                     % plot surface contours only
        [cls chs] = contour(Xi,Yi,ZiC,CONTOURNUM,'k');
        handle = chs;                                   % handle to a contourgroup object
        % for h=chs, set(h,'color',CCOLOR); end
        %
        %%%%%%%%%%%%%%%%%%%%%%%% Else plot map and contours %%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(STYLE,'both')  % plot interpolated surface and surface contours
        if strcmp(SHADING,'interp')
            tmph = surface(Xi*unsh,Yi*unsh,zeros(size(Zi))-0.1,Zi,...
                'EdgeColor','none','FaceColor',SHADING);
        else % SHADING == 'flat'
            tmph = surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi))-0.1,Zi,...
                'EdgeColor','none','FaceColor',SHADING);
        end
        if strcmpi(MASKSURF, 'on')
            set(tmph, 'visible', 'off');
            handle = tmph;
        end
        
        warning off;
        if ~PMASKFLAG
            [cls chs] = contour(Xi,Yi,ZiC,CONTOURNUM,'k');
        else
            ZiC(find(ZiC > 0.5 )) = NaN;
            [cls chs] = contourf(Xi,Yi,ZiC,0,'k');
            subh = get(chs, 'children');
            for indsubh = 1:length(subh)
                numfaces = size(get(subh(indsubh), 'XData'),1);
                set(subh(indsubh), 'FaceVertexCData', ones(numfaces,3), 'Cdatamapping', 'direct', 'facealpha', 0.5, 'linewidth', 2);
            end
        end
        handle = tmph;                                   % surface handle
        try, for h=chs, set(h,'color',CCOLOR); end, catch, end % the try clause is for Octave
        warning on;
        %
        %%%%%%%%%%%%%%%%%%%%%%%% Else plot map only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(STYLE,'straight') || strcmp(STYLE,'map') % 'straight' was former arg
        
        if strcmp(SHADING,'interp') % 'interp' mode is shifted somehow... but how?
            tmph = surface(Xi*unsh,Yi*unsh,zeros(size(Zi)),Zi,'EdgeColor','none',...
                'FaceColor',SHADING);
        else
            tmph = surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi)),Zi,'EdgeColor','none',...
                'FaceColor',SHADING);
        end
        if strcmpi(MASKSURF, 'on')
            set(tmph, 'visible', 'off');
            handle = tmph;
        end
        handle = tmph;                                   % surface handle
        %
        %%%%%%%%%%%%%%%%%% Else fill contours with uniform colors  %%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(STYLE,'fill')
        [cls chs] = contourf(Xi,Yi,Zi,CONTOURNUM,'k');
        
        handle = chs;                                   % handle to a contourgroup object
        
        % for h=chs, set(h,'color',CCOLOR); end
        %     <- 'not line objects.' Why does 'both' work above???
        
    else
        error('Invalid style')
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set color axis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   caxis([amin amax]); % set coloraxis
    
    % 7/30/2014 Ramon: +-5% for the color limits were added
    cax_sgn = sign([amin amax]);                                                  % getting sign
    caxis([amin+cax_sgn(1)*(0.05*abs(amin)) amax+cax_sgn(2)*(0.05*abs(amax))]);   % Adding 5% to the color limits
    
else % if STYLE 'blank'
    %
    %%%%%%%%%%%%%%%%%%%%%%% Draw blank head %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if strcmpi(noplot, 'on')
        if strcmpi(VERBOSE,'on')
            fprintf('topoplot(): no plot requested.\n')
        end
        return;
    end
    %cla
    hold on
    
    set(gca,'Xlim',[-rmax rmax]*AXHEADFAC,'Ylim',[-rmax rmax]*AXHEADFAC)
    % pos = get(gca,'position');
    % fprintf('Current axes size %g,%g\n',pos(3),pos(4));
    
    if strcmp(ELECTRODES,'labelpoint') ||  strcmp(ELECTRODES,'numpoint')
        text(-0.6,-0.6, ...
            [ int2str(length(Rd)) ' of ' int2str(length(tmpeloc)) ' electrode locations shown']);
        text(-0.6,-0.7, [ 'Click on electrodes to toggle name/number']);
        tl = title('Channel locations');
        set(tl, 'fontweight', 'bold');
    end
end % STYLE 'blank'

if exist('handle') ~= 1
    handle = gca;
end

if ~strcmpi(STYLE,'grid')                     % if not plot grid only
    
    %
    %%%%%%%%%%%%%%%%%%% Plot filled ring to mask jagged grid boundary %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    hwidth = HEADRINGWIDTH;                   % width of head ring
    hin  = squeezefac*headrad*(1- hwidth/2);  % inner head ring radius
    
    if strcmp(SHADING,'interp')
        rwidth = BLANKINGRINGWIDTH*1.3;             % width of blanking outer ring
    else
        rwidth = BLANKINGRINGWIDTH;         % width of blanking outer ring
    end
    rin    =  rmax*(1-rwidth/2);              % inner ring radius
    if hin>rin
        rin = hin;                              % dont blank inside the head ring
    end
    
    if strcmp(CONVHULL,'on') %%%%%%%%% mask outside the convex hull of the electrodes %%%%%%%%%
        cnv = convhull(allx,ally);
        cnvfac = round(CIRCGRID/length(cnv)); % spline interpolate the convex hull
        if cnvfac < 1, cnvfac=1; end
        CIRCGRID = cnvfac*length(cnv);
        
        startangle = atan2(allx(cnv(1)),ally(cnv(1)));
        circ = linspace(0+startangle,2*pi+startangle,CIRCGRID);
        rx = sin(circ);
        ry = cos(circ);
        
        allx = allx(:)';  % make x (elec locations; + to nose) a row vector
        ally = ally(:)';  % make y (elec locations, + to r? ear) a row vector
        erad = sqrt(allx(cnv).^2+ally(cnv).^2);  % convert to polar coordinates
        eang = atan2(allx(cnv),ally(cnv));
        eang = unwrap(eang);
        eradi =spline(linspace(0,1,3*length(cnv)), [erad erad erad], ...
            linspace(0,1,3*length(cnv)*cnvfac));
        eangi =spline(linspace(0,1,3*length(cnv)), [eang+2*pi eang eang-2*pi], ...
            linspace(0,1,3*length(cnv)*cnvfac));
        xx = eradi.*sin(eangi);           % convert back to rect coordinates
        yy = eradi.*cos(eangi);
        yy = yy(CIRCGRID+1:2*CIRCGRID);
        xx = xx(CIRCGRID+1:2*CIRCGRID);
        eangi = eangi(CIRCGRID+1:2*CIRCGRID);
        eradi = eradi(CIRCGRID+1:2*CIRCGRID);
        xx = xx*1.02; yy = yy*1.02;           % extend spline outside electrode marks
        
        splrad = sqrt(xx.^2+yy.^2);           % arc radius of spline points (yy,xx)
        oob = find(splrad >= rin);            %  enforce an upper bound on xx,yy
        xx(oob) = rin*xx(oob)./splrad(oob);   % max radius = rin
        yy(oob) = rin*yy(oob)./splrad(oob);   % max radius = rin
        
        splrad = sqrt(xx.^2+yy.^2);           % arc radius of spline points (yy,xx)
        oob = find(splrad < hin);             % don't let splrad be inside the head cartoon
        xx(oob) = hin*xx(oob)./splrad(oob);   % min radius = hin
        yy(oob) = hin*yy(oob)./splrad(oob);   % min radius = hin
        
        ringy = [[ry(:)' ry(1) ]*(rin+rwidth) yy yy(1)];
        ringx = [[rx(:)' rx(1) ]*(rin+rwidth) xx xx(1)];
        
        ringh2= patch(ringy,ringx,ones(size(ringy)),BACKCOLOR,'edgecolor','none'); hold on
        
        % plot(ry*rmax,rx*rmax,'b') % debugging line
        
    else %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mask the jagged border around rmax %%%%%%%%%%%%%%%5%%%%%%
        
        circ = linspace(0,2*pi,CIRCGRID);
        rx = sin(circ);
        ry = cos(circ);
        ringx = [[rx(:)' rx(1) ]*(rin+rwidth)  [rx(:)' rx(1)]*rin];
        ringy = [[ry(:)' ry(1) ]*(rin+rwidth)  [ry(:)' ry(1)]*rin];
        
        if ~strcmpi(STYLE,'blank')
            ringh= patch(ringx,ringy,0.01*ones(size(ringx)),BACKCOLOR,'edgecolor','none'); hold on
        end
        % plot(ry*rmax,rx*rmax,'b') % debugging line
    end
    
    %f1= fill(rin*[rx rX],rin*[ry rY],BACKCOLOR,'edgecolor',BACKCOLOR); hold on
    %f2= fill(rin*[rx rX*(1+rwidth)],rin*[ry rY*(1+rwidth)],BACKCOLOR,'edgecolor',BACKCOLOR);
    
    % Former line-style border smoothing - width did not scale with plot
    %  brdr=plot(1.015*cos(circ).*rmax,1.015*sin(circ).*rmax,...      % old line-based method
    %      'color',HEADCOLOR,'Linestyle','-','LineWidth',HLINEWIDTH);    % plot skirt outline
    %  set(brdr,'color',BACKCOLOR,'linewidth',HLINEWIDTH + 4);        % hide the disk edge jaggies
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%% Plot cartoon head, ears, nose %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if headrad > 0                         % if cartoon head to be plotted
        %
        %%%%%%%%%%%%%%%%%%% Plot head outline %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        headx = [[rx(:)' rx(1) ]*(hin+hwidth)  [rx(:)' rx(1)]*hin];
        heady = [[ry(:)' ry(1) ]*(hin+hwidth)  [ry(:)' ry(1)]*hin];
        
        if ~ischar(HEADCOLOR) || ~strcmpi(HEADCOLOR,'none')
            %ringh= patch(headx,heady,ones(size(headx)),HEADCOLOR,'edgecolor',HEADCOLOR,'linewidth', HLINEWIDTH); hold on
            headx = [rx(:)' rx(1)]*hin;
            heady = [ry(:)' ry(1)]*hin;
            ringh= plot(headx,heady);
            set(ringh, 'color',HEADCOLOR,'linewidth', HLINEWIDTH); hold on
        end
        
        % rx = sin(circ); rX = rx(end:-1:1);
        % ry = cos(circ); rY = ry(end:-1:1);
        % for k=2:2:CIRCGRID
        %   rx(k) = rx(k)*(1+hwidth);
        %   ry(k) = ry(k)*(1+hwidth);
        % end
        % f3= fill(hin*[rx rX],hin*[ry rY],HEADCOLOR,'edgecolor',HEADCOLOR); hold on
        % f4= fill(hin*[rx rX*(1+hwidth)],hin*[ry rY*(1+hwidth)],HEADCOLOR,'edgecolor',HEADCOLOR);
        
        % Former line-style head
        %  plot(cos(circ).*squeezefac*headrad,sin(circ).*squeezefac*headrad,...
        %      'color',HEADCOLOR,'Linestyle','-','LineWidth',HLINEWIDTH);    % plot head outline
        
        %
        %%%%%%%%%%%%%%%%%%% Plot ears and nose %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        base  = rmax-.0046;
        basex = 0.18*rmax;                   % nose width
        tip   = 1.15*rmax;
        tiphw = .04*rmax;                    % nose tip half width
        tipr  = .01*rmax;                    % nose tip rounding
        q = .04; % ear lengthening
        EarX  = [.497-.005  .510  .518  .5299 .5419  .54    .547   .532   .510   .489-.005]; % rmax = 0.5
        EarY  = [q+.0555 q+.0775 q+.0783 q+.0746 q+.0555 -.0055 -.0932 -.1313 -.1384 -.1199];
        sf    = headrad/plotrad;                                          % squeeze the model ears and nose
        % by this factor
        if ~ischar(HEADCOLOR) || ~strcmpi(HEADCOLOR,'none')
            plot3([basex;tiphw;0;-tiphw;-basex]*sf,[base;tip-tipr;tip;tip-tipr;base]*sf,...
                2*ones(size([basex;tiphw;0;-tiphw;-basex])),...
                'Color',HEADCOLOR,'LineWidth',HLINEWIDTH);                 % plot nose
            plot3(EarX*sf,EarY*sf,2*ones(size(EarX)),'color',HEADCOLOR,'LineWidth',HLINEWIDTH)    % plot left ear
            plot3(-EarX*sf,EarY*sf,2*ones(size(EarY)),'color',HEADCOLOR,'LineWidth',HLINEWIDTH)   % plot right ear
        end
    end
    
    %
    % %%%%%%%%%%%%%%%%%%% Show electrode information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    plotax = gca;
    axis square                                           % make plotax square
    axis off
    
    pos = get(gca,'position');
    xlm = get(gca,'xlim');
    ylm = get(gca,'ylim');
    % textax = axes('position',pos,'xlim',xlm,'ylim',ylm);  % make new axes so clicking numbers <-> labels
    % will work inside head cartoon patch
    % axes(textax);
    axis square                                           % make textax square
    
    pos = get(gca,'position');
    set(plotax,'position',pos);
    
    xlm = get(gca,'xlim');
    set(plotax,'xlim',xlm);
    
    ylm = get(gca,'ylim');
    set(plotax,'ylim',ylm);                               % copy position and axis limits again
    
    axis equal;
    lim = [-0.525 0.525];
    %lim = [-0.56 0.56];
    set(gca, 'xlim', lim); set(plotax, 'xlim', lim);
    set(gca, 'ylim', lim); set(plotax, 'ylim', lim);
    set(gca, 'xlim', lim); set(plotax, 'xlim', lim);
    set(gca, 'ylim', lim); set(plotax, 'ylim', lim);
    
    %get(textax,'pos')    % test if equal!
    %get(plotax,'pos')
    %get(textax,'xlim')
    %get(plotax,'xlim')
    %get(textax,'ylim')
    %get(plotax,'ylim')
    
    if isempty(EMARKERSIZE)
        EMARKERSIZE = 10;
        if length(y)>=160
            EMARKERSIZE = 3;
        elseif length(y)>=128
            EMARKERSIZE = 3;
        elseif length(y)>=100
            EMARKERSIZE = 3;
        elseif length(y)>=80
            EMARKERSIZE = 4;
        elseif length(y)>=64
            EMARKERSIZE = 5;
        elseif length(y)>=48
            EMARKERSIZE = 6;
        elseif length(y)>=32
            EMARKERSIZE = 8;
        end
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%% Mark electrode locations only %%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    ELECTRODE_HEIGHT = 2.1;  % z value for plotting electrode information (above the surf)
    
    if strcmp(ELECTRODES,'on')   % plot electrodes as spots
        if isempty(EMARKER2CHANS)
            hp2 = plot3(y,x,ones(size(x))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
        else % plot markers for normal chans and EMARKER2CHANS separately
            hp2 = plot3(y(mark1chans),x(mark1chans),ones(size((mark1chans)))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
            hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
                EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%%% Print electrode labels only %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(ELECTRODES,'labels')  % print electrode names (labels)
        for i = 1:size(labels,1)
            % % % % % % % %     text(double(y(i)),double(x(i)),...
            % % % % % % % %         ELECTRODE_HEIGHT,labels(i,:),'HorizontalAlignment','center',...
            % % % % % % % % 	'VerticalAlignment','middle','Color',ECOLOR,...
            % % % % % % % % 	'FontSize',EFSIZE)
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%%% Mark electrode locations plus labels %%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(ELECTRODES,'labelpoint')
        if isempty(EMARKER2CHANS)
            hp2 = plot3(y,x,ones(size(x))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
        else
            hp2 = plot3(y(mark1chans),x(mark1chans),ones(size((mark1chans)))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
            hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
                EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
        end
        for i = 1:size(labels,1)
            hh(i) = text(double(y(i)+0.01),double(x(i)),...
                ELECTRODE_HEIGHT,labels(i,:),'HorizontalAlignment','left',...
                'VerticalAlignment','middle','Color', ECOLOR,'userdata', num2str(allchansind(i)), ...
                'FontSize',EFSIZE, 'buttondownfcn', ...
                ['tmpstr = get(gco, ''userdata'');'...
                'set(gco, ''userdata'', get(gco, ''string''));' ...
                'set(gco, ''string'', tmpstr); clear tmpstr;'] );
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%% Mark electrode locations plus numbers %%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(ELECTRODES,'numpoint')
        if isempty(EMARKER2CHANS)
            hp2 = plot3(y,x,ones(size(x))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
        else
            hp2 = plot3(y(mark1chans),x(mark1chans),ones(size((mark1chans)))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
            hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
                EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
        end
        for i = 1:size(labels,1)
            hh(i) = text(double(y(i)+0.01),double(x(i)),...
                ELECTRODE_HEIGHT,num2str(allchansind(i)),'HorizontalAlignment','left',...
                'VerticalAlignment','middle','Color', ECOLOR,'userdata', labels(i,:) , ...
                'FontSize',EFSIZE, 'buttondownfcn', ...
                ['tmpstr = get(gco, ''userdata'');'...
                'set(gco, ''userdata'', get(gco, ''string''));' ...
                'set(gco, ''string'', tmpstr); clear tmpstr;'] );
        end
        %
        %%%%%%%%%%%%%%%%%%%%%% Print electrode numbers only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(ELECTRODES,'numbers')
        for i = 1:size(labels,1)
            text(double(y(i)),double(x(i)),...
                ELECTRODE_HEIGHT,int2str(allchansind(i)),'HorizontalAlignment','center',...
                'VerticalAlignment','middle','Color',ECOLOR,...
                'FontSize',EFSIZE)
        end
        %
        %%%%%%%%%%%%%%%%%%%%%% Mark emarker2 electrodes only  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(ELECTRODES,'off') && ~isempty(EMARKER2CHANS)
        hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
            EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
    end
    %
    %%%%%%%% Mark specified electrode locations with red filled disks  %%%%%%%%%%%%%%%%%%%%%%
    %
    %try,
    if strcmpi(STYLE,'blank') % if mark-selected-channel-locations mode
        for kk = 1:length(1:length(x))
            if abs(Values(kk))
                if strcmpi(PLOTDISK, 'off')
                    hh(kk) = text(double(y(kk)+0.01),double(x(kk)),...
                        ELECTRODE_HEIGHT,labels(kk,:),'HorizontalAlignment','left',...
                        'VerticalAlignment','middle','Color', [0,0,1],'EdgeColor',[0,0,0],'userdata', strcat(num2str(allchansind(kk)),':','1') , ...
                        'FontSize',14, 'buttondownfcn', ...
                        ['TempA = get(gco,''color'');'...
                        'if any(diff([TempA;[0,0,1]],1,1))==0;'...
                        'set(gco, ''Color'', [1,0,0]);'...
                        'set(gco, ''EdgeColor'', ''none'');'...
                        'TempB = get(gco,''userdata'');'...
                        'COI_Find_Colon1 =  strfind(TempB,'':'');'...
                        'TempB = convertStringsToChars(TempB);'...
                        'Chan = TempB(1:(COI_Find_Colon1-1));'...
                        'Chan =str2double(Chan);'...
                        'OnOff = 0;'...
                        'set(gco,''userdata'', strcat(string(Chan),'':'',string(OnOff)));'...
                        'elseif any(diff([TempA;[1,0,0]],1,1))==0;'...
                        'set(gco, ''Color'', [0,0,1]);'...
                        'set(gco, ''EdgeColor'', [0,0,0]);'...
                        'TempB = get(gco,''userdata'');'...
                        'COI_Find_Colon1 =  strfind(TempB,'':'');'...
                        'TempB = convertStringsToChars(TempB);'...
                        'Chan = TempB(1:(COI_Find_Colon1-1));'...
                        'Chan =str2double(Chan);'...
                        'OnOff = 1;'...
                        'set(gco,''userdata'', strcat(string(Chan),'':'',string(OnOff)));'...
                        'end']);
                end
            else
                hh(kk) = text(double(y(kk)+0.01),double(x(kk)),...
                    ELECTRODE_HEIGHT,labels(kk,:),'HorizontalAlignment','left',...
                    'VerticalAlignment','middle','Color', [1,0,0],'EdgeColor','none','userdata', strcat(num2str(allchansind(kk)),':','1') , ...
                    'FontSize',14, 'buttondownfcn', ...
                    ['TempA = get(gco,''color'');'...
                    'if any(diff([TempA;[0,0,1]],1,1))==0;'...
                    'set(gco, ''Color'', [1,0,0]);'...
                    'set(gco, ''EdgeColor'', ''none'');'...
                    'TempB = get(gco,''userdata'');'...
                    'COI_Find_Colon1 =  strfind(TempB,'':'');'...
                    'TempB = convertStringsToChars(TempB);'...
                    'Chan = TempB(1:(COI_Find_Colon1-1));'...
                    'Chan =str2double(Chan);'...
                    'OnOff = 0;'...
                    'set(gco,''userdata'', strcat(string(Chan),'':'',string(OnOff)));'...
                    'elseif any(diff([TempA;[1,0,0]],1,1))==0;'...
                    'set(gco, ''Color'', [0,0,1]);'...
                    'set(gco, ''EdgeColor'', [0,0,0]);'...
                    'TempB = get(gco,''userdata'');'...
                    'COI_Find_Colon1 =  strfind(TempB,'':'');'...
                    'TempB = convertStringsToChars(TempB);'...
                    'Chan = TempB(1:(COI_Find_Colon1-1));'...
                    'Chan =str2double(Chan);'...
                    'OnOff = 1;'...
                    'set(gco,''userdata'', strcat(string(Chan),'':'',string(OnOff)));'...
                    'end']);
                
                %                 angleRatio = real(Values(kk))/(real(Values(kk))+imag(Values(kk)))*360;
                %                 radius     = real(Values(kk))+imag(Values(kk));
                %                 allradius  = [0.02 0.03 0.037 0.044 0.05];
                %                 radius     = allradius(radius);
                %                 hp2 = disk(y(kk),x(kk),radius, [1 0 0], 0 , angleRatio, 16);
                %                 %                     W = findall(gcf,'Type','Patch');
                %                 %                     WW = get(gcf,'Position');
            end
        end
    end
    % catch
    %end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Plot dipole(s) on the scalp map  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if ~isempty(DIPOLE)
        hold on;
        tmp = DIPOLE;
        if isstruct(DIPOLE)
            if ~isfield(tmp,'posxyz')
                error('dipole structure is not an EEG.dipfit.model')
            end
            DIPOLE = [];  % Note: invert x and y from dipplot usage
            DIPOLE(:,1) = -tmp.posxyz(:,2)/DIPSPHERE; % -y -> x
            DIPOLE(:,2) =  tmp.posxyz(:,1)/DIPSPHERE; %  x -> y
            DIPOLE(:,3) = -tmp.momxyz(:,2);
            DIPOLE(:,4) =  tmp.momxyz(:,1);
            DIPOLE(:,5) =  tmp.momxyz(:,3);
        else
            DIPOLE(:,1) = -tmp(:,2);                    % same for vector input
            DIPOLE(:,2) =  tmp(:,1);
            DIPOLE(:,3) = -tmp(:,4);
            DIPOLE(:,4) =  tmp(:,3);
        end
        for index = 1:size(DIPOLE,1)
            if ~any(DIPOLE(index,:))
                DIPOLE(index,:) = [];
            end
        end
        DIPOLE(:,1:4)   = DIPOLE(:,1:4)*rmax*(rmax/plotrad); % scale radius from 1 -> rmax (0.5)
        DIPOLE(:,3:end) = (DIPOLE(:,3:end))*rmax/100000*(rmax/plotrad);
        if strcmpi(DIPNORM, 'on')
            for index = 1:size(DIPOLE,1)
                DIPOLE(index,3:4) = DIPOLE(index,3:4)/norm(DIPOLE(index,3:end))*0.2;
            end
        elseif strcmpi(DIPNORMMAX, 'on')
            for inorm =  1: size(DIPOLE,1)
                normtmp(inorm) = norm(DIPOLE(inorm,3:5)); % Max norm of projection on XY
            end
            [maxnorm,maxnormindx] = max(normtmp);
            for index = 1:size(DIPOLE,1)
                DIPOLE(index,3:4) = DIPOLE(index,3:4)/norm(DIPOLE(index,3:4))*0.2*normtmp(index)/normtmp(maxnormindx);
            end;
        end
        DIPOLE(:, 3:4) =  DIPORIENT*DIPOLE(:, 3:4)*DIPLEN;
        
        PLOT_DIPOLE=1;
        if sum(DIPOLE(1,3:4).^2) <= 0.00001
            if strcmpi(VERBOSE,'on')
                fprintf('Note: dipole is length 0 - not plotted\n')
            end
            PLOT_DIPOLE = 0;
        end
        if 0 % sum(DIPOLE(1,1:2).^2) > plotrad
            if strcmpi(VERBOSE,'on')
                fprintf('Note: dipole is outside plotting area - not plotted\n')
            end
            PLOT_DIPOLE = 0;
        end
        if PLOT_DIPOLE
            for index = 1:size(DIPOLE,1)
                hh = plot( DIPOLE(index, 1), DIPOLE(index, 2), '.');
                set(hh, 'color', DIPCOLOR, 'markersize', DIPSCALE*30);
                hh = line( [DIPOLE(index, 1) DIPOLE(index, 1)+DIPOLE(index, 3)]', ...
                    [DIPOLE(index, 2) DIPOLE(index, 2)+DIPOLE(index, 4)]',[10 10]);
                set(hh, 'color', DIPCOLOR, 'linewidth', DIPSCALE*30/7);
            end
        end
    end
    
end % if ~ 'gridplot'

%
%%%%%%%%%%%%% Plot axis orientation %%%%%%%%%%%%%%%%%%%%
%
if strcmpi(DRAWAXIS, 'on')
    axes('position', [0 0.85 0.08 0.1]);
    axis off;
    coordend1 = sqrt(-1)*3;
    coordend2 = -3;
    coordend1 = coordend1*exp(sqrt(-1)*rotate);
    coordend2 = coordend2*exp(sqrt(-1)*rotate);
    
    line([5 5+round(real(coordend1))]', [5 5+round(imag(coordend1))]', 'color', 'k');
    line([5 5+round(real(coordend2))]', [5 5+round(imag(coordend2))]', 'color', 'k');
    if round(real(coordend2))<0
        text( 5+round(real(coordend2))*1.2, 5+round(imag(coordend2))*1.2-2, '+Y');
    else text( 5+round(real(coordend2))*1.2, 5+round(imag(coordend2))*1.2, '+Y');
    end
    if round(real(coordend1))<0
        text( 5+round(real(coordend1))*1.2, 5+round(imag(coordend1))*1.2+1.5, '+X');
    else text( 5+round(real(coordend1))*1.2, 5+round(imag(coordend1))*1.2, '+X');
    end
    set(gca, 'xlim', [0 10], 'ylim', [0 10]);
end

%
%%%%%%%%%%%%% Set EEGLAB background color to match head border %%%%%%%%%%%%%%%%%%%%%%%%
%
try,
    set(gcf, 'color', BACKCOLOR);
catch,
end;

hold off
axis off
return
function vq = gdatav4(x,y,v,xq,yq)
%GDATAV4 MATLAB 4 GRIDDATA interpolation

%   Reference:  David T. Sandwell, Biharmonic spline
%   interpolation of GEOS-3 and SEASAT altimeter
%   data, Geophysical Research Letters, 2, 139-142,
%   1987.  Describes interpolation using value or
%   gradient of value in any dimension.

xy = x(:) + 1i*y(:);

% Determine distances between points
d = abs(xy - xy.');

% Determine weights for interpolation
g = (d.^2) .* (log(d)-1);   % Green's function.
% Fixup value of Green's function along diagonal
g(1:size(d,1)+1:end) = 0;
weights = g \ v(:);

[m,n] = size(xq);
vq = zeros(size(xq));
xy = xy.';

% Evaluate at requested points (xq,yq).  Loop to save memory.
for i=1:m
    for j=1:n
        d = abs(xq(i,j) + 1i*yq(i,j) - xy);
        g = (d.^2) .* (log(d)-1);   % Green's function.
        % Value of Green's function at zero
        g(d==0) = 0;
        vq(i,j) = g * weights;
    end
end
function h2 = disk(X, Y, radius, colorfill, oriangle, endangle, segments)
A = linspace(oriangle/180*pi, endangle/180*pi, segments-1);
if endangle-oriangle == 360
    A  = linspace(oriangle/180*pi, endangle/180*pi, segments);
    h2 = patch( [X   + cos(A)*radius(1)], [Y   + sin(A)*radius(end)], zeros(1,segments)+3, colorfill);
    % %         ZZ = get(gcf);
    %          [nrows,ncols] = size(get(gcf));
    %          xdata = get(gcf,'XData');
    %          ydata = get(gcf,'YData');
    %          px = axes2pix(ncols,X,30);
    %          py = axes2pix(nrows,Y,30);
    %
    %          h2 = uicontrol('style','checkbox','units','pixels', 'position',[10,30,50,15],'string','yes');
    %
    %
else A  = linspace(oriangle/180*pi, endangle/180*pi, segments-1);
    h2 = patch( [X X + cos(A)*radius(1)], [Y Y + sin(A)*radius(end)], zeros(1,segments)+3, colorfill);
end
set(h2, 'FaceColor', colorfill);
set(h2, 'EdgeColor', 'none');
function [result, userdat, strhalt, resstruct, instruct] = inputguiMG(EEG,index_of_Channels, varargin)

if nargin < 2
    help inputgui;
    return;
end

% decoding input and backward compatibility
% -----------------------------------------
if ischar(varargin{1})
    options = varargin;
else
    options = { 'geometry' 'uilist' 'helpcom' 'title' 'userdata' 'mode' 'geomvert' };
    options = { options{1:length(varargin)}; varargin{:} };
    options = options(:)';
end

% checking inputs
% ---------------
g = finputcheck(options, { 'geom'     'cell'                []      {}; ...
    'geometry' {'cell','integer'}    []      []; ...
    'uilist'   'cell'                []      {}; ...
    'helpcom'  { 'string','cell' }   { [] [] }      ''; ...
    'title'    'string'              []      ''; ...
    'eval'     'string'              []      ''; ...
    'helpbut'  'string'              []      'Help'; ...
    'skipline' 'string'              { 'on' 'off' } 'on'; ...
    'addbuttons' 'string'            { 'on' 'off' } 'on'; ...
    'userdata' ''                    []      []; ...
    'getresult' 'real'               []      []; ...
    'minwidth'  'real'               []      200; ...
    'screenpos' ''                   []      []; ...
    'mode'     ''                    []      'normal'; ...
    'geomvert' 'real'                []       [] ...
    }, 'inputgui');
if ischar(g), error(g); end

if isempty(g.getresult)
    if ischar(g.mode)
        fig = figure('visible', 'off');
        set(fig, 'name', g.title);
        set(fig, 'userdata', g.userdata);
        if ~iscell( g.geometry )
            oldgeom = g.geometry;
            g.geometry = {};
            for row = 1:length(oldgeom)
                g.geometry = { g.geometry{:} ones(1, oldgeom(row)) };
            end
        end
        
        % skip a line
        if strcmpi(g.skipline, 'on')
            g.geometry = { g.geometry{:} [1] };
            if ~isempty(g.geom)
                for ind = 1:length(g.geom)
                    g.geom{ind}{2} = g.geom{ind}{2}+1; % add one row
                end
                g.geom = { g.geom{:} {1 g.geom{1}{2} [0 g.geom{1}{2}-2] [1 1] } };
            end
            g.uilist   = { g.uilist{:}, {} };
        end
        
        % add buttons
        if strcmpi(g.addbuttons, 'on')
            g.geometry = { g.geometry{:} [1 1 1 1] };
            if ~isempty(g.geom)
                for ind = 1:length(g.geom)
                    g.geom{ind}{2} = g.geom{ind}{2}+1; % add one row
                end
                g.geom = { g.geom{:} ...
                    {4 g.geom{1}{2} [0 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [1 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [2 g.geom{1}{2}-1] [1 1] }, ...
                    {4 g.geom{1}{2} [3 g.geom{1}{2}-1] [1 1] } };
            end
            if ~isempty(g.helpcom)
                if ~iscell(g.helpcom)
                    g.uilist = { g.uilist{:}, { 'width' 80 'align' 'left' 'Style', 'pushbutton', 'string', g.helpbut, 'tag', 'help', 'callback', g.helpcom } {} };
                else
                    g.uilist = { g.uilist{:}, { 'width' 80 'align' 'left' 'Style', 'pushbutton', 'string', 'Help gui', 'callback', g.helpcom{1} } };
                    g.uilist = { g.uilist{:}, { 'width' 80 'align' 'left' 'Style', 'pushbutton', 'string', 'More help', 'callback', g.helpcom{2} } };
                end
            else
                g.uilist = { g.uilist{:}, {} {} };
            end
            g.uilist = { g.uilist{:}, { 'width' 80 'align' 'right' 'Style', 'pushbutton', 'string', 'Cancel', 'tag' 'cancel' 'callback', 'close(gcbf)' } };
            g.uilist = { g.uilist{:}, { 'width' 80 'align' 'right' 'stickto' 'on' 'Style', 'pushbutton', 'tag', 'ok', 'string', 'OK', 'callback', 'set(gcbo, ''userdata'', ''retuninginputui'');' } };
        end
        
        % add the three buttons (CANCEL HELP OK) at the bottom of the GUI
        % ---------------------------------------------------------------
        if ~isempty(g.geom)
            [tmp, tmp2, allobj] = supergui( 'fig', fig, 'minwidth', g.minwidth, 'geom', g.geom, 'uilist', g.uilist, 'screenpos', g.screenpos );
        elseif isempty(g.geomvert)
            [tmp, tmp2, allobj] = supergui( 'fig', fig, 'minwidth', g.minwidth, 'geomhoriz', g.geometry, 'uilist', g.uilist, 'screenpos', g.screenpos );
        else
            if strcmpi(g.skipline, 'on'),  g.geomvert = [g.geomvert(:)' 1]; end
            if strcmpi(g.addbuttons, 'on'),g.geomvert = [g.geomvert(:)' 1]; end
            [tmp, tmp2, allobj] = supergui( 'fig', fig, 'minwidth', g.minwidth, 'geomhoriz', g.geometry, 'uilist', g.uilist, 'screenpos', g.screenpos, 'geomvert', g.geomvert(:)' );
        end
    else
        fig = g.mode;
        set(findobj('parent', fig, 'tag', 'ok'), 'userdata', []);
        allobj = findobj('parent',fig);
        allobj = allobj(end:-1:1);
    end
    % evaluate command before waiting?
    % --------------------------------
    if ~isempty(g.eval), eval(g.eval); end
    instruct = outstruct(allobj); % Getting default values in the GUI.
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%
    pos1 = [0.245 .20 .70 .70];
    subplot('Position',pos1)
    topoplotMG( index_of_Channels, EEG.chanlocs,'chaninfo', EEG.chaninfo, 'electrodes','labels','style', 'blank', 'emarkersize1chan', 2);
    
    %     set(gcf,'color',([0.93,0.96,1]))
    %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%
    
    
    % create figure and wait for return
    % ---------------------------------
    if ischar(g.mode) && (strcmpi(g.mode, 'plot') || strcmpi(g.mode, 'return') )
        if strcmpi(g.mode, 'plot')
            return; % only plot and returns
        end
    else
        waitfor( findobj('parent', fig, 'tag', 'ok'), 'userdata');
    end
else
    fig = g.getresult;
    allobj = findobj('parent',fig);
    allobj = allobj(end:-1:1);
end

result    = {};
userdat   = [];
strhalt   = '';
resstruct = [];


if ~(ishandle(fig)), return; end % Check if figure still exist

% output parameters
% -----------------
strhalt = get(findobj('parent', fig, 'tag', 'ok'), 'userdata');
[resstruct,result] = outstruct(allobj); % Output parameters
userdat = get(fig, 'userdata');

if isempty(g.getresult) && ischar(g.mode) && ( strcmp(g.mode, 'normal') || strcmp(g.mode, 'return') )
    close(fig);
end
drawnow; % for windows
function [resstructout, resultout] = outstruct(allobj)
counter   = 1;
resultout    = {};
resstructout = [];

for index=1:length(allobj)
    if iscell(allobj), currentobj = allobj{index};
    else               currentobj = allobj(index);
    end
    if isnumeric(currentobj) || ~isprop(currentobj,'GetPropertySpecification') % To allow new object handles
        try
            objstyle = get(currentobj, 'style');
            switch lower( objstyle )
                case { 'listbox', 'checkbox', 'radiobutton' 'popupmenu' 'radio' }
                    resultout{counter} = get( currentobj, 'value');
                    if ~isempty(get(currentobj, 'tag')),
                        try
                            resstructout = setfield(resstructout, get(currentobj, 'tag'), resultout{counter});
                        catch
                            fprintf('Warning: tag "%" may not be use as field in output structure', get(currentobj, 'tag'));
                        end
                    end
                    counter = counter+1;
                case 'edit'
                    resultout{counter} = get( currentobj, 'string');
                    if ~isempty(get(currentobj, 'tag')),
                        try
                            resstructout = setfield(resstructout, get(currentobj, 'tag'), resultout{counter});
                        catch
                            fprintf('Warning: tag "%" may not be use as field in output structure', get(currentobj, 'tag'));
                        end
                    end
                    counter = counter+1;
            end
        catch, end
    else
        ps              = currentobj.GetPropertySpecification;
        resultout{counter} = arg_tovals(ps,false);
        count = 1;
        while isfield(resstructout, ['propgrid' int2str(count)])
            count = count + 1;
        end
        resstructout = setfield(resstructout, ['propgrid' int2str(count)], arg_tovals(ps,false));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%


function [EEG, com] = pop_selectMG( EEG, varargin);

com = '';
if nargin < 1
    help pop_select;
    return;
end
if isempty(EEG(1).data)
    disp('Pop_select error: cannot process empty dataset'); return;
end;

if nargin < 2
    geometry = { [1 1 1] [1 1 0.25 0.23 0.51] [1 1 0.25 0.23 0.51] [1 1 0.25 0.23 0.51] ...
        [1 1 0.25 0.23 0.51] [1] [1 1 1]};
    uilist = { ...
        { 'Style', 'text', 'string', 'Select data in:', 'fontweight', 'bold'  }, ...
        { 'Style', 'text', 'string', 'Input desired range', 'fontweight', 'bold'  }, ...
        { 'Style', 'text', 'string', 'on->remove these', 'fontweight', 'bold'  }, ...
        { 'Style', 'text', 'string', 'Time range [min max] (s)', 'fontangle', fastif(length(EEG)>1, 'italic', 'normal') }, ...
        { 'Style', 'edit', 'string', '', 'enable', fastif(length(EEG)>1, 'off', 'on') }, ...
        { }, { 'Style', 'checkbox', 'string', '    ', 'enable', fastif(length(EEG)>1, 'off', 'on') },{ }, ...
        ...
        { 'Style', 'text', 'string', 'Point range (ex: [1 10])', 'fontangle', fastif(length(EEG)>1, 'italic', 'normal') }, ...
        { 'Style', 'edit', 'string', '', 'enable', fastif(length(EEG)>1, 'off', 'on') }, ...
        { }, { 'Style', 'checkbox', 'string', '    ', 'enable', fastif(length(EEG)>1, 'off', 'on') },{ }, ...
        ...
        { 'Style', 'text', 'string', 'Epoch range (ex: 3:2:10)', 'fontangle', fastif(length(EEG)>1, 'italic', 'normal') }, ...
        { 'Style', 'edit', 'string', '', 'enable', fastif(length(EEG)>1, 'off', 'on') }, ...
        { }, { 'Style', 'checkbox', 'string', '    ', 'enable', fastif(length(EEG)>1, 'off', 'on') },{ }, ...
        ...
        { 'Style', 'text', 'string', 'Channel range' }, ...
        { 'Style', 'edit', 'string', '', 'tag', 'chans' }, ...
        { }, { 'Style', 'checkbox', 'string', '    ' }, ...
        { 'style' 'pushbutton' 'string'  '...', 'enable' fastif(isempty(EEG.chanlocs), 'off', 'on') ...
        'callback' 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on''); set(findobj(gcbf, ''tag'', ''chans''), ''string'',tmpval); clear tmp tmpchanlocs tmpval' }, ...
        { }, { }, { 'Style', 'pushbutton', 'string', 'Scroll dataset', 'enable', fastif(length(EEG)>1, 'off', 'on'), 'callback', ...
        'eegplot(EEG.data, ''srate'', EEG.srate, ''winlength'', 5, ''limits'', [EEG.xmin EEG.xmax]*1000, ''position'', [100 300 800 500], ''xgrid'', ''off'', ''eloc_file'', EEG.chanlocs);' } {}};
    results = inputgui( geometry, uilist, 'pophelp(''pop_select'');', 'Select data -- pop_select()' );
    if length(results) == 0, return; end
    
    
    % decode inputs -------------
    args = {};
    if ~isempty( results{1} )
        if ~results{2}, args = { args{:}, 'time', eval( [ '[' results{1} ']' ] ) };
        else            args = { args{:}, 'notime', eval( [ '[' results{1} ']' ] ) }; end
    end
    
    if ~isempty( results{3} )
        if ~results{4}, args = { args{:}, 'point', eval( [ '[' results{3} ']' ] ) };
        else            args = { args{:}, 'nopoint', eval( [ '[' results{3} ']' ] ) }; end
    end
    
    if ~isempty( results{5} )
        if ~results{6}, args = { args{:}, 'trial', eval( [ '[' results{5} ']' ] ) };
        else            args = { args{:}, 'notrial', eval( [ '[' results{5} ']' ] ) }; end
    end
    
    if ~isempty( results{7} )
        [ chaninds chanlist ] = eeg_decodechan(EEG.chanlocs, results{7});
        if isempty(chanlist), chanlist = chaninds; end
        if ~results{8}, args = { args{:}, 'channel'  , chanlist };
        else            args = { args{:}, 'nochannel', chanlist }; end
    end
    
else
    args = varargin;
end

%----------------------------AMICA---------------------------------
if isfield(EEG.etc,'amica') && isfield(EEG.etc.amica,'prob_added')
    for index = 1:2:length(args)
        if strcmpi(args{index}, 'channel')
            args{index+1} = [ args{index+1} EEG.nbchan-(0:2*EEG.etc.amica.num_models-1)];
            
        end
        
        
    end
end
%--------------------------------------------------------------------

% process multiple datasets -------------------------
if length(EEG) > 1
    [ EEG com ] = eeg_eval( 'pop_select', EEG, 'warning', 'on', 'params', args);
    return;
end

if isempty(EEG.chanlocs), chanlist = [1:EEG.nbchan];
else                      chanlocs = EEG.chanlocs; chanlist = { chanlocs.labels };
end
g = finputcheck(args, { 'time'    'real'      []         []; ...
    'notime'  'real'      []         []; ...
    'trial'   'integer'   []         [1:EEG.trials]; ...
    'notrial' 'integer'   []         []; ...
    'point'   'integer'   []         []; ...
    'nopoint' 'integer'   []         []; ...
    'channel'   { 'integer','cell' }  []  chanlist;
    'nochannel' { 'integer','cell' }   []  [];
    'trialcond'   'integer'   []         []; ...
    'notrialcond' 'integer'   []         []; ...
    'sort'        'integer'   []         []; ...
    'sorttrial'   'string'    { 'on','off' } 'on' }, 'pop_select');
if ischar(g), error(g); end
if ~isempty(g.sort)
    if g.sort, g.sorttrial = 'on';
    else       g.sorttrial = 'off';
    end
end
if strcmpi(g.sorttrial, 'on')
    g.trial = sort(setdiff( g.trial, g.notrial ));
    if isempty(g.trial), error('Error: dataset is empty'); end
else
    g.trial(ismember(g.trial,g.notrial)) = [];
    % still warn about & remove duplicate trials (may be removed in the
    % future)
    [p,q] = unique_bc(g.trial);
    if length(p) ~= length(g.trial)
        disp('Warning: trial selection contained duplicated elements, which were removed.');
    end
    g.trial = g.trial(sort(q));
end

if isempty(g.channel) && ~iscell(g.nochannel) && ~iscell(chanlist)
    g.channel = [1:EEG.nbchan];
end

if iscell(g.channel) && ~iscell(g.nochannel) && ~isempty(EEG.chanlocs)
    noChannelAsCell = {};
    for nochanId = 1:length(g.nochannel)
        noChannelAsCell{nochanId} = EEG.chanlocs(g.nochannel(nochanId)).labels;
    end
    g.nochannel =   noChannelAsCell;
end

if strcmpi(g.sorttrial, 'on')
    if iscell(g.channel)
        g.channel = sort(setdiff( lower(g.channel), lower(g.nochannel) ));
    else g.channel = sort(setdiff( g.channel, g.nochannel ));
    end
else
    g.channel(ismember(lower(g.channel),lower(g.nochannel))) = [];
    % still warn about & remove duplicate channels (may be removed in the
    % future)
    [p,q] = unique_bc(g.channel);
    if length(p) ~= length(g.channel)
        disp('Warning: channel selection contained duplicated elements, which were removed.');
    end
    g.channel = g.channel(sort(q));
end

if ~isempty(EEG.chanlocs)
    if strcmpi(g.sorttrial, 'on')
        g.channel = eeg_decodechan(EEG.chanlocs, g.channel);
    else
        % we have to protect the channel order against changes by
        % eeg_decodechan
        if iscell(g.channel)
            % translate channel names into indices
            [inds,names] = eeg_decodechan(EEG.chanlocs, g.channel);
            % and sort the indices back into the original order of channel
            % names
            [tmp,I] = ismember_bc(lower(g.channel),lower(names));
            g.channel = inds(I);
        end
    end
end

if ~isempty(g.time) && (g.time(1) < EEG.xmin*1000) && (g.time(2) > EEG.xmax*1000)
    error('Wrong time range');
end
if min(g.trial) < 1 || max( g.trial ) > EEG.trials
    error('Wrong trial range');
end
if ~isempty(g.channel)
    if min(double(g.channel)) < 1 || max(double(g.channel)) > EEG.nbchan
        error('Wrong channel range');
    end
end

if size(g.point,2) > 2,
    g.point = [g.point(1) g.point(end)];
    disp('Warning: vector format for point range is deprecated');
end
if size(g.nopoint,2) > 2,
    g.nopoint = [g.nopoint(1) g.nopoint(end)];
    disp('Warning: vector format for point range is deprecated');
end
if ~isempty( g.point )
    g.time = zeros(size(g.point));
    for index = 1:length(g.point(:))
        g.time(index) = eeg_point2lat(g.point(index), 1, EEG.srate, [EEG.xmin EEG.xmax]);
    end
    g.notime = [];
end
if ~isempty( g.nopoint )
    g.notime = zeros(size(g.nopoint));
    for index = 1:length(g.nopoint(:))
        g.notime(index) = eeg_point2lat(g.nopoint(index), 1, EEG.srate, [EEG.xmin EEG.xmax]);
    end
    g.time = [];
end
if ~isempty( g.notime )
    if size(g.notime,2) ~= 2
        error('Time/point range must contain 2 columns exactly');
    end
    if g.notime(2) == EEG.xmax
        g.time = [EEG.xmin g.notime(1)];
    else
        if g.notime(1) == EEG.xmin
            g.time = [g.notime(2) EEG.xmax];
        elseif EEG.trials > 1
            error('Wrong notime range. Remember that it is not possible to remove a slice of time for data epochs.');
        end
    end
    if g.notime(end) > EEG.xmax, g.notime(end) = EEG.xmax; end
    if g.notime(1)   < EEG.xmin, g.notime(1)   = EEG.xmin; end
    if floor(max(g.notime(:))) > EEG.xmax
        error('Time/point range exceed upper data limits');
    end
    if min(g.notime(:)) < EEG.xmin
        error('Time/point range exceed lower data limits');
    end
end
if ~isempty(g.time)
    if size(g.time,2) ~= 2
        error('Time/point range must contain 2 columns exactly');
    end
    for index = 1:length(g.time)
        if g.time(index) > EEG.xmax
            g.time(index) = EEG.xmax;
            disp('Upper time limits exceed data, corrected');
        elseif g.time(index) < EEG.xmin
            g.time(index) = EEG.xmin;
            disp('Lower time limits exceed data, corrected');
        end
    end
end

% select trial values
%--------------------
if ~isempty(g.trialcond)
    try, tt = struct( g.trialcond{:} ); catch
        error('Trial conditions format error');
    end
    ttfields = fieldnames (tt);
    for index = 1:length(ttfields)
        if ~isfield( EEG.epoch, ttfields{index} )
            error([ ttfields{index} 'is not a field of EEG.epoch' ]);
        end;
        tmpepoch = EEG.epoch;
        eval( [ 'Itriallow  = find( [ tmpepoch(:).' ttfields{index} ' ] >= tt.' ttfields{index} '(1) );' ] );
        eval( [ 'Itrialhigh = find( [ tmpepoch(:).' ttfields{index} ' ] <= tt.' ttfields{index} '(end) );' ] );
        Itrialtmp = intersect_bc(Itriallow, Itrialhigh);
        g.trial = intersect_bc( g.trial(:)', Itrialtmp(:)');
    end;
end

if isempty(g.trial)
    error('Empty dataset, no trial');
end
if length(g.trial) ~= EEG.trials
    fprintf('Removing %d trial(s)...\n', EEG.trials - length(g.trial));
end
if length(g.channel) ~= EEG.nbchan
    %   fprintf('Removing %d channel(s)...\n', EEG.nbchan -
    %   length(g.channel));
end

try
    % For AMICA probabilities...
    %-----------------------------------------------------
    if isfield(EEG.etc, 'amica') && ~isempty(EEG.etc.amica) && isfield(EEG.etc.amica, 'v_smooth') && ~isempty(EEG.etc.amica.v_smooth) && ~isfield(EEG.etc.amica,'prob_added')
        if isfield(EEG.etc.amica, 'num_models') && ~isempty(EEG.etc.amica.num_models)
            if size(EEG.data,2) == size(EEG.etc.amica.v_smooth,2) && size(EEG.data,3) == size(EEG.etc.amica.v_smooth,3) && size(EEG.etc.amica.v_smooth,1) == EEG.etc.amica.num_models
                
                EEG = eeg_formatamica(EEG);
                
                %-------------------------------------------
                
                [EEG com] = pop_select(EEG,args{:});
                
                %-------------------------------------------
                
                EEG = eeg_reformatamica(EEG);
                EEG = eeg_checkamica(EEG);
                return;
            else
                disp('AMICA probabilities not compatible with size of data, probabilities cannot be rejected')
                
                disp('Resuming rejection...')
            end
        end
        
    end
    % ------------------------------------------------------
catch
    warnmsg = strcat('your dataset contains amica information, but the amica plugin is not installed.  Continuing and ignoring amica information.');
    warning(warnmsg)
end


% recompute latency and epoch number for events
% ---------------------------------------------
if length(g.trial) ~= EEG.trials && ~isempty(EEG.event)
    if ~isfield(EEG.event, 'epoch')
        disp('Pop_epoch warning: bad event format with epoch dataset, removing events');
        EEG.event = [];
    else
        if isfield(EEG.event, 'epoch')
            keepevent = [];
            for indexevent = 1:length(EEG.event)
                newindex = find( EEG.event(indexevent).epoch == g.trial );% For AMICA probabilities...
                %-----------------------------------------------------
                try
                    if isfield(EEG.etc, 'amica') && ~isempty(EEG.etc.amica) && isfield(EEG.etc.amica, 'v_smooth') && ~isempty(EEG.etc.amica.v_smooth) && ~isfield(EEG.etc.amica,'prob_added')
                        if isfield(EEG.etc.amica, 'num_models') && ~isempty(EEG.etc.amica.num_models)
                            if size(EEG.data,2) == size(EEG.etc.amica.v_smooth,2) && size(EEG.data,3) == size(EEG.etc.amica.v_smooth,3) && size(EEG.etc.amica.v_smooth,1) == EEG.etc.amica.num_models
                                
                                EEG = eeg_formatamica(EEG);
                                
                                %-------------------------------------------
                                
                                [EEG com] = pop_select(EEG,args{:});
                                
                                %-------------------------------------------
                                
                                EEG = eeg_reformatamica(EEG);
                                EEG = eeg_checkamica(EEG);
                                return;
                            else
                                disp('AMICA probabilities not compatible with size of data, probabilities cannot be rejected')
                                
                                disp('Resuming rejection...')
                            end
                        end
                        
                    end
                catch
                    warnmsg = strcat('your dataset contains amica information, but the amica plugin is not installed.  Continuing and ignoring amica information.');
                    warning(warnmsg)
                end;
                % ------------------------------------------------------
                
                if ~isempty(newindex)
                    keepevent = [keepevent indexevent];
                    if isfield(EEG.event, 'latency')
                        EEG.event(indexevent).latency = EEG.event(indexevent).latency - (EEG.event(indexevent).epoch-1)*EEG.pnts + (newindex-1)*EEG.pnts;
                    end
                    EEG.event(indexevent).epoch = newindex;
                end
            end
            diffevent = setdiff_bc([1:length(EEG.event)], keepevent);
            if ~isempty(diffevent)
                disp(['Pop_select: removing ' int2str(length(diffevent)) ' unreferenced events']);
                EEG.event(diffevent) = [];
            end
        end
    end
end


% performing removal ------------------
if ~isempty(g.time) || ~isempty(g.notime)
    if EEG.trials > 1
        % select new time window ----------------------
        try,   tmpevent = EEG.event;
            tmpeventlatency = [ tmpevent.latency ];
        catch, tmpeventlatency = [];
        end
        alllatencies = 1-(EEG.xmin*EEG.srate); % time 0 point
        alllatencies = linspace( alllatencies, EEG.pnts*(EEG.trials-1)+alllatencies, EEG.trials);
        [EEG.data tmptime indices epochevent]= epoch(EEG.data, alllatencies, ...
            [g.time(1) g.time(2)]*EEG.srate, 'allevents', tmpeventlatency);
        tmptime = tmptime/EEG.srate;
        if g.time(1) ~= tmptime(1) && g.time(2)-1/EEG.srate ~= tmptime(2)
            fprintf('pop_select(): time limits have been adjusted to [%3.3f %3.3f] to fit data points limits\n', tmptime(1), tmptime(2)+1/EEG.srate);
        end
        EEG.xmin = tmptime(1);
        EEG.xmax = tmptime(2);
        EEG.pnts = size(EEG.data,2);
        alllatencies = alllatencies(indices);
        
        % modify the event structure accordingly (latencies and add epoch
        % field)
        % ----------------------------------------------------------------------
        allevents = [];
        newevent = [];
        count = 1;
        if ~isempty(epochevent)
            newevent = EEG.event(1);
            for index=1:EEG.trials
                for indexevent = epochevent{index}
                    newevent(count)         = EEG.event(indexevent);
                    newevent(count).epoch   = index;
                    newevent(count).latency = newevent(count).latency - alllatencies(index) - tmptime(1)*EEG.srate + 1 + EEG.pnts*(index-1);
                    count = count + 1;
                end
            end
        end
        EEG.event = newevent;
        
        % erase event-related fields from the epochs
        % ------------------------------------------
        if ~isempty(EEG.epoch)
            fn = fieldnames(EEG.epoch);
            EEG.epoch = rmfield(EEG.epoch,{fn{strmatch('event',fn)}});
        end
    else
        if isempty(g.notime)
            if length(g.time) == 2 && EEG.xmin < 0
                disp('Warning: negative minimum time; unchanged to ensure correct latency of initial boundary event');
            end
            g.notime = g.time';
            g.notime = g.notime(:);
            if g.notime(1) ~= 0, g.notime = [EEG.xmin g.notime(:)'];
            else                 g.notime = [g.notime(2:end)'];
            end
            if g.time(end) == EEG.xmax, g.notime(end) = [];
            else                        g.notime(end+1) = EEG.xmax;
            end
            
            for index = 1:length(g.notime)
                if g.notime(index) ~= 0  && g.notime(index) ~= EEG.xmax
                    if mod(index,2), g.notime(index) = g.notime(index) + 1/EEG.srate;
                    else             g.notime(index) = g.notime(index) - 1/EEG.srate;
                    end
                end
            end;
            g.notime = reshape(g.notime, 2, length(g.notime)/2)';
        end;
        
        nbtimes = length(g.notime(:));
        [points,flag] = eeg_lat2point(g.notime(:)', ones(1,nbtimes), EEG.srate, [EEG.xmin EEG.xmax]);
        points = reshape(points, size(g.notime));
        
        % fixing if last region is the same
        if flag
            if ~isempty(find((points(end,1)-points(end,2))== 0)), points(end,:) = []; end
        end
        
        EEG = eeg_eegrej(EEG, points);
    end
end

% performing removal ------------------
if ~isequal(g.channel,1:size(EEG.data,1)) || ~isequal(g.trial,1:size(EEG.data,3))
    %EEG.data  = EEG.data(g.channel, :, g.trial);
    % this code belows is prefered for memory mapped files
    diff1 = setdiff_bc([1:size(EEG.data,1)], g.channel);
    diff2 = setdiff_bc([1:size(EEG.data,3)], g.trial);
    if ~isempty(diff1)
        EEG.data(diff1, :, :) = [];
    end
    if ~isempty(diff2)
        EEG.data(:, :, diff2) = [];
    end
end
if ~isempty(EEG.icaact), EEG.icaact = EEG.icaact(:,:,g.trial); end
EEG.trials    = length(g.trial);
EEG.pnts      = size(EEG.data,2);
EEG.nbchan    = length(g.channel);
if ~isempty(EEG.chanlocs)
    EEG.chanlocs = EEG.chanlocs(g.channel);
end;
if ~isempty(EEG.epoch)
    EEG.epoch = EEG.epoch( g.trial );
end
if ~isempty(EEG.specdata)
    if length(g.point) == EEG.pnts
        EEG.specdata = EEG.specdata(g.channel, :, g.trial);
    else
        EEG.specdata = [];
        %  fprintf('Warning: spectral data were removed because of the
        %  change in the numner of points\n');
    end;
end

% ica specific ------------
if ~isempty(EEG.icachansind)
    
    rmchans = setdiff_bc( EEG.icachansind, g.channel ); % channels to remove
    
    % channel sub-indices -------------------
    icachans = 1:length(EEG.icachansind);
    for index = length(rmchans):-1:1
        chanind           = find(EEG.icachansind == rmchans(index));
        icachans(chanind) = [];
    end
    
    % new channels indices --------------------
    count   = 1;
    newinds = [];
    for index = 1:length(g.channel)
        if any(EEG.icachansind == g.channel(index))
            newinds(count) = index;
            count          = count+1;
        end
    end
    EEG.icachansind = newinds;
    
else
    icachans = 1:size(EEG.icasphere,2);
end

if ~isempty(EEG.icawinv)
    flag_rmchan = (length(icachans) ~= size(EEG.icawinv,1));
    if  isempty(EEG.icaweights) || flag_rmchan
        EEG.icawinv    = EEG.icawinv(icachans,:);
        EEG.icaweights = pinv(EEG.icawinv);
        EEG.icasphere  = eye(size(EEG.icaweights,2));
    end
end
if ~isempty(EEG.specicaact)
    if length(g.point) == EEG.pnts
        EEG.specicaact = EEG.specicaact(icachans, :, g.trial);
    else
        EEG.specicaact = [];
        fprintf('Warning: spectral ICA data were removed because of the change in the numner of points\n');
    end
end

% check if only one epoch -----------------------
if EEG.trials == 1
    if isfield(EEG.event, 'epoch')
        EEG.event = rmfield(EEG.event, 'epoch');
    end
    EEG.epoch = [];
end
if isfield(EEG.reject, 'gcompreject') && isequal(g.channel,1:size(EEG.data,1))
    tmpgcompreject = EEG.reject.gcompreject;
    EEG.reject = [];
    EEG.reject.gcompreject = tmpgcompreject;
else
    EEG.reject = [];
end
EEG.stats  = [];
EEG.reject.rejmanual = [];
% for stats, can adapt remove the selected trials and electrodes in the
% future to gain time -----------------------------------
EEG.stats.jp = [];
EEG = eeg_checksetMG(EEG, 'eventconsistency');

% generate command ----------------
if nargout > 1
    com = sprintf('EEG = pop_select( EEG, %s);', vararg2str(args));
end

return;

% ********* OLD, do not remove any event any more ********* in the future
% maybe do a pack event to remove events not in the time range of any epoch

if ~isempty(EEG.event)
    % go to array format if necessary
    if isstruct(EEG.event), format = 'struct';
    else                     format = 'array';
    end
    switch format, case 'struct', EEG = eventsformat(EEG, 'array'); end
    
    % keep only events related to the selected trials
    Indexes = [];
    Ievent  = [];
    for index = 1:length( g.trial )
        currentevents = find( EEG.event(:,2) == g.trial(index));
        Indexes = [ Indexes ones(1, length(currentevents))*index ];
        Ievent  = union_bc( Ievent, currentevents );
    end
    EEG.event = EEG.event( Ievent,: );
    EEG.event(:,2) = Indexes(:);
    
    switch format, case 'struct', EEG = eventsformat(EEG, 'struct'); end
end









% eeg_checkset()   - check the consistency of the fields of an EEG dataset
%                    Also: See EEG dataset structure field descriptions
%                    below.
%
% Usage: >> [EEGOUT,changes] = eeg_checkset(EEG); % perform all checks
%                                                  except 'makeur'
%        >> [EEGOUT,changes] = eeg_checkset(EEG, 'keyword'); % perform
%        'keyword' check(s)
%
% Inputs:
%       EEG        - EEGLAB dataset structure or (ALLEEG) array of EEG
%       structures
%
% Optional keywords:
%   'icaconsist'   - if EEG contains several datasets, check whether they
%   have
%                    the same ICA decomposition
%   'epochconsist' - if EEG contains several datasets, check whether they
%   have
%                    identical epoch lengths and time limits.
%   'chanconsist'  - if EEG contains several datasets, check whether they
%   have
%                    the same number of channels and channel labels.
%   'data'         - check whether EEG contains data (EEG.data) 'loaddata'
%   - load data array (if necessary) 'savedata'     - save data array (if
%   necessary - see EEG.saved below) 'contdata'     - check whether EEG
%   contains continuous data 'epoch'        - check whether EEG contains
%   epoched or continuous data 'ica'          - check whether EEG contains
%   an ICA decomposition 'besa'         - check whether EEG contains
%   component dipole locations 'event'        - check whether EEG contains
%   an event array 'makeur'       - remake the EEG.urevent structure
%   'checkur'      - check whether the EEG.urevent structure is consistent
%                    with the EEG.event structure
%   'chanlocsize'  - check the EEG.chanlocs structure length; show warning
%   if
%                    necessary.
%   'chanlocs_homogeneous' - check whether EEG contains consistent channel
%                            information; if not, correct it.This option
%                            calls eeg_checkchanlocs.
%   'eventconsistency'     - check whether EEG.event information are
%   consistent;
%                            rebuild event* subfields of the 'EEG.epoch'
%                            structure (can be time consuming).
% Outputs:
%       EEGOUT     - output EEGLAB dataset or dataset array changes    -
%       change code: 'no' = no changes; 'yes' = the EEG
%                    structure was modified
%
% =========================================================== The structure
% of an EEG dataset under EEGLAB (as of v5.03):
%
% Basic dataset information:
%   EEG.setname      - descriptive name|title for the dataset EEG.filename
%   - filename of the dataset file on disk EEG.filepath     - filepath
%   (directory/folder) of the dataset file(s) EEG.trials       - number of
%   epochs (or trials) in the dataset.
%                      If data are continuous, this number is 1.
%   EEG.pnts         - number of time points (or data frames) per trial
%   (epoch).
%                      If data are continuous (trials=1), the total number
%                      of time points (frames) in the dataset
%   EEG.nbchan       - number of channels EEG.srate        - data sampling
%   rate (in Hz) EEG.xmin         - epoch start latency|time (in sec.
%   relative to the
%                      time-locking event at time 0)
%   EEG.xmax         - epoch end latency|time (in seconds) EEG.times
%   - vector of latencies|times in miliseconds (one per time point) EEG.ref
%   - ['common'|'averef'|integer] reference channel type or number
%   EEG.history      - cell array of ascii pop-window commands that created
%                      or modified the dataset
%   EEG.comments     - comments about the nature of the dataset (edit this
%   via
%                      menu selection Edit > About this dataset)
%   EEG.etc          - miscellaneous (technical or temporary) dataset
%   information EEG.saved        - ['yes'|'no'] 'no' flags need to save
%   dataset changes before exit
%
% The data:
%   EEG.data         - two-dimensional continuous data array (chans,
%   frames)
%                      ELSE, three-dim. epoched data array (chans, frames,
%                      epochs)
%
% The channel locations sub-structures:
%   EEG.chanlocs     - structure array containing names and locations
%                      of the channels on the scalp
%   EEG.urchanlocs   - original (ur) dataset chanlocs structure containing
%                      all channels originally collected with these data
%                      (before channel rejection)
%   EEG.chaninfo     - structure containing additional channel info EEG.ref
%   - type of channel reference ('common'|'averef'|+/-int] EEG.splinefile
%   - location of the spline file used by headplot() to plot
%                      data scalp maps in 3-D
%
% The event and epoch sub-structures:
%   EEG.event        - event structure containing times and nature of
%   experimental
%                      events recorded as occurring at data time points
%   EEG.urevent      - original (ur) event structure containing all
%   experimental
%                      events recorded as occurring at the original data
%                      time points (before data rejection)
%   EEG.epoch        - epoch event information and epoch-associated data
%   structure array (one per epoch) EEG.eventdescription - cell array of
%   strings describing event fields. EEG.epochdescription - cell array of
%   strings describing epoch fields. --> See the
%   http://sccn.ucsd.edu/eeglab/maintut/eeglabscript.html for details
%
% ICA (or other linear) data components:
%   EEG.icasphere   - sphering array returned by linear (ICA) decomposition
%   EEG.icaweights  - unmixing weights array returned by linear (ICA)
%   decomposition EEG.icawinv     - inverse (ICA) weight matrix. Columns
%   gives the projected
%                     topographies of the components to the electrodes.
%   EEG.icaact      - ICA activations matrix (components, frames, epochs)
%                     Note: [] here means that 'compute_ica' option has bee
%                     set to 0 under 'File > Memory options' In this case,
%                     component activations are computed only as needed.
%   EEG.icasplinefile - location of the spline file used by headplot() to
%   plot
%                     component scalp maps in 3-D
%   EEG.chaninfo.icachansind  - indices of channels used in the ICA
%   decomposition EEG.dipfit      - array of structures containing
%   component map dipole models
%
% Variables indicating membership of the dataset in a studyset:
%   EEG.subject     - studyset subject code EEG.group       - studyset
%   group code EEG.condition   - studyset experimental condition code
%   EEG.session     - studyset session number
%
% Variables used for manual and semi-automatic data rejection:
%   EEG.specdata           - data spectrum for every single trial
%   EEG.specica            - data spectrum for every single trial EEG.stats
%   - statistics used for data rejection
%       EEG.stats.kurtc    - component kurtosis values EEG.stats.kurtg    -
%       global kurtosis of components EEG.stats.kurta    - kurtosis of
%       accepted epochs EEG.stats.kurtr    - kurtosis of rejected epochs
%       EEG.stats.kurtd    - kurtosis of spatial distribution
%   EEG.reject            - statistics used for data rejection
%       EEG.reject.entropy - entropy of epochs EEG.reject.entropyc  -
%       entropy of components EEG.reject.threshold - rejection thresholds
%       EEG.reject.icareject - epochs rejected by ICA criteria
%       EEG.reject.gcompreject - rejected ICA components
%       EEG.reject.sigreject  - epochs rejected by single-channel criteria
%       EEG.reject.elecreject - epochs rejected by raw data criteria
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% See also: eeglab()

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This file is part of EEGLAB, see http://www.eeglab.org for the
% documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% 01-25-02 reformated help & license -ad 01-26-02 chandeg events and trial
% condition format -ad 01-27-02 debug when trial condition is empty -ad
% 02-15-02 remove icawinv recompute for pop_epoch -ad & ja 02-16-02 remove
% last modification and test icawinv separatelly -ad 02-16-02 empty event
% and epoch check -ad 03-07-02 add the eeglab options -ad 03-07-02
% corrected typos and rate/point calculation -ad & ja 03-15-02 add channel
% location reading & checking -ad 03-15-02 add checking of ICA and epochs
% with pop_up windows -ad 03-27-02 recorrected rate/point calculation -ad &
% sm

function [EEG, res] = eeg_checksetMG( EEG, varargin );
msg = '';
res = 'no';
com = sprintf('EEG = eeg_checkset( EEG );');

if nargin < 1
    help eeg_checkset;
    return;
end

if isempty(EEG), return; end
if ~isfield(EEG, 'data'), return; end

% checking multiple datasets --------------------------
if length(EEG) > 1
    
    if nargin > 1
        switch varargin{1}
            case 'epochconsist', % test epoch consistency
                % ----------------------
                res = 'no';
                datasettype = unique_bc( [ EEG.trials ] );
                if datasettype(1) == 1 && length(datasettype) == 1, return; % continuous data
                elseif datasettype(1) == 1,                        return; % continuous and epoch data
                end
                
                allpnts = unique_bc( [ EEG.pnts ] );
                allxmin = unique_bc( [ EEG.xmin ] );
                if length(allpnts) == 1 && length(allxmin) == 1, res = 'yes'; end
                return;
                
            case 'chanconsist'  % test channel number and name consistency
                % ----------------------------------------
                res = 'yes';
                chanlen    = unique_bc( [ EEG.nbchan ] );
                anyempty    = unique_bc( cellfun( 'isempty', { EEG.chanlocs }) );
                if length(chanlen) == 1 && all(anyempty == 0)
                    tmpchanlocs = EEG(1).chanlocs;
                    channame1 = { tmpchanlocs.labels };
                    for i = 2:length(EEG)
                        tmpchanlocs = EEG(i).chanlocs;
                        channame2 = { tmpchanlocs.labels };
                        if length(intersect(channame1, channame2)) ~= length(channame1), res = 'no'; end
                    end
                else res = 'no';
                end
                
                % Field 'datachan in 'urchanlocs' is removed, if exist
                if isfield(EEG, 'urchanlocs') && ~all(cellfun(@isempty,{EEG.urchanlocs})) && isfield([EEG.urchanlocs], 'datachan')
                    [EEG.urchanlocs] = deal(rmfield([EEG.urchanlocs], 'datachan'));
                end
                return;
                
            case 'icaconsist'  % test ICA decomposition consistency
                % ----------------------------------
                res = 'yes';
                anyempty    = unique_bc( cellfun( 'isempty', { EEG.icaweights }) );
                if length(anyempty) == 1 && anyempty(1) == 0
                    ica1 = EEG(1).icawinv;
                    for i = 2:length(EEG)
                        if ~isequal(EEG(1).icawinv, EEG(i).icawinv)
                            res = 'no';
                        end
                    end
                else res = 'no';
                end
                return;
                
        end
    end
    
end

% reading these option take time because of disk access --------------
eeglab_options;

% standard checking -----------------
ALLEEG = EEG;
for inddataset = 1:length(ALLEEG)
    
    EEG = ALLEEG(inddataset);
    
    % additional checks -----------------
    res = -1; % error code
    if ~isempty( varargin)
        for index = 1:length( varargin )
            switch varargin{ index }
                case 'data',; % already done at the top
                case 'contdata',;
                    if EEG.trials > 1
                        errordlg2(strvcat('Error: function only works on continuous data'), 'Error');
                        return;
                    end
                case 'ica',
                    if isempty(EEG.icaweights)
                        errordlg2(strvcat('Error: no ICA decomposition. use menu "Tools > Run ICA" first.'), 'Error');
                        return;
                    end
                case 'epoch',
                    if EEG.trials == 1
                        errordlg2(strvcat('Extract epochs before running that function', 'Use Tools > Extract epochs'), 'Error');
                        return
                    end
                case 'besa',
                    if ~isfield(EEG, 'sources')
                        errordlg2(strvcat('No dipole information', '1) Export component maps: Tools > Localize ... BESA > Export ...' ...
                            , '2) Run BESA to localize the equivalent dipoles', ...
                            '3) Import the BESA dipoles: Tools > Localize ... BESA > Import ...'), 'Error');
                        return
                    end
                case 'event',
                    if isempty(EEG.event)
                        errordlg2(strvcat('Requires events. You need to add events first.', ...
                            'Use "File > Import event info" or "File > Import epoch info"'), 'Error');
                        return;
                    end
                case 'chanloc',
                    tmplocs = EEG.chanlocs;
                    if isempty(tmplocs) || ~isfield(tmplocs, 'theta') || all(cellfun('isempty', { tmplocs.theta }))
                        errordlg2( strvcat('This functionality requires channel location information.', ...
                            'Enter the channel file name via "Edit > Edit dataset info".', ...
                            'For channel file format, see ''>> help readlocs'' from the command line.'), 'Error');
                        return;
                    end
                case 'chanlocs_homogeneous',
                    tmplocs = EEG.chanlocs;
                    if isempty(tmplocs) || ~isfield(tmplocs, 'theta') || all(cellfun('isempty', { tmplocs.theta }))
                        errordlg2( strvcat('This functionality requires channel location information.', ...
                            'Enter the channel file name via "Edit > Edit dataset info".', ...
                            'For channel file format, see ''>> help readlocs'' from the command line.'), 'Error');
                        return;
                    end
                    if ~isfield(EEG.chanlocs, 'X') || isempty(EEG.chanlocs(1).X)
                        EEG = eeg_checkchanlocs(EEG);
                        % EEG.chanlocs = convertlocs(EEG.chanlocs,
                        % 'topo2all');
                        res = ['EEG = eeg_checkset(EEG, ''chanlocs_homogeneous''); ' ];
                    end
                case 'chanlocsize',
                    if ~isempty(EEG.chanlocs)
                        if length(EEG.chanlocs) > EEG.nbchan
                            questdlg2(strvcat('Warning: there is one more electrode location than', ...
                                'data channels. EEGLAB will consider the last electrode to be the', ...
                                'common reference channel. If this is not the case, remove the', ...
                                'extra channel'), 'Warning', 'Ok', 'Ok');
                        end
                    end
                case 'makeur',
                    if ~isempty(EEG.event)
                        if isfield(EEG.event, 'urevent'),
                            EEG.event = rmfield(EEG.event, 'urevent');
                            disp('eeg_checkset note: re-creating the original event table (EEG.urevent)');
                        else
                            disp('eeg_checkset note: creating the original event table (EEG.urevent)');
                        end
                        EEG.urevent = EEG.event;
                        for index = 1:length(EEG.event)
                            EEG.event(index).urevent = index;
                        end
                    end
                case 'checkur',
                    if ~isempty(EEG.event)
                        if isfield(EEG.event, 'urevent') && ~isempty(EEG.urevent)
                            urlatencies = [ EEG.urevent.latency ];
                            [newlat tmpind] = sort(urlatencies);
                            if ~isequal(newlat, urlatencies)
                                EEG.urevent   = EEG.urevent(tmpind);
                                [tmp tmpind2] = sort(tmpind);
                                for index = 1:length(EEG.event)
                                    EEG.event(index).urevent = tmpind2(EEG.event(index).urevent);
                                end
                            end
                        end
                    end
                case 'eventconsistency',
                    [EEG res] = eeg_checksetMG(EEG);
                    if isempty(EEG.event), return; end
                    
                    % check events (slow) ------------
                    if isfield(EEG.event, 'type')
                        eventInds = arrayfun(@(x)isempty(x.type), EEG.event);
                        if any(eventInds)
                            if all(arrayfun(@(x)isnumeric(x.type), EEG.event))
                                for ind = find(eventInds), EEG.event(ind).type = NaN; end
                            else for ind = find(eventInds), EEG.event(ind).type = 'empty'; end
                            end
                        end
                        if ~all(arrayfun(@(x)ischar(x.type), EEG.event)) && ~all(arrayfun(@(x)isnumeric(x.type), EEG.event))
                            disp('Warning: converting all event types to strings');
                            for ind = 1:length(EEG.event)
                                EEG.event(ind).type = num2str(EEG.event(ind).type);
                            end
                            EEG = eeg_checksetMG(EEG, 'eventconsistency');
                        end
                        
                    end
                    
                    % Removing events with NaN latency
                    % --------------------------------
                    if isfield(EEG.event, 'latency')
                        nanindex = find(isnan([ EEG.event.latency ]));
                        if ~isempty(nanindex)
                            EEG.event(nanindex) = [];
                            trialtext = '';
                            for inan = 1:length(nanindex)
                                trialstext = [trialtext ' ' num2str(nanindex(inan))];
                            end
                            disp(sprintf(['eeg_checkset: Event(s) with NaN latency were deleted \nDeleted event index(es):[' trialstext ']']));
                        end
                    end
                    
                    % remove the events which latency are out of boundary
                    % ---------------------------------------------------
                    if isfield(EEG.event, 'latency')
                        if isfield(EEG.event, 'type') && ischar(EEG.event(1).type)
                            if strcmpi(EEG.event(1).type, 'boundary') && isfield(EEG.event, 'duration')
                                if EEG.event(1).duration < 1
                                    EEG.event(1) = [];
                                elseif EEG.event(1).latency > 0 && EEG.event(1).latency < 1
                                    EEG.event(1).latency = 0.5;
                                end
                            end
                        end
                        
                        try, tmpevent = EEG.event; alllatencies = [ tmpevent.latency ];
                        catch, error('Checkset: error empty latency entry for new events added by user');
                        end
                        I1 = find(alllatencies < 0.5);
                        I2 = find(alllatencies > EEG.pnts*EEG.trials+1); % The addition of 1 was included
                        % because, if data epochs are extracted from -1 to
                        % time 0, this allow to include the last event in
                        % the last epoch (otherwise all epochs have an
                        % event except the last one
                        if (length(I1) + length(I2)) > 0
                            fprintf('eeg_checkset warning: %d/%d events had out-of-bounds latencies and were removed\n', ...
                                length(I1) + length(I2), length(EEG.event));
                            EEG.event(union(I1, I2)) = [];
                        end
                    end
                    if isempty(EEG.event), return; end
                    
                    % save information for non latency fields updates
                    % -----------------------------------------------
                    difffield = [];
                    if ~isempty(EEG.event) && isfield(EEG.event, 'epoch')
                        % remove fields with empty epochs
                        % -------------------------------
                        removeevent = [];
                        try, tmpevent = EEG.event; allepochs = [ tmpevent.epoch ];
                            removeevent = find( allepochs < 1 || allepochs > EEG.trials);
                            if ~isempty(removeevent)
                                disp([ 'eeg_checkset warning: ' int2str(length(removeevent)) ' event had invalid epoch numbers and were removed']);
                            end
                        catch,
                            for indexevent = 1:length(EEG.event)
                                if isempty( EEG.event(indexevent).epoch ) || ~isnumeric(EEG.event(indexevent).epoch) ...
                                        || EEG.event(indexevent).epoch < 1 || EEG.event(indexevent).epoch > EEG.trials
                                    removeevent = [removeevent indexevent];
                                    disp([ 'eeg_checkset warning: event ' int2str(indexevent) ' has an invalid epoch number: removed']);
                                end
                            end
                        end
                        EEG.event(removeevent) = [];
                        tmpevent  = EEG.event;
                        allepochs = [ tmpevent.epoch ];
                        
                        % uniformize fields content for the different
                        % epochs
                        % --------------------------------------------------
                        % THIS WAS REMOVED SINCE SOME FIELDS ARE ASSOCIATED
                        % WITH THE EVENT AND NOT WITH THE EPOCH I PUT IT
                        % BACK, BUT IT DOES NOT ERASE NON-EMPTY VALUES
                        difffield = fieldnames(EEG.event);
                        difffield = difffield(~(strcmp(difffield,'latency')|strcmp(difffield,'epoch')|strcmp(difffield,'type')|strcmp(difffield,'mffkeys')|strcmp(difffield,'mffkeysbackup')|strcmp(difffield,'begintime')));
                        for index = 1:length(difffield)
                            tmpevent  = EEG.event;
                            allvalues = { tmpevent.(difffield{index}) };
                            try
                                valempt = cellfun('isempty', allvalues);
                            catch
                                valempt = mycellfun('isempty', allvalues);
                            end
                            arraytmpinfo = cell(1,EEG.trials);
                            
                            % spetial case of duration
                            % ------------------------
                            if strcmp( difffield{index}, 'duration')
                                if any(valempt)
                                    fprintf(['eeg_checkset: found empty values for field ''' difffield{index} ...
                                        ''' (filling with 0)\n']);
                                end
                                for indexevent = find(valempt)
                                    EEG.event(indexevent).duration = 0;
                                end
                            else
                                
                                % get the field content
                                % ---------------------
                                indexevent = find(~valempt);
                                arraytmpinfo(allepochs(indexevent)) = allvalues(indexevent);
                                
                                % uniformize content for all epochs
                                % ---------------------------------
                                indexevent = find(valempt);
                                tmpevent   = EEG.event;
                                [tmpevent(indexevent).(difffield{index})] = arraytmpinfo{allepochs(indexevent)};
                                EEG.event  = tmpevent;
                                if any(valempt)
                                    fprintf(['eeg_checkset: found empty values for field ''' difffield{index} '''\n']);
                                    fprintf(['              filling with values of other events in the same epochs\n']);
                                end
                            end
                        end
                    end
                    if isempty(EEG.event), return; end
                    
                    % uniformize fields (str or int) if necessary
                    % -------------------------------------------
                    fnames = fieldnames(EEG.event);
                    for fidx = 1:length(fnames)
                        fname = fnames{fidx};
                        if ~strcmpi(fname, 'mffkeys') && ~strcmpi(fname, 'mffkeysbackup')
                            tmpevent  = EEG.event;
                            allvalues = { tmpevent.(fname) };
                            try
                                % find indices of numeric values among
                                % values of this event property
                                valreal = ~cellfun('isclass', allvalues, 'char');
                            catch
                                valreal = mycellfun('isclass', allvalues, 'double');
                            end
                            
                            format = 'ok';
                            if ~all(valreal) % all valreal ok
                                format = 'str';
                                if all(valreal == 0) % all valreal=0 ok
                                    format = 'ok';
                                end
                            end
                            if strcmp(format, 'str')
                                fprintf('eeg_checkset note: event field format ''%s'' made uniform\n', fname);
                                allvalues = cellfun(@num2str, allvalues, 'uniformoutput', false);
                                [EEG.event(valreal).(fname)] = deal(allvalues{find(valreal)});
                            end
                        end
                    end
                    
                    % check boundary events ---------------------
                    tmpevent = EEG.event;
                    if isfield(tmpevent, 'type') && ~isnumeric(tmpevent(1).type)
                        allEventTypes = { tmpevent.type };
                        boundsInd = strmatch('boundary', allEventTypes);
                        if ~isempty(boundsInd),
                            bounds = [ tmpevent(boundsInd).latency ];
                            % remove last event if necessary
                            if EEG.trials==1;%this if block added by James Desjardins (Jan 13th, 2014)
                                if round(bounds(end)-0.5+1) >= size(EEG.data,2), EEG.event(boundsInd(end)) = []; bounds(end) = []; end; % remove final boundary if any
                            end
                            % The first boundary below need to be kept for
                            % urevent latency calculation if bounds(1) < 0,
                            % EEG.event(bounds(1))   = []; end; % remove
                            % initial boundary if any
                            indDoublet = find(bounds(2:end)-bounds(1:end-1)==0);
                            if ~isempty(indDoublet)
                                disp('Warning: duplicate boundary event removed');
                                if isfield(EEG.event, 'duration')
                                    for indBound = 1:length(indDoublet)
                                        EEG.event(boundsInd(indDoublet(indBound)+1)).duration = EEG.event(boundsInd(indDoublet(indBound)+1)).duration+EEG.event(boundsInd(indDoublet(indBound))).duration;
                                    end
                                end
                                EEG.event(boundsInd(indDoublet)) = [];
                            end
                        end
                    end
                    if isempty(EEG.event), return; end
                    
                    % check that numeric format is double (Matlab 7)
                    % -----------------------------------
                    allfields = fieldnames(EEG.event);
                    if ~isempty(EEG.event)
                        for index = 1:length(allfields)
                            tmpval = EEG.event(1).(allfields{index});
                            if isnumeric(tmpval) && ~isa(tmpval, 'double')
                                for indexevent = 1:length(EEG.event)
                                    tmpval  =   getfield(EEG.event, { indexevent }, allfields{index} );
                                    EEG.event = setfield(EEG.event, { indexevent }, allfields{index}, double(tmpval));
                                end
                            end
                        end
                    end
                    
                    % check duration field, replace empty by 0
                    % ----------------------------------------
                    if isfield(EEG.event, 'duration')
                        tmpevent = EEG.event;
                        try,   valempt = cellfun('isempty'  , { tmpevent.duration });
                        catch, valempt = mycellfun('isempty', { tmpevent.duration });
                        end
                        if any(valempt),
                            for index = find(valempt)
                                EEG.event(index).duration = 0;
                            end
                        end
                    end
                    
                    % resort events -------------
                    if isfield(EEG.event, 'latency')
                        try,
                            if isfield(EEG.event, 'epoch')
                                TMPEEG = pop_editeventvals(EEG, 'sort', { 'epoch' 0 'latency' 0 });
                            else
                                TMPEEG = pop_editeventvals(EEG, 'sort', { 'latency' 0 });
                            end
                            if ~isequal(TMPEEG.event, EEG.event)
                                EEG = TMPEEG;
                                disp('Event resorted by increasing latencies.');
                            end
                        catch,
                            disp('eeg_checkset: problem when attempting to resort event latencies.');
                        end
                    end
                    
                    % check latency of first event
                    % ----------------------------
                    if ~isempty(EEG.event)
                        if isfield(EEG.event, 'latency')
                            if EEG.event(1).latency < 0.5
                                EEG.event(1).latency = 0.5;
                            end
                        end
                    end
                    
                    % build epoch structure ---------------------
                    try,
                        if EEG.trials > 1 && ~isempty(EEG.event)
                            % erase existing event-related fields
                            % ------------------------------
                            if ~isfield(EEG,'epoch')
                                EEG.epoch = [];
                            end
                            if ~isempty(EEG.epoch)
                                if length(EEG.epoch) ~= EEG.trials
                                    disp('Warning: number of epoch entries does not match number of dataset trials;');
                                    disp('         user-defined epoch entries will be erased.');
                                    EEG.epoch = [];
                                else
                                    fn = fieldnames(EEG.epoch);
                                    EEG.epoch = rmfield(EEG.epoch,fn(strncmp('event',fn,5)));
                                end
                            end
                            
                            % set event field ---------------
                            tmpevent   = EEG.event;
                            eventepoch = [tmpevent.epoch];
                            epochevent = cell(1,EEG.trials);
                            destdata = epochevent;
                            EEG.epoch(length(epochevent)).event = [];
                            for k=1:length(epochevent)
                                epochevent{k} = find(eventepoch==k);
                            end
                            tmpepoch = EEG.epoch;
                            [tmpepoch.event] = epochevent{:};
                            EEG.epoch = tmpepoch;
                            maxlen = max(cellfun(@length,epochevent));
                            
                            % copy event information into the epoch array
                            % -------------------------------------------
                            eventfields = fieldnames(EEG.event)';
                            eventfields = eventfields(~strcmp(eventfields,'epoch'));
                            tmpevent    = EEG.event;
                            for k = 1:length(eventfields)
                                fname = eventfields{k};
                                switch fname
                                    case 'latency'
                                        sourcedata = round(eeg_point2lat([tmpevent.(fname)],[tmpevent.epoch],EEG.srate, [EEG.xmin EEG.xmax]*1000, 1E-3) * 10^8 )/10^8;
                                        sourcedata = num2cell(sourcedata);
                                    case 'duration'
                                        sourcedata = num2cell([tmpevent.(fname)]/EEG.srate*1000);
                                    otherwise
                                        sourcedata = {tmpevent.(fname)};
                                end
                                if maxlen == 1
                                    destdata = cell(1,length(epochevent));
                                    destdata(~cellfun('isempty',epochevent)) = sourcedata([epochevent{:}]);
                                else
                                    for l=1:length(epochevent)
                                        destdata{l} = sourcedata(epochevent{l});
                                    end
                                end
                                tmpepoch = EEG.epoch;
                                [tmpepoch.(['event' fname])] = destdata{:};
                                EEG.epoch = tmpepoch;
                            end
                        end
                    catch,
                        errordlg2(['Warning: minor problem encountered when generating' 10 ...
                            'the EEG.epoch structure (used only in user scripts)']); return;
                    end
                case { 'loaddata' 'savedata' 'chanconsist' 'icaconsist' 'epochconsist' }, res = '';
                otherwise, error('eeg_checkset: unknown option');
            end
        end
    end
    
    res = [];
    
    % check name consistency ----------------------
    if ~isempty(EEG.setname)
        if ~ischar(EEG.setname)
            EEG.setname = '';
        else
            if size(EEG.setname,1) > 1
                disp('eeg_checkset warning: invalid dataset name, removed');
                EEG.setname = '';
            end
        end
    else
        EEG.setname = '';
    end
    
    % checking history and convert if necessary
    % -----------------------------------------
    if isfield(EEG, 'history') && size(EEG.history,1) > 1
        allcoms = cellstr(EEG.history);
        EEG.history = deblank(allcoms{1});
        for index = 2:length(allcoms)
            EEG.history = [ EEG.history 10 deblank(allcoms{index}) ];
        end
    end
    
    % read data if necessary ----------------------
    if ischar(EEG.data) && nargin > 1
        if strcmpi(varargin{1}, 'loaddata')
            
            EEG.data = eeg_getdatact(EEG);
            
        end
    end
    
    % save data if necessary ----------------------
    if nargin > 1
        
        % datfile available? ------------------
        datfile = 0;
        if isfield(EEG, 'datfile')
            if ~isempty(EEG.datfile)
                datfile = 1;
            end
        end
        
        % save data ---------
        if strcmpi(varargin{1}, 'savedata') && option_storedisk
            error('eeg_checkset: cannot call savedata any more');
            
            % the code below is deprecated
            if ~ischar(EEG.data) % not already saved
                disp('Writing previous dataset to disk...');
                
                if datfile
                    tmpdata = reshape(EEG.data, EEG.nbchan,  EEG.pnts*EEG.trials);
                    floatwrite( tmpdata', fullfile(EEG.filepath, EEG.datfile), 'ieee-le');
                    EEG.data   = EEG.datfile;
                end
                EEG.icaact = [];
                
                % saving dataset --------------
                filename = fullfile(EEG(1).filepath, EEG(1).filename);
                if ~ischar(EEG.data) && option_single, EEG.data = single(EEG.data); end
                v = version;
                if str2num(v(1)) >= 7, save( filename, '-v6', '-mat', 'EEG'); % Matlab 7
                else                   save( filename, '-mat', 'EEG');
                end
                if ~ischar(EEG.data), EEG.data = 'in set file'; end
                
                % res = sprintf('%s = eeg_checkset( %s, ''savedata'');',
                % inputname(1), inputname(1));
                res = ['EEG = eeg_checkset( EEG, ''savedata'');'];
            end
        end
    end
    
    % numerical format ----------------
    if isnumeric(EEG.data)
        v = version;
        EEG.icawinv    = double(EEG.icawinv); % required for dipole fitting, otherwise it crashes
        EEG.icaweights = double(EEG.icaweights);
        EEG.icasphere  = double(EEG.icasphere);
        if ~isempty(findstr(v, 'R11')) || ~isempty(findstr(v, 'R12')) || ~isempty(findstr(v, 'R13'))
            EEG.data       = double(EEG.data);
            EEG.icaact     = double(EEG.icaact);
        else
            try,
                if isa(EEG.data, 'double') && option_single
                    EEG.data       = single(EEG.data);
                    EEG.icaact     = single(EEG.icaact);
                end
            catch,
                disp('WARNING: EEGLAB ran out of memory while converting dataset to single precision.');
                disp('         Save dataset (preferably saving data to a separate file; see File > Memory options).');
                disp('         Then reload it.');
            end
        end
    end
    
    % verify the type of the variables --------------------------------
    % data dimensions -------------------------
    if isnumeric(EEG.data) && ~isempty(EEG.data)
        if ~isequal(size(EEG.data,1), EEG.nbchan)
            disp( [ 'eeg_checkset warning: number of columns in data (' int2str(size(EEG.data,1)) ...
                ') does not match the number of channels (' int2str(EEG.nbchan) '): corrected' ]);
            res = com;
            EEG.nbchan = size(EEG.data,1);
        end
        
        if (ndims(EEG.data)) < 3 && (EEG.pnts > 1)
            if mod(size(EEG.data,2), EEG.pnts) ~= 0
                if popask( [ 'eeg_checkset error: the number of frames does not divide the number of columns in the data.'  10 ...
                        'Should EEGLAB attempt to abort operation ?' 10 '(press Cancel to fix the problem from the command line)'])
                    error('eeg_checkset error: user abort');
                    %res = com; EEG.pnts = size(EEG.data,2); EEG =
                    %eeg_checkset(EEG); return;
                else
                    res = com;
                    return;
                    %error( 'eeg_checkset error: number of points does not
                    %divide the number of columns in data');
                end
            else
                if EEG.trials > 1
                    disp( 'eeg_checkset note: data array made 3-D');
                    res = com;
                end
                if size(EEG.data,2) ~= EEG.pnts
                    EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, size(EEG.data,2)/EEG.pnts);
                end
            end
        end
        
        % size of data -----------
        if size(EEG.data,3) ~= EEG.trials
            disp( ['eeg_checkset warning: 3rd dimension size of data (' int2str(size(EEG.data,3)) ...
                ') does not match the number of epochs (' int2str(EEG.trials) '), corrected' ]);
            res = com;
            EEG.trials = size(EEG.data,3);
        end
        if size(EEG.data,2) ~= EEG.pnts
            disp( [ 'eeg_checkset warning: number of columns in data (' int2str(size(EEG.data,2)) ...
                ') does not match the number of points (' int2str(EEG.pnts) '): corrected' ]);
            res = com;
            EEG.pnts = size(EEG.data,2);
        end
    end
    
    % parameters consistency -------------------------
    if round(EEG.srate*(EEG.xmax-EEG.xmin)+1) ~= EEG.pnts
        fprintf( 'eeg_checkset note: upper time limit (xmax) adjusted so (xmax-xmin)*srate+1 = number of frames\n');
        if EEG.srate == 0
            EEG.srate = 1;
        end
        EEG.xmax = (EEG.pnts-1)/EEG.srate+EEG.xmin;
        res = com;
    end
    
    % deal with event arrays ----------------------
    if ~isfield(EEG, 'event'), EEG.event = []; res = com; end
    if ~isempty(EEG.event)
        if EEG.trials > 1 && ~isfield(EEG.event, 'epoch')
            if popask( [ 'eeg_checkset error: the event info structure does not contain an ''epoch'' field.'  ...
                    'Should EEGLAB attempt to abort operation ?' 10 '(press Cancel to fix the problem from the commandline)'])
                error('eeg_checkset error(): user abort');
                %res = com; EEG.event = []; EEG = eeg_checkset(EEG);
                %return;
            else
                res = com;
                return;
                %error('eeg_checkset error: no epoch field in event
                %structure');
            end
        end
    else
        EEG.event = [];
    end
    if isempty(EEG.event)
        EEG.eventdescription = {};
    end
    if ~isfield(EEG, 'eventdescription') || ~iscell(EEG.eventdescription)
        EEG.eventdescription = cell(1, length(fieldnames(EEG.event)));
        res = com;
    else
        if ~isempty(EEG.event)
            if length(EEG.eventdescription) > length( fieldnames(EEG.event))
                EEG.eventdescription = EEG.eventdescription(1:length( fieldnames(EEG.event)));
            elseif length(EEG.eventdescription) < length( fieldnames(EEG.event))
                EEG.eventdescription(end+1:length( fieldnames(EEG.event))) = {''};
            end
        end
    end
    % create urevent if continuous data ---------------------------------
    %if ~isempty(EEG.event) && ~isfield(EEG, 'urevent')
    %    EEG.urevent = EEG.event;
    %   disp('eeg_checkset note: creating the original event table
    %   (EEG.urevent)');
    %    for index = 1:length(EEG.event)
    %        EEG.event(index).urevent = index;
    %    end
    %end
    if isfield(EEG, 'urevent') && isfield(EEG.urevent, 'urevent')
        EEG.urevent = rmfield(EEG.urevent, 'urevent');
    end
    
    % deal with epoch arrays ----------------------
    if ~isfield(EEG, 'epoch'), EEG.epoch = []; res = com; end
    
    % check if only one epoch -----------------------
    if EEG.trials == 1
        if isfield(EEG.event, 'epoch')
            EEG.event = rmfield(EEG.event, 'epoch'); res = com;
        end
        if ~isempty(EEG.epoch)
            EEG.epoch = []; res = com;
        end
    end
    
    if ~isfield(EEG, 'epochdescription'), EEG.epochdescription = {}; res = com; end
    if ~isempty(EEG.epoch)
        if isstruct(EEG.epoch),  l = length( EEG.epoch);
        else                     l = size( EEG.epoch, 2);
        end
        if l ~= EEG.trials
            if popask( [ 'eeg_checkset error: the number of epoch indices in the epoch array/struct (' ...
                    int2str(l) ') is different from the number of epochs in the data (' int2str(EEG.trials) ').' 10 ...
                    'Should EEGLAB attempt to abort operation ?' 10 '(press Cancel to fix the problem from the commandline)'])
                error('eeg_checkset error: user abort');
                %res = com; EEG.epoch = []; EEG = eeg_checkset(EEG);
                %return;
            else
                res = com;
                return;
                %error('eeg_checkset error: epoch structure size invalid');
            end
        end
    else
        EEG.epoch = [];
    end
    
    % check ica ---------
    if ~isfield(EEG, 'icachansind')
        if isempty(EEG.icaweights)
            EEG.icachansind = []; res = com;
        else
            EEG.icachansind = [1:EEG.nbchan]; res = com;
        end
    elseif isempty(EEG.icachansind)
        if isempty(EEG.icaweights)
            EEG.icachansind = []; res = com;
        else
            EEG.icachansind = [1:EEG.nbchan]; res = com;
        end
    end
    if ~isempty(EEG.icasphere)
        if ~isempty(EEG.icaweights)
            if size(EEG.icaweights,2) ~= size(EEG.icasphere,1)
                if popask( [ 'eeg_checkset error: number of columns in weights array (' int2str(size(EEG.icaweights,2)) ')' 10 ...
                        'does not match the number of rows in the sphere array (' int2str(size(EEG.icasphere,1)) ')' 10 ...
                        'Should EEGLAB remove ICA information ?' 10 '(press Cancel to fix the problem from the commandline)'])
                    res = com;
                    EEG.icasphere = [];
                    EEG.icaweights = [];
                    EEG = eeg_checksetMG(EEG);
                    return;
                else
                    error('eeg_checkset error: user abort');
                    res = com;
                    return;
                    %error('eeg_checkset error: invalid weight and sphere
                    %array sizes');
                end
            end
            if isnumeric(EEG.data)
                if length(EEG.icachansind) ~= size(EEG.icasphere,2)
                    if popask( [ 'eeg_checkset error: number of elements in ''icachansind'' (' int2str(length(EEG.icachansind)) ')' 10 ...
                            'does not match the number of columns in the sphere array (' int2str(size(EEG.icasphere,2)) ')' 10 ...
                            'Should EEGLAB remove ICA information ?' 10 '(press Cancel to fix the problem from the commandline)'])
                        res = com;
                        EEG.icasphere = [];
                        EEG.icaweights = [];
                        EEG = eeg_checksetMG(EEG);
                        return;
                    else
                        error('eeg_checkset error: user abort');
                        res = com;
                        return;
                        %error('eeg_checkset error: invalid weight and
                        %sphere array sizes');
                    end
                end
                if isempty(EEG.icaact) || (size(EEG.icaact,1) ~= size(EEG.icaweights,1)) || (size(EEG.icaact,2) ~= size(EEG.data,2))
                    EEG.icaweights = double(EEG.icaweights);
                    EEG.icawinv = double(EEG.icawinv);
                    
                    % scale ICA components to RMS microvolt
                    if option_scaleicarms
                        if ~isempty(EEG.icawinv)
                            if mean(mean(abs(pinv(EEG.icaweights * EEG.icasphere)-EEG.icawinv))) < 0.0001
                                %disp('Scaling components to RMS
                                %microvolt');
                                scaling = repmat(sqrt(mean(EEG(1).icawinv(:,:).^2))', [1 size(EEG.icaweights,2)]);
                                EEG.etc.icaweights_beforerms = EEG.icaweights;
                                EEG.etc.icasphere_beforerms = EEG.icasphere;
                                
                                EEG.icaweights = EEG.icaweights .* scaling;
                                EEG.icawinv = pinv(EEG.icaweights * EEG.icasphere);
                            end
                        end
                    end
                    
                    if ~isempty(EEG.data) && option_computeica
                        fprintf('eeg_checkset: recomputing the ICA activation matrix ...\n');
                        res = com;
                        % Make compatible with Matlab 7
                        if any(isnan(EEG.data(:)))
                            tmpdata = EEG.data(EEG.icachansind,:);
                            fprintf('eeg_checkset: recomputing ICA ignoring NaN indices ...\n');
                            tmpindices = find(~sum(isnan(tmpdata))); % was: tmpindices = find(~isnan(EEG.data(1,:)));
                            EEG.icaact = zeros(size(EEG.icaweights,1), size(tmpdata,2)); EEG.icaact(:) = NaN;
                            EEG.icaact(:,tmpindices) = (EEG.icaweights*EEG.icasphere)*tmpdata(:,tmpindices);
                        else
                            EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:); % automatically does single or double
                        end
                        EEG.icaact    = reshape( EEG.icaact, size(EEG.icaact,1), EEG.pnts, EEG.trials);
                    end
                end
            end
            if isempty(EEG.icawinv)
                EEG.icawinv = pinv(EEG.icaweights*EEG.icasphere); % a priori same result as inv
                res         = com;
            end
        else
            disp( [ 'eeg_checkset warning: weights matrix cannot be empty if sphere matrix is not, correcting ...' ]);
            res = com;
            EEG.icasphere = [];
        end
        if option_computeica
            if ~isempty(EEG.icaact) && ndims(EEG.icaact) < 3 && (EEG.trials > 1)
                disp( [ 'eeg_checkset note: independent component made 3-D' ]);
                res = com;
                EEG.icaact = reshape(EEG.icaact, size(EEG.icaact,1), EEG.pnts, EEG.trials);
            end
        else
            if ~isempty(EEG.icaact)
                fprintf('eeg_checkset: removing ICA activation matrix (as per edit options) ...\n');
            end
            EEG.icaact     = [];
        end
    else
        if ~isempty( EEG.icaweights ), EEG.icaweights = []; res = com; end
        if ~isempty( EEG.icawinv ),    EEG.icawinv = []; res = com; end
        if ~isempty( EEG.icaact ),     EEG.icaact = []; res = com; end
    end
    if isempty(EEG.icaact)
        EEG.icaact = [];
    end
    
    % ------------- check chanlocs -------------
    if ~isfield(EEG, 'chaninfo')
        EEG.chaninfo = [];
    end
    if ~isempty( EEG.chanlocs )
        
        % reference (use EEG structure) ---------
        if ~isfield(EEG, 'ref'), EEG.ref = ''; end
        if strcmpi(EEG.ref, 'averef')
            ref = 'average';
        else ref = '';
        end
        if ~isfield( EEG.chanlocs, 'ref')
            EEG.chanlocs(1).ref = ref;
        end
        charrefs = cellfun('isclass',{EEG.chanlocs.ref},'char');
        if any(charrefs) ref = ''; end
        for tmpind = find(~charrefs)
            EEG.chanlocs(tmpind).ref = ref;
        end
        if ~isstruct( EEG.chanlocs)
            if exist( EEG.chanlocs ) ~= 2
                disp( [ 'eeg_checkset warning: channel file does not exist or is not in Matlab path: filename removed from EEG struct' ]);
                EEG.chanlocs = [];
                res = com;
            else
                res = com;
                try, EEG.chanlocs = readlocs( EEG.chanlocs );
                    disp( [ 'eeg_checkset: channel file read' ]);
                catch, EEG.chanlocs = []; end
            end
        else
            if ~isfield(EEG.chanlocs,'labels')
                disp('eeg_checkset warning: no field label in channel location structure, removing it');
                EEG.chanlocs = [];
                res = com;
            end
        end
        if isstruct( EEG.chanlocs)
            if length( EEG.chanlocs) ~= EEG.nbchan && length( EEG.chanlocs) ~= EEG.nbchan+1 && ~isempty(EEG.data)
                disp( [ 'eeg_checkset warning: number of channels different in data and channel file/struct: channel file/struct removed' ]);
                EEG.chanlocs = [];
                res = com;
            end
        end
        
        % force Nosedir to +X (done here because of DIPFIT)
        % -------------------
        if isfield(EEG.chaninfo, 'nosedir')
            if ~strcmpi(EEG.chaninfo.nosedir, '+x') && all(isfield(EEG.chanlocs,{'X','Y','theta','sph_theta'}))
                disp(['Note for expert users: Nose direction is now set from ''' upper(EEG.chaninfo.nosedir)  ''' to default +X in EEG.chanlocs']);
                [tmp chaninfo chans] = eeg_checkchanlocs(EEG.chanlocs, EEG.chaninfo); % Merge all channels for rotation (FID and data channels)
                if strcmpi(chaninfo.nosedir, '+y')
                    rotate = 270;
                elseif strcmpi(chaninfo.nosedir, '-x')
                    rotate = 180;
                else
                    rotate = 90;
                end
                for index = 1:length(chans)
                    rotategrad = rotate/180*pi;
                    coord = (chans(index).Y + chans(index).X*sqrt(-1))*exp(sqrt(-1)*-rotategrad);
                    chans(index).Y = real(coord);
                    chans(index).X = imag(coord);
                    
                    if ~isempty(chans(index).theta)
                        chans(index).theta     = chans(index).theta    -rotate;
                        chans(index).sph_theta = chans(index).sph_theta+rotate;
                        if chans(index).theta    <-180, chans(index).theta    =chans(index).theta    +360; end
                        if chans(index).sph_theta>180 , chans(index).sph_theta=chans(index).sph_theta-360; end
                    end
                end
                
                if isfield(EEG, 'dipfit')
                    if isfield(EEG.dipfit, 'coord_transform')
                        if isempty(EEG.dipfit.coord_transform)
                            EEG.dipfit.coord_transform = [0 0 0 0 0 0 1 1 1];
                        end
                        EEG.dipfit.coord_transform(6) = EEG.dipfit.coord_transform(6)+rotategrad;
                    end
                end
                
                chaninfo.nosedir = '+X';
                [EEG.chanlocs EEG.chaninfo] = eeg_checkchanlocs(chans, chaninfo); % Update FID in chaninfo and remove them from chanlocs
            end;
        end
        
        % general checking of channels ----------------------------
        EEG = eeg_checkchanlocs(EEG);
        if EEG.nbchan ~= length(EEG.chanlocs)
            EEG.chanlocs = [];
            EEG.chaninfo = [];
            disp('Warning: the size of the channel location structure does not match with');
            disp('         number of channels. Channel information have been removed.');
        end
    end
    EEG.chaninfo.icachansind = EEG.icachansind; % just a copy for programming convinience
    
    %if ~isfield(EEG, 'urchanlocs')
    %    EEG.urchanlocs = EEG.chanlocs; for index = 1:length(EEG.chanlocs)
    %        EEG.chanlocs(index).urchan = index;
    %    end disp('eeg_checkset note: creating backup chanlocs structure
    %    (urchanlocs)');
    %end
    
    % Field 'datachan in 'urchanlocs' is removed, if exist
    if isfield(EEG, 'urchanlocs') && ~isempty(EEG.urchanlocs) && isfield(EEG.urchanlocs, 'datachan')
        EEG.urchanlocs = rmfield(EEG.urchanlocs, 'datachan');
    end
    
    % check reference ---------------
    if ~isfield(EEG, 'ref')
        EEG.ref = 'common';
    end
    if ischar(EEG.ref) && strcmpi(EEG.ref, 'common')
        if length(EEG.chanlocs) > EEG.nbchan
            disp('Extra common reference electrode location detected');
            EEG.ref = EEG.nbchan+1;
        end
    end
    
    % DIPFIT structure ----------------
    if ~isfield(EEG,'dipfit') || isempty(EEG.dipfit)
        EEG.dipfit = []; res = com;
    else
        try
            % check if dipfitdefs is present
            dipfitdefs;
            if isfield(EEG.dipfit, 'vol') && ~isfield(EEG.dipfit, 'hdmfile')
                if exist('pop_dipfit_settings')
                    disp('Old DIPFIT structure detected: converting to DIPFIT 2 format');
                    EEG.dipfit.hdmfile     = template_models(1).hdmfile;
                    EEG.dipfit.coordformat = template_models(1).coordformat;
                    EEG.dipfit.mrifile     = template_models(1).mrifile;
                    EEG.dipfit.chanfile    = template_models(1).chanfile;
                    EEG.dipfit.coord_transform = [];
                    EEG.saved = 'no';
                    res = com;
                end
            end
            if isfield(EEG.dipfit, 'hdmfile')
                if length(EEG.dipfit.hdmfile) > 8
                    if strcmpi(EEG.dipfit.hdmfile(end-8), template_models(1).hdmfile(end-8)), EEG.dipfit.hdmfile = template_models(1).hdmfile; end
                    if strcmpi(EEG.dipfit.hdmfile(end-8), template_models(2).hdmfile(end-8)), EEG.dipfit.hdmfile = template_models(2).hdmfile; end
                end
                if length(EEG.dipfit.mrifile) > 8
                    if strcmpi(EEG.dipfit.mrifile(end-8), template_models(1).mrifile(end-8)), EEG.dipfit.mrifile = template_models(1).mrifile; end
                    if strcmpi(EEG.dipfit.mrifile(end-8), template_models(2).mrifile(end-8)), EEG.dipfit.mrifile = template_models(2).mrifile; end
                end
                if length(EEG.dipfit.chanfile) > 8
                    if strcmpi(EEG.dipfit.chanfile(end-8), template_models(1).chanfile(end-8)), EEG.dipfit.chanfile = template_models(1).chanfile; end
                    if strcmpi(EEG.dipfit.chanfile(end-8), template_models(2).chanfile(end-8)), EEG.dipfit.chanfile = template_models(2).chanfile; end
                end
            end
            
            if isfield(EEG.dipfit, 'coord_transform')
                if isempty(EEG.dipfit.coord_transform)
                    EEG.dipfit.coord_transform = [0 0 0 0 0 0 1 1 1];
                end
            elseif ~isempty(EEG.dipfit)
                EEG.dipfit.coord_transform = [0 0 0 0 0 0 1 1 1];
            end
        catch
            e = lasterror;
            if ~strcmp(e.identifier,'MATLAB:UndefinedFunction')
                % if we got some error aside from dipfitdefs not being
                % present, rethrow it
                rethrow(e);
            end
        end
    end
    
    % check events (fast) ------------
    if isfield(EEG.event, 'type')
        tmpevent = EEG.event(1:min(length(EEG.event), 100));
        if ~all(cellfun(@ischar, { tmpevent.type })) && ~all(cellfun(@isnumeric, { tmpevent.type }))
            disp('Warning: converting all event types to strings');
            for ind = 1:length(EEG.event)
                EEG.event(ind).type = num2str(EEG.event(ind).type);
            end
            EEG = eeg_checksetMG(EEG, 'eventconsistency');
        end
    end
    
    % EEG.times (only for epoched datasets) ---------
    if ~isfield(EEG, 'times') || isempty(EEG.times) || length(EEG.times) ~= EEG.pnts
        EEG.times = linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts);
    end
    
    if ~isfield(EEG, 'history')    EEG.history    = ''; res = com; end
    if ~isfield(EEG, 'splinefile') EEG.splinefile = ''; res = com; end
    if ~isfield(EEG, 'icasplinefile') EEG.icasplinefile = ''; res = com; end
    if ~isfield(EEG, 'saved')      EEG.saved      = 'no'; res = com; end
    if ~isfield(EEG, 'subject')    EEG.subject    = ''; res = com; end
    if ~isfield(EEG, 'condition')  EEG.condition  = ''; res = com; end
    if ~isfield(EEG, 'group')      EEG.group      = ''; res = com; end
    if ~isfield(EEG, 'session')    EEG.session    = []; res = com; end
    if ~isfield(EEG, 'urchanlocs') EEG.urchanlocs = []; res = com; end
    if ~isfield(EEG, 'specdata')   EEG.specdata   = []; res = com; end
    if ~isfield(EEG, 'specicaact') EEG.specicaact = []; res = com; end
    if ~isfield(EEG, 'comments')   EEG.comments   = ''; res = com; end
    if ~isfield(EEG, 'etc'     )   EEG.etc        = []; res = com; end
    if ~isfield(EEG, 'urevent' )   EEG.urevent    = []; res = com; end
    if ~isfield(EEG, 'ref') || isempty(EEG.ref) EEG.ref = 'common'; res = com; end
    
    % create fields if absent -----------------------
    if ~isfield(EEG, 'reject')                    EEG.reject.rejjp = []; res = com; end
    
    listf = { 'rejjp' 'rejkurt' 'rejmanual' 'rejthresh' 'rejconst', 'rejfreq' ...
        'icarejjp' 'icarejkurt' 'icarejmanual' 'icarejthresh' 'icarejconst', 'icarejfreq'};
    for index = 1:length(listf)
        name = listf{index};
        elecfield = [name 'E'];
        if ~isfield(EEG.reject, elecfield),     EEG.reject.(elecfield) = []; res = com; end
        if ~isfield(EEG.reject, name)
            EEG.reject.(name) = [];
            res = com;
        elseif ~isempty(EEG.reject.(name)) && isempty(EEG.reject.(elecfield))
            % check if electrode array is empty with rejection array is not
            nbchan = fastif(strcmp(name, 'ica'), size(EEG.icaweights,1), EEG.nbchan);
            EEG.reject = setfield(EEG.reject, elecfield, zeros(nbchan, length(getfield(EEG.reject, name)))); res = com;
        end
    end
    if ~isfield(EEG.reject, 'rejglobal')        EEG.reject.rejglobal  = []; res = com; end
    if ~isfield(EEG.reject, 'rejglobalE')       EEG.reject.rejglobalE = []; res = com; end
    
    % track version of EEGLAB -----------------------
    tmpvers = eeg_getversion;
    if ~isfield(EEG.etc, 'eeglabvers') || ~isequal(EEG.etc.eeglabvers, tmpvers)
        EEG.etc.eeglabvers = tmpvers;
        EEG = eeg_hist( EEG, ['EEG.etc.eeglabvers = ''' tmpvers '''; % this tracks which version of EEGLAB is being used, you may ignore it'] );
        res = com;
    end
    
    % default colors for rejection ----------------------------
    if ~isfield(EEG.reject, 'rejmanualcol')   EEG.reject.rejmanualcol = [1.0000    1     0.783]; res = com; end
    if ~isfield(EEG.reject, 'rejthreshcol')   EEG.reject.rejthreshcol = [0.8487    1.0000    0.5008]; res = com; end
    if ~isfield(EEG.reject, 'rejconstcol')    EEG.reject.rejconstcol  = [0.6940    1.0000    0.7008]; res = com; end
    if ~isfield(EEG.reject, 'rejjpcol')       EEG.reject.rejjpcol     = [1.0000    0.6991    0.7537]; res = com; end
    if ~isfield(EEG.reject, 'rejkurtcol')     EEG.reject.rejkurtcol   = [0.6880    0.7042    1.0000]; res = com; end
    if ~isfield(EEG.reject, 'rejfreqcol')     EEG.reject.rejfreqcol   = [0.9596    0.7193    1.0000]; res = com; end
    if ~isfield(EEG.reject, 'disprej')        EEG.reject.disprej      = { }; end
    
    if ~isfield(EEG, 'stats')           EEG.stats.jp = []; res = com; end
    if ~isfield(EEG.stats, 'jp')        EEG.stats.jp = []; res = com; end
    if ~isfield(EEG.stats, 'jpE')       EEG.stats.jpE = []; res = com; end
    if ~isfield(EEG.stats, 'icajp')     EEG.stats.icajp = []; res = com; end
    if ~isfield(EEG.stats, 'icajpE')    EEG.stats.icajpE = []; res = com; end
    if ~isfield(EEG.stats, 'kurt')      EEG.stats.kurt = []; res = com; end
    if ~isfield(EEG.stats, 'kurtE')     EEG.stats.kurtE = []; res = com; end
    if ~isfield(EEG.stats, 'icakurt')   EEG.stats.icakurt = []; res = com; end
    if ~isfield(EEG.stats, 'icakurtE')  EEG.stats.icakurtE = []; res = com; end
    
    % component rejection -------------------
    if ~isfield(EEG.stats, 'compenta')        EEG.stats.compenta = []; res = com; end
    if ~isfield(EEG.stats, 'compentr')        EEG.stats.compentr = []; res = com; end
    if ~isfield(EEG.stats, 'compkurta')       EEG.stats.compkurta = []; res = com; end
    if ~isfield(EEG.stats, 'compkurtr')       EEG.stats.compkurtr = []; res = com; end
    if ~isfield(EEG.stats, 'compkurtdist')    EEG.stats.compkurtdist = []; res = com; end
    if ~isfield(EEG.reject, 'threshold')      EEG.reject.threshold = [0.8 0.8 0.8]; res = com; end
    if ~isfield(EEG.reject, 'threshentropy')  EEG.reject.threshentropy = 600; res = com; end
    if ~isfield(EEG.reject, 'threshkurtact')  EEG.reject.threshkurtact = 600; res = com; end
    if ~isfield(EEG.reject, 'threshkurtdist') EEG.reject.threshkurtdist = 600; res = com; end
    if ~isfield(EEG.reject, 'gcompreject')    EEG.reject.gcompreject = []; res = com; end
    if length(EEG.reject.gcompreject) ~= size(EEG.icaweights,1)
        EEG.reject.gcompreject = zeros(1, size(EEG.icaweights,1));
    end
    
    % remove old fields -----------------
    if isfield(EEG, 'averef'), EEG = rmfield(EEG, 'averef'); end
    if isfield(EEG, 'rt'    ), EEG = rmfield(EEG, 'rt');     end
    
    % store in new structure ----------------------
    if isstruct(EEG)
        if ~exist('ALLEEGNEW','var')
            ALLEEGNEW = EEG;
        else
            ALLEEGNEW(inddataset) = EEG;
        end
    end
end

% recorder fields ---------------
fieldorder = { 'setname' ...
    'filename' ...
    'filepath' ...
    'subject' ...
    'group' ...
    'condition' ...
    'session' ...
    'comments' ...
    'nbchan' ...
    'trials' ...
    'pnts' ...
    'srate' ...
    'xmin' ...
    'xmax' ...
    'times' ...
    'data' ...
    'icaact' ...
    'icawinv' ...
    'icasphere' ...
    'icaweights' ...
    'icachansind' ...
    'chanlocs' ...
    'urchanlocs' ...
    'chaninfo' ...
    'ref' ...
    'event' ...
    'urevent' ...
    'eventdescription' ...
    'epoch' ...
    'epochdescription' ...
    'reject' ...
    'stats' ...
    'specdata' ...
    'specicaact' ...
    'splinefile' ...
    'icasplinefile' ...
    'dipfit' ...
    'history' ...
    'saved' ...
    'etc' };

for fcell = fieldnames(EEG)'
    fname = fcell{1};
    if ~any(strcmp(fieldorder,fname))
        fieldorder{end+1} = fname;
    end
end

try
    ALLEEGNEW = orderfields(ALLEEGNEW, fieldorder);
    EEG = ALLEEGNEW;
catch
    disp('Couldn''t order data set fields properly.');
end

if exist('ALLEEGNEW','var')
    EEG = ALLEEGNEW;
end

if ~isa(EEG, 'eegobj') && option_eegobject
    EEG = eegobj(EEG);
end

return;

function num = popask( text )
ButtonName=questdlg2( text, ...
    'Confirmation', 'Cancel', 'Yes','Yes');
switch lower(ButtonName),
    case 'cancel', num = 0;
    case 'yes',    num = 1;
end

function res = mycellfun(com, vals, classtype);
res = zeros(1, length(vals));
switch com
    case 'isempty',
        for index = 1:length(vals), res(index) = isempty(vals{index}); end
    case 'isclass'
        if strcmp(classtype, 'double')
            for index = 1:length(vals), res(index) = isnumeric(vals{index}); end
        else
            error('unknown cellfun command');
        end
    otherwise error('unknown cellfun command');
end




function [EEG, com, b] = pop_eegfiltnew(EEG, varargin)

com = '';

if nargin < 1
    help pop_eegfiltnew;
    return
end
if isempty(EEG(1).data)
    error('Cannot filter empty dataset.');
end

% GUI
if nargin < 2
    
    geometry = {[3, 1], [3, 1], [3, 1], 1, 1, 1, 1 [2 1.5 0.5] [2 1.5 0.5]  };
    geomvert = [1 1 1 2 1 1 1 1 1];
    
    cb_type = 'pop_chansel(get(gcbf, ''userdata''), ''field'', ''type'',   ''handle'', findobj(''parent'', gcbf, ''tag'', ''chantypes''));';
    cb_chan = 'pop_chansel(get(gcbf, ''userdata''), ''field'', ''labels'', ''handle'', findobj(''parent'', gcbf, ''tag'', ''channels''));';
    
    uilist = {{'style', 'text', 'string', 'Lower edge of the frequency pass band (Hz)'} ...
        {'style', 'edit', 'string', ''} ...
        {'style', 'text', 'string', 'Higher edge of the frequency pass band (Hz)'} ...
        {'style', 'edit', 'string', ''} ...
        {'style', 'text', 'string', 'FIR Filter order (Mandatory even. Default is automatic*)'} ...
        {'style', 'edit', 'string', ''} ...
        {'style', 'text', 'string', {'*See help text for a description of the default filter order heuristic.', 'Manual definition is recommended.'}} ...
        {'style', 'checkbox', 'string', 'Notch filter the data instead of pass band', 'value', 0} ...
        {'Style', 'checkbox', 'String', 'Use minimum-phase converted causal filter (non-linear!; beta)', 'Value', 0} ...
        {'style', 'checkbox', 'string', 'Plot frequency response', 'value', 1} ...
        { 'style' 'text'       'string' 'Channel type(s)' } ...
        { 'style' 'edit'       'string' '' 'tag' 'chantypes'}  ...
        { 'style' 'pushbutton' 'string' '...'  'callback' cb_type } ...
        { 'style' 'text'       'string' 'OR channel labels or indices' } ...
        { 'style' 'edit'       'string' '' 'tag' 'channels' }  ...
        { 'style' 'pushbutton' 'string' '...' 'callback' cb_chan }
        };
    
    % channel labels --------------
    if ~isempty(EEG(1).chanlocs)
        tmpchanlocs = EEG(1).chanlocs;
    else
        tmpchanlocs = [];
        for index = 1:EEG(1).nbchan
            tmpchanlocs(index).labels = int2str(index);
            tmpchanlocs(index).type = '';
        end
    end
    
    result = inputgui('geometry', geometry, 'geomvert', geomvert, 'uilist', uilist, 'title', 'Filter the data -- pop_eegfiltnew()', 'helpcom', 'pophelp(''pop_eegfiltnew'')', 'userdata', tmpchanlocs);
    
    if isempty(result), return; end
    options = {};
    if ~isempty(result{1}), options = { options{:} 'locutoff' str2num( result{1}) }; end
    if ~isempty(result{2}), options = { options{:} 'hicutoff' str2num( result{2}) }; end
    if ~isempty(result{3}), options = { options{:} 'filtorder' result{3} }; end
    if result{4}, options = { options{:} 'revfilt' result{4} }; end
    if result{5}, options = { options{:} 'minphase' result{5} }; end
    if result{6}, options = { options{:} 'plotfreqz' result{6} }; end
    if ~isempty(result{7} ), options = { options{:} 'chantype' parsetxt(result{7}) }; end
    if ~isempty(result{8}) && isempty( result{7} )
        [ chaninds, chanlist ] = eeg_decodechan(EEG(1).chanlocs, result{8});
        if isempty(chanlist), chanlist = chaninds; end
        options = { options{:}, 'channels' chanlist };
    end
elseif ~ischar(varargin{1})
    % backward compatibility
    options = {};
    if nargin > 1, options = { options{:} 'locutoff'  varargin{1} }; end
    if nargin > 2, options = { options{:} 'hicutoff'  varargin{2} }; end
    if nargin > 3, options = { options{:} 'filtorder' varargin{3} }; end
    if nargin > 4, options = { options{:} 'revfilt'   varargin{4} }; end
    if nargin > 5, options = { options{:} 'usefft'    varargin{5} }; end
    if nargin > 6, options = { options{:} 'plotfreqz' varargin{6} }; end
    if nargin > 7, options = { options{:} 'minphase'  varargin{7} }; end
    if nargin > 8, options = { options{:} 'usefftfilt' varargin{8} }; end
    
    if nargin < 5 || isempty(revfilt)
        revfilt = 0;
    end
    if nargin < 6
        usefft = [];
    elseif usefft == 1
        error('FFT filtering not supported. Argument is provided for backward compatibility in command line mode only.')
    end
    if nargin < 7 || isempty(plotfreqz)
        plotfreqz = 0;
    end
    if nargin < 8 || isempty(minphase)
        minphase = 0;
    end
    if nargin < 9 || isempty(usefftfilt)
        usefftfilt = 0;
    end
    
else
    options = varargin;
end

% process multiple datasets -------------------------
if length(EEG) > 1
    if nargin < 2
        [ EEG, com ] = eeg_eval( 'pop_eegfiltnew', EEG, 'warning', 'on', 'params', options );
    else
        [ EEG, com ] = eeg_eval( 'pop_eegfiltnew', EEG, 'params', options );
    end
    return;
end

% decode inputs -------------
fieldlist = { 'locutoff'           'real'       []            [];
    'hicutoff'           'real'       []            [];
    'filtorder'          'integer'    []            [];
    'revfilt'            'integer'    [0 1]         0;
    'usefft'             'integer'    [0 1]         0;
    'usefftfilt'         'integer'    [0 1]         0;
    'minphase'           'integer'    [0 1]         0;
    'plotfreqz'          'integer'    [0 1]         0;
    'channels'      {'cell' 'string' 'integer' } []                {};
    'chantype'      {'cell' 'string'} []                {}  };
g = finputcheck( options, fieldlist, 'pop_eegfiltnew');
if ischar(g), error(g); end
if isempty(g.minphase), g.minphase = 0; end
if ~isempty(g.chantype)
    g.channels = eeg_decodechan(EEG.chanlocs, g.chantype, 'type');
elseif ~isempty(g.channels)
    g.channels = eeg_decodechan(EEG.chanlocs, g.channels);
else
    g.channels = [1:EEG.nbchan];
end
if g.usefft
    error('FFT filtering not supported. Argument is provided for backward compatibility in command line mode only.')
end

% Constants
TRANSWIDTHRATIO = 0.25;
fNyquist = EEG.srate / 2;

% Check arguments
if g.locutoff == 0, g.locutoff = []; end
if g.hicutoff == 0, g.hicutoff = []; end
if isempty(g.hicutoff) % Convert highpass to inverted lowpass
    g.hicutoff = g.locutoff;
    g.locutoff = [];
    g.revfilt = ~g.revfilt;
end
edgeArray = sort([g.locutoff g.hicutoff]);

if isempty(edgeArray)
    error('Not enough input arguments.');
end
if any(edgeArray < 0 | edgeArray >= fNyquist)
    error('Cutoff frequency out of range');
end

if ~isempty(g.filtorder) && (g.filtorder < 2 || mod(g.filtorder, 2) ~= 0)
    error('Filter order must be a real, even, positive integer.')
end

% Max stop-band width
maxTBWArray = edgeArray; % Band-/highpass
if g.revfilt == 0 % Band-/lowpass
    maxTBWArray(end) = fNyquist - edgeArray(end);
elseif length(edgeArray) == 2 % Bandstop
    maxTBWArray = diff(edgeArray) / 2;
end
maxDf = min(maxTBWArray);

% Transition band width and filter order
if isempty(g.filtorder)
    
    % Default filter order heuristic
    if g.revfilt == 1 % Highpass and bandstop
        df = min([max([maxDf * TRANSWIDTHRATIO 2]) maxDf]);
    else % Lowpass and bandpass
        df = min([max([edgeArray(1) * TRANSWIDTHRATIO 2]) maxDf]);
    end
    
    g.filtorder = 3.3 / (df / EEG.srate); % Hamming window
    g.filtorder = ceil(g.filtorder / 2) * 2; % Filter order must be even.
    
else
    
    df = 3.3 / g.filtorder * EEG.srate; % Hamming window
    g.filtorderMin = ceil(3.3 ./ ((maxDf * 2) / EEG.srate) / 2) * 2;
    g.filtorderOpt = ceil(3.3 ./ (maxDf / EEG.srate) / 2) * 2;
    if g.filtorder < g.filtorderMin
        error('Filter order too low. Minimum required filter order is %d. For better results a minimum filter order of %d is recommended.', g.filtorderMin, g.filtorderOpt)
    elseif g.filtorder < g.filtorderOpt
        warning('firfilt:filterOrderLow', 'Transition band is wider than maximum stop-band width. For better results a minimum filter order of %d is recommended. Reported might deviate from effective -6dB cutoff frequency.', g.filtorderOpt)
    end
    
end

filterTypeArray = {'lowpass', 'bandpass'; 'highpass', 'bandstop (notch)'};
% fprintf('pop_eegfiltnew() - performing %d point %s filtering.\n',
% g.filtorder + 1, filterTypeArray{g.revfilt + 1, length(edgeArray)})
% fprintf('pop_eegfiltnew() - transition band width: %.4g Hz\n', df)
% fprintf('pop_eegfiltnew() - passband edge(s): %s Hz\n',
% mat2str(edgeArray))

% Passband edge to cutoff (transition band center; -6 dB)
dfArray = {df, [-df, df]; -df, [df, -df]};
cutoffArray = edgeArray + dfArray{g.revfilt + 1, length(edgeArray)} / 2;
% fprintf('pop_eegfiltnew() - cutoff frequency(ies) (-6 dB): %s Hz\n',
% mat2str(cutoffArray))

% Window
winArray = windows('hamming', g.filtorder + 1);

% Filter coefficients
if g.revfilt == 1
    filterTypeArray = {'high', 'stop'};
    b = firws(g.filtorder, cutoffArray / fNyquist, filterTypeArray{length(cutoffArray)}, winArray);
else
    b = firws(g.filtorder, cutoffArray / fNyquist, winArray);
end

if g.minphase
    disp('pop_eegfiltnew() - converting filter to minimum-phase (non-linear!)');
    b = minphaserceps(b);
    causal = 1;
    dir = '(causal)';
else
    causal = 0;
    dir = '(zero-phase, non-causal)';
end

% Plot frequency response
if g.plotfreqz
    try
        freqz(b, 1, 8192, EEG.srate);
    catch
        warning( 'Plotting of frequency response requires signal processing toolbox.' )
    end
end

% Filter
if g.minphase || g.usefftfilt
    disp(['pop_eegfiltnew() - filtering the data ' dir]);
    EEG = firfiltsplit(EEG, b, causal, g.usefftfilt, g.channels);
else
    %     disp(['pop_eegfiltnew() - filtering the data ' dir]);
    EEG = firfilt(EEG, b, [], g.channels);
end

% History string
com = sprintf('EEG = pop_eegfiltnew(EEG, %s);', vararg2str(options));


function EEG = firfilt(EEG, b, nFrames, chaninds)

if nargin < 2
    error('Not enough input arguments.');
end
if nargin < 3 || isempty(nFrames)
    nFrames = 1000;
end
if nargin < 4
    chaninds = 1:size(EEG.data,1);
end

% Filter's group delay
if mod(length(b), 2) ~= 1
    error('Filter order is not even.');
end
groupDelay = (length(b) - 1) / 2;

% Find data discontinuities and reshape epoched data
if EEG.trials > 1 % Epoched data
    EEG.data = reshape(EEG.data, [EEG.nbchan EEG.pnts * EEG.trials]);
    dcArray = 1 : EEG.pnts : EEG.pnts * (EEG.trials + 1);
else % Continuous data
    dcArray = [findboundaries(EEG.event) EEG.pnts + 1];
end

% Initialize progress indicator
nSteps = 20;
step = 0;
% fprintf(1, 'firfilt(): |');
strLength = fprintf(1, [repmat(' ', 1, nSteps - step) '|   0%%']);
tic

for iDc = 1:(length(dcArray) - 1)
    
    % Pad beginning of data with DC constant and get initial conditions
    ziDataDur = min(groupDelay, dcArray(iDc + 1) - dcArray(iDc));
    [temp, zi] = filter(b, 1, double([EEG.data(chaninds, ones(1, groupDelay) * dcArray(iDc)) ...
        EEG.data(chaninds, dcArray(iDc):(dcArray(iDc) + ziDataDur - 1))]), [], 2);
    
    blockArray = [(dcArray(iDc) + groupDelay):nFrames:(dcArray(iDc + 1) - 1) dcArray(iDc + 1)];
    for iBlock = 1:(length(blockArray) - 1)
        
        % Filter the data
        [EEG.data(chaninds, (blockArray(iBlock) - groupDelay):(blockArray(iBlock + 1) - groupDelay - 1)), zi] = ...
            filter(b, 1, double(EEG.data(chaninds, blockArray(iBlock):(blockArray(iBlock + 1) - 1))), zi, 2);
        
        % Update progress indicator
        [step, strLength] = mywaitbar((blockArray(iBlock + 1) - groupDelay - 1), size(EEG.data, 2), step, nSteps, strLength);
    end
    
    % Pad end of data with DC constant
    temp = filter(b, 1, double(EEG.data(chaninds, ones(1, groupDelay) * (dcArray(iDc + 1) - 1))), zi, 2);
    EEG.data(chaninds, (dcArray(iDc + 1) - ziDataDur):(dcArray(iDc + 1) - 1)) = ...
        temp(:, (end - ziDataDur + 1):end);
    
    % Update progress indicator
    [step, strLength] = mywaitbar((dcArray(iDc + 1) - 1), size(EEG.data, 2), step, nSteps, strLength);
    
end

% Reshape epoched data
if EEG.trials > 1
    EEG.data = reshape(EEG.data, [EEG.nbchan EEG.pnts EEG.trials]);
end

% Deinitialize progress indicator
fprintf(1, '\n')



function [step, strLength] = mywaitbar(compl, total, step, nSteps, strLength)

progStrArray = '/-\|';
tmp = floor(compl / total * nSteps);
if tmp > step
    fprintf(1, [repmat('\b', 1, strLength) '%s'], repmat('=', 1, tmp - step))
    step = tmp;
    ete = ceil(toc / step * (nSteps - step));
    % strLength = fprintf(1, [repmat(' ', 1, nSteps - step) '%s %3d%%, ETE
    % %02d:%02d'], progStrArray(mod(step - 1, 4) + 1), floor(step * 100 /
    % nSteps), floor(ete / 60), mod(ete, 60));
end






