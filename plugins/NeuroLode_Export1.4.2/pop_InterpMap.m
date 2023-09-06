function [EEG] = pop_InterpMap(EEG,ChanListNum2,ChanListLab2,currentPos,MoveValue,Run)

%     'AA = get(gca,''Parent'');AB = get(AA,''userdata'');ChanListNum2 = AB.ImapchansNL;ChanListLab2 = AB.chanlocsNL;pop_InterpMap(EEG,ChanListNum2,ChanListLab2,currentPos,1,1);'
%            { 'Style', 'pushbutton', 'string', '>',  'callback', [ 'pop_InterpMap(EEG,ChanListNum2,ChanListLab2,currentPos,1,1);'  ] } ...
if Run == 0
    Ti = sprintf('Channel Interpolation Maps');
    ButtonSection = {...
        { 'Style', 'text', 'string', ''} ...
        { 'Style', 'text', 'string', ''} ...
        { 'Style', 'pushbutton', 'string', '<',  'callback', ['AA = get(gca,''Parent'');AB = get(AA,''userdata'');ChanListNum2 = AB.ImapchansNL;ChanListLab2 = AB.chanlocsNL;pop_InterpMap(EEG,ChanListNum2,ChanListLab2,currentPos,-1,1);' ] } ...
        { 'Style', 'edit'      , 'string', num2str(currentPos),'tag','CurChanEditNum','Value',currentPos, 'callback', ['currentPos = get(findobj(AA, ''tag'', ''CurChanEditNum''),''Value''); pop_InterpMap(EEG,ChanListNum2,ChanListLab2,currentPos,0,2);'] } ...
        { 'Style', 'pushbutton', 'string', '>',  'callback', [    'AA = get(gca,''Parent'');AB = get(AA,''userdata'');ChanListNum2 = AB.ImapchansNL;ChanListLab2 = AB.chanlocsNL;pop_InterpMap(EEG,ChanListNum2,ChanListLab2,currentPos,1,1);'] } ...
        { 'Style', 'text', 'string', ''} ...
        { 'Style', 'text', 'string', ''}, ...
        };
    geometry =  {...
        [ 1 ] ...
        [1.5  1    0.2 3 1]...
        [2    0.35 0.5 3 1]...
        [2    0.35 0.5 3 1]...
        [1]...
        [2    0.35 0.5 3 1]...
        [2    0.35 0.5 3 1]...
        [2    0.35 0.5 3 1]...
        [1]...
        [2    0.35 0.5 3 1]...
        [2    0.35 0.5 3 1]...
        [2    0.35 0.5 3 1]...
        [1]...
        [1]...
        [2    0.35 0.5 3 1]...
        [2    0.35 0.5 3 1]...
        [1]...
        [1]...
        [1]...
        [1]...
        [1]...
        [1]...
        [1]...
        [1]...
        [2 0.7  0.7 1 0.7 0.7 .75] }; %Last line is button line
    uilist   = {....
        { 'Style', 'text', 'string', Ti, 'fontweight', 'bold'  }, ...
        { 'Style', 'text', 'string', 'Blue/Boxed Channels'},{},{},{},{}, ...
        { 'Style', 'text', 'string', 'will be used for'},{},{},{},{}, ...
        { 'Style', 'text', 'string', 'interpolation analysis'},{},{},{},{}, ...
        { }, ...
        { 'Style', 'text', 'string', 'Red/Non-boxed Channels'},{},{},{},{}, ...
        { 'Style', 'text', 'string', 'will not be used for'},{},{},{},{}, ...
        { 'Style', 'text', 'string', 'interpolation analysis'},{},{},{},{}, ...
        { }, ...
        { 'Style', 'text', 'string', 'These maps can be used'},{},{},{},{}, ...
        { 'Style', 'text', 'string', 'later and load into'},{},{},{},{}, ...
        { 'Style', 'text', 'string', 'interpolation analysis'},{},{},{},{}, ...
        { }, ...
        { }, ...
        { 'Style', 'text', 'string', 'Central Channel', 'fontweight', 'bold' },{},{},{},{}, ...
        { 'Style', 'text', 'string', EEG.chanlocs(1,1).labels, 'fontweight', 'bold','tag','CurChanLabel' },{},{},{},{}, ...
        { }, ...
        { }, ...
        { }, ...
        { }, ...
        { }, ...
        { }, ...
        { 'Style', 'text', 'string', strcat('Filename InterpMapUserBased.txt')},...
        { 'Style', 'text', 'string', strcat('File saving to',{' '}, string(pwd))},...
        ButtonSection{:},...
        };
    
    userdata.chansNL    = ChanListNum2;
    userdata.chanlocsNL = EEG.chanlocs;
    userdata.chaninfoNL = EEG.chaninfo;
    userdata.ImapchansNL = ChanListNum2;
    close();
    CC = nonzeros(ChanListNum2(1,:)');
    [results userdata returnmode] = inputguiMG(EEG,CC,'geometry', geometry, 'uilist', uilist, 'helpcom', ...
        'pophelp(''pop_chanedit'');', 'title', 'Edit channel info -- pop_chanedit()', ...
        'userdata', userdata);
    
elseif Run == 1
    AA = get(gca,'Parent');
    AB = get(AA,'userdata');
    AC = get(gca,'Children');
    AD = get(AC,'userdata');
    CL_NL = AB.chanlocsNL;
    CI_NL = AB.chaninfoNL;
    CM_NL = AB.ImapchansNL;
    AD = AD(~cellfun('isempty',AD));
    AD = cellstr(string(flip(AD)));
    Index = find(not(cellfun('isempty',(strfind(AD,':1')))));
    currentPos = get(findobj(AA, 'tag', 'CurChanEditNum'),'string');
    
    if isnan(str2double(currentPos))
        ALcmp = {EEG.chanlocs(1:end).labels}';
        currentPos =  find(strcmpi(ALcmp, currentPos));
    else
        currentPos =str2double(currentPos);
    end
    currentPosO = currentPos;
    currentPos = currentPos + MoveValue;
    
    if currentPos > 0 && currentPos < size(CL_NL,2)+1
        set(findobj(AA, 'tag', 'CurChanEditNum'),'string',currentPos)
        set(findobj(AA, 'tag', 'CurChanLabel'),'string',CL_NL(currentPos).labels)
        set(findobj(AA, 'tag', 'CurChanEditNum'),'Value',currentPos)
        index_of_Channels = nonzeros(AB.ImapchansNL(currentPos,:)');
        cla()
        topoplotMG( index_of_Channels,CL_NL,'chaninfo', CI_NL, ...
            'electrodes','labels','style', 'blank', 'emarkersize1chan', 2);
        
        userdata.chansNL    = ChanListNum2;
        userdata.chanlocsNL = EEG.chanlocs;
        userdata.chaninfoNL = EEG.chaninfo;
        NewLine = [Index',zeros(1,(size(ChanListNum2,2)-size(Index,1)-1))];
        ChanListNum2(currentPosO,2:end) = NewLine;
        userdata.ImapchansNL = ChanListNum2;
    else
        userdata.chansNL    = ChanListNum2;
        userdata.chanlocsNL = EEG.chanlocs;
        userdata.chaninfoNL = EEG.chaninfo;
        userdata.ImapchansNL = ChanListNum2;
    end
    set(get(gca,'Parent'), 'UserData', userdata);
    fileID = fopen('InterpMapUserBased.txt','w');
    PrintTab = ' %.7f \t ';
    for ii=1:size(ChanListNum2,2)-1
        PrintTab = strcat(PrintTab,' %.7f \t ');
    end
    PrintTab = strcat('\n ',PrintTab);
    for iii=1:size(EEG.chanlocs,2)
        fprintf(fileID, PrintTab,...
            ChanListNum2(iii,:));
    end
    fclose( 'all' );% or fclose(fileID);
    
    
elseif Run ==2
    AA = get(gca,'Parent');
    AB = get(AA,'userdata');
    AC = get(gca,'Children');
    AD = get(AC,'userdata');
    CL_NL = AB.chanlocsNL;
    CI_NL = AB.chaninfoNL;
    CM_NL = AB.ImapchansNL;
    AD = AD(~cellfun('isempty',AD));
    AD = cellstr(string(flip(AD)));
    Index = find(not(cellfun('isempty',(strfind(AD,':1')))));
    currentPos = get(findobj(AA, 'tag', 'CurChanEditNum'),'string');
    
    if isnan(str2double(currentPos))
        ALcmp = {EEG.chanlocs(1:end).labels}';
        currentPos =  find(strcmpi(ALcmp, currentPos));
    else
        currentPos =str2double(currentPos);
    end
    if currentPos > 0 && currentPos < size(CL_NL,2)+1
        % CurChan = AB.chansNL(currentPos,1);
        set(findobj(AA, 'tag', 'CurChanEditNum'),'string',currentPos)
        set(findobj(AA, 'tag', 'CurChanLabel'),'string',CL_NL(currentPos).labels)
        set(findobj(AA, 'tag', 'CurChanEditNum'),'Value',currentPos)
        index_of_Channels = nonzeros(AB.ImapchansNL(currentPos,:)');
        cla()
        %         drawnow()
        topoplotMG( index_of_Channels,CL_NL,'chaninfo', CI_NL, ...
            'electrodes','labels','style', 'blank', 'emarkersize1chan', 2);        
        userdata.chansNL    = ChanListNum2;
        userdata.chanlocsNL = EEG.chanlocs;
        userdata.chaninfoNL = EEG.chaninfo;
        NewLine = [Index',zeros(1,(size(ChanListNum2,2)-size(Index,1)-1))];
        ChanListNum2(currentPos,2:end) = NewLine;
        userdata.ImapchansNL = ChanListNum2;
    else
        userdata.chansNL    = ChanListNum2;
        userdata.chanlocsNL = EEG.chanlocs;
        userdata.chaninfoNL = EEG.chaninfo;
        userdata.ImapchansNL = ChanListNum2;
    end
    end
    set(get(gca,'Parent'), 'UserData', userdata);
    fileID = fopen('InterpMapUserBased.txt','w');
    PrintTab = ' %.7f \t ';
    for ii=1:size(ChanListNum2,2)-1
        PrintTab = strcat(PrintTab,' %.7f \t ');
    end
    PrintTab = strcat('\n ',PrintTab);
    for iii=1:size(EEG.chanlocs,2)
        fprintf(fileID, PrintTab,...
            ChanListNum2(iii,:));
    end
    fclose( 'all' );% or fclose(fileID);


%
% function [com] = pop_InterpMapI(EEG,ChanListNum2,ChanListLab2,currentPos,MoveValue,Run)
% global currentPos;
% global CurChan;
% AA = get(gca,'Parent');
% AB = get(AA,'userdata');
% AC = get(gca,'Children');
% AD = get(AC,'userdata');
%
% D = get(AA,'tag');
% CL_NL = AB.chanlocsNL;
% CI_NL = AB.chaninfoNL;
%
% if currentPos > 0 && currentPos < size(CL_NL,2)
%     currentPos = currentPos + MoveValue;
%    % CurChan = AB.chansNL(currentPos,1);
%     index_of_Channels = nonzeros(AB.chansNL(currentPos,:)');
%     cla()
%     drawnow()
%     topoplotMG( index_of_Channels,CL_NL,'chaninfo', CI_NL, ...
%         'electrodes','labels','style', 'blank', 'emarkersize1chan', 2);
% end
%
%
% function [com] = pop_InterpMap1(gca,MoveValue,currentPos)
%
% global currentPos;
% global CurChan;
% AA = get(gca,'Parent');
% AB = get(AA,'userdata');
% AC = get(gca,'Children');
% AD = get(AC,'userdata');
%
% D = get(AA,'tag');
% CL_NL = AB.chanlocsNL;
% CI_NL = AB.chaninfoNL;
%
% if currentPos > 0 && currentPos < size(CL_NL,2)
%     currentPos = currentPos + MoveValue;
%    % CurChan = AB.chansNL(currentPos,1);
%     index_of_Channels = nonzeros(AB.chansNL(currentPos,:)');
%     cla()
%     drawnow()
%     topoplotMG( index_of_Channels,CL_NL,'chaninfo', CI_NL, ...
%         'electrodes','labels','style', 'blank', 'emarkersize1chan', 2);
% end
%
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



