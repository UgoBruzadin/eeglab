% eegplot_w3() - Scroll (horizontally and/or vertically) through multichannel data.
%             Allows vertical scrolling through channels and manual marking 
%             and unmarking of data stretches or epochs for rejection.
%    Almost identical to pop_eegplot(), but allow scroll with mouse wheel, 
%    to remove channels / components (with Shift+click), 
%    looks better in wide-screen monitor and draw EEG data faster.
%
% Usage: 
%           >> eegplot_w3(data, 'key1', value1 ...); % use interface buttons, etc.
%      else
%           >> eegplot_w3('noui', data, 'key1', value1 ...); % no user interface;
%                                                         % use for plotting
% Menu items:
%    "Figure > print" - [menu] Print figure in portrait or landscape.
%    "Figure > Edit figure" - [menu] Remove menus and buttons and call up the standard
%                  Matlab figure menu. Select "Tools > Edit" to format the figure
%                  for publication. Command line equivalent: 'noui' 
%    "Figure > Accept and Close" - [menu] Same as the bottom-right "Reject" button. 
%    "Figure > Cancel and Close" - [menu] Cancel all editing, same as the "Cancel" button. 
%    "Display > Marking color" > [Hide|Show] marks" - [menu] Show or hide patches of 
%                  background color behind the data. Mark stretches of *continuous* 
%                  data (e.g., for rejection) by dragging the mouse horizontally 
%                  over the activity. With *epoched* data, click on the selected epochs.
%                  Clicked on a marked region to unmark it. Called from the
%                  command line, marked data stretches or epochs are returned in 
%                  the TMPREJ variable in the global workspace *if/when* the "Reject" 
%                  button is pressed (see Outputs); called from pop_eegplot() or 
%                  eeglab(), the marked data portions are removed from the current
%                  dataset, and the dataset is automatically updated.
%     "Display > Marking color > Choose color" - [menu] Change the background marking 
%                  color. The marking color(s) of previously marked trials are preserved. 
%                  Called from command line, subsequent functions eegplot2event() or 
%                  eegplot2trials() allow processing trials marked with different colors 
%                  in the TMPREJ output variable. Command line equivalent: 'wincolor'.
%     "Display > Grid > ..." - [menu] Toggle (on or off) time and/or channel axis grids 
%                  in the activity plot. Submenus allow modifications to grid aspects.
%                  Command line equivalents: 'xgrid' / 'ygrid' 
%     "Display > Show scale" - [menu] Show (or hide if shown) the scale on the bottom 
%                  right corner of the activity window. Command line equivalent: 'scale' 
%     "Display > Title" - [menu] Change the title of the figure. Command line equivalent: 
%                  'title'
%     "Settings > Time range to display"  - [menu] For continuous EEG data, this item 
%                  pops up a query window for entering the number of seconds to display
%                  in the activity window. For epoched data, the query window asks
%                  for the number of epochs to display (this can be fractional). 
%                  Command line equivalent: 'winlength'
%     "Settings > Number of channels to display" - [menu] Number of channels to display
%                  in the activity window.  If not all channels are displayed, the 
%                  user may scroll through channels using the slider on the left 
%                  of the activity plot. Command line equivalent: 'dispchans'
%     "Settings > Channel labels > ..."  - [menu] Use numbers as channel labels or load
%                  a channel location file from disk. If called from the eeglab() menu or
%                  pop_eegplot(), the channel labels of the dataset will be used. 
%                  Command line equivalent: 'eloc_file'
%     "Settings > Zoom on/off" - [menu] Toggle Matlab figure zoom on or off for time and
%                  electrode axes. left-click to zoom (x2); right-click to reverse-zoom. 
%                  Else, draw a rectange in the activity window to zoom the display into 
%                  that region. NOTE: When zoom is on, data cannot be marked for rejection.
%     "Settings > Events" - [menu] Toggle event on or off (assuming events have been 
%                  given as input). Press "legend" to pop up a legend window for events.
%
% Display window interface:
%    "Activity plot" - [main window] This axis displays the channel activities.  For 
%                  continuous data, the time axis shows time in seconds. For epoched
%                  data, the axis label indicate time within each epoch.
%    "Cancel" - [button] Closes the window and cancels any data rejection marks.
%    "Event types" - [button] pop up a legend window for events.
%    "<<" - [button] Scroll backwards though time or epochs by one window length.
%    "<"  - [button] Scroll backwards though time or epochs by 0.2 window length.
%    "Navigation edit box" - [edit box] Enter a starting time or epoch to jump to.
%    ">"  - [button] Scroll forward though time or epochs by 0.2 window length.
%    ">>" - [button] Scroll forward though time or epochs by one window length.
%    "Chan/Time/Value" - [text] If the mouse is within the activity window, indicates
%                  which channel, time, and activity value the cursor is closest to.
%    "Scale edit box" - [edit box] Scales the displayed amplitude in activity units.
%                  Command line equivalent: 'spacing' 
%    "+ / -" - [buttons] Use these buttons to +/- the amplitude scale by 10%. 
%    "Reject" - [button] When pressed, save rejection marks and close the figure. 
%                  Optional input parameter 'command' is evaluated at that time. 
%                  NOTE: This button's label can be redefined from the command line
%                  (see 'butlabel' below). If no processing command is specified
%                  for the 'command' parameter (below), this button does not appear.
%    "Stack/Spread" - [button] "Stack" collapses all channels/activations onto the
%                  middle axis of the plot. "Spread" undoes the operation.
%    "Norm/Denorm" - [button] "Norm" normalizes each channel separately such that all
%                  channels have the same standard deviation without changing original 
%                  data/activations under EEG structure. "Denorm" undoes the operation.  
%                 
% Required command line input:
%    data        - Input data matrix, either continuous 2-D (channels,timepoints) or 
%                  epoched 3-D (channels,timepoints,epochs). If the data is preceded 
%                  by keyword 'noui', GUI control elements are omitted (useful for 
%                  plotting data for presentation). A set of power spectra at
%                  each channel may also be plotted (see 'freqlimits' below).
% Optional command line keywords:
%    'srate'      - Sampling rate in Hz {default|0: 256 Hz}
%    'spacing'    - Display range per channel (default|0: max(whole_data)-min(whole_data))
%    'eloc_file'  - Electrode filename (as in  >> topoplot example) to read
%                    ascii channel labels. Else,
%                   [vector of integers] -> Show specified channel numbers. Else,
%                   [] -> Do not show channel labels {default|0 -> Show [1:nchans]}
%    'limits'     - [start end] Time limits for data epochs in ms (for labeling 
%                   purposes only).
%    'freqs'      - Vector of frequencies (If data contain  spectral values).
%                   size(data, 2) must be equal to size(freqs,2).
%                   *** This option must be used ALWAYS with 'freqlimits' ***                           
%    'freqlimits' - [freq_start freq_end] If plotting epoch spectra instead of data, frequency 
%                   limits to display spectrum. (Data should contain spectral values).
%                   *** This option must be used ALWAYS with 'freqs' ***  
%    'winlength'  - [value] Seconds (or epochs) of data to display in window {default: 10}
%    'dispchans'  - [integer] Number of channels to display in the activity window 
%                   {default: from data}.  If < total number of channels, a vertical  
%                   slider on the left side of the figure allows vertical data scrolling. 
%    'title'      - Figure title {default: none}
%    'plottitle'  - Plot title {default: none}
%    'xgrid'      - ['on'|'off'] Toggle display of the x-axis grid {default: 'off'}
%    'ygrid'      - ['on'|'off'] Toggle display of the y-axis grid {default: 'off'}
%    'ploteventdur' - ['on'|'off'] Toggle display of event duration { default: 'off' }
%    'data2'      - [float array] identical size to the original data and
%                   plotted on top of it.
%
% Additional keywords:
%    'command'    - ['string'] Matlab command to evaluate when the 'REJECT' button is 
%                   clicked. The 'REJECT' button is visible only if this parameter is 
%                   not empty. As explained in the "Output" section below, the variable 
%                   'TMPREJ' contains the rejected windows (see the functions 
%                   eegplot2event() and eegplot2trial()).
%    'butlabel'   - Reject button label. {default: 'REJECT'}
%    'winrej'     - [start end R G B e1 e2 e3 ...] Matrix giving data periods to mark 
%                    for rejection, each row indicating a different period
%                      [start end] = period limits (in frames from beginning of data); 
%                      [R G B] = specifies the marking color; 
%                      [e1 e2 e3 ...] = a (1,nchans) logical [0|1] vector giving 
%                         channels (1) to mark and (0) not mark for rejection.
%    'color'      - ['on'|'off'|cell array] Plot channels with different colors.
%                   If an RGB cell array {'r' 'b' 'g'}, channels will be plotted 
%                   using the cell-array color elements in cyclic order {default:'off'}. 
%    'wincolor'   - [color] Color to use to mark data stretches or epochs {default: 
%                   [ 0.7 1 0.9] is the default marking color}
%    'events'     - [struct] EEGLAB event structure (EEG.event) to use to show events.
%    'submean'    - ['on'|'off'] Remove channel means in each window {default: 'on'}
%    'position'   - [lowleft_x lowleft_y width height] Position of the figure in pixels.
%    'tag'        - [string] Matlab object tag to identify this eegplot_w3() window (allows 
%                    keeping track of several simultaneous eegplot_w3() windows). 
%    'children'   - [integer] Figure handle of a *dependent* eegplot_w3() window. Scrolling
%                    horizontally in the master window will produce the same scroll in 
%                    the dependent window. Allows comparison of two concurrent datasets,
%                    or of channel and component data from the same dataset.
%    'scale'      - ['on'|'off'] Display the amplitude scale {default: 'on'}.
%    'selectcommand' - [cell array] list of 3 commands (strings) to run when the mouse 
%                      button is down, when it is moving and when the mouse button is up.
%    'ctrlselectcommand' - [cell array] same as above in conjunction with pressing the 
%                      CTRL key.
% Outputs:
%    TMPREJ       -  Matrix (same format as 'winrej' above) placed as a variable in
%                    the global workspace (only) when the REJECT button is clicked. 
%                    The command specified in the 'command' keyword argument can use 
%                    this variable. (See eegplot2trial() and eegplot2event()). 
%
% Author: Arnaud Delorme & Colin Humphries, CNL/Salk Institute, SCCN/INC/UCSD, 1998-2001
% Modified by: Ugo Bruzadin Nunes 2021
% Part of the code was copied and altered from the TBT plugin by Mattan S. Ben-Shachar
%
% See also: eeg_multieegplot(), eegplot2event(), eegplot2trial(), eeglab()

% deprecated 
%    'colmodif'   - nested cell array of window colors that may be marked/unmarked. Default
%                   is current color only.

% Copyright (C) 2001 Arnaud Delorme & Colin Humphries, Salk Institute, arno@salk.edu
% Copyright (C) 2017 Mattan S. Ben-Shachar
% Copyright (C) 2021 Ugo Bruzadin Nunes ugobruzadin@gmail.com
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

% Note for programmers - Internal variable structure:
% All in g. except for Eposition and Eg.spacingwhich are inside the boxes
% gcf
%    1 - winlength
%    2 - srate 
%    3 - children
% 'backeeg' axis
%    1 - trialtag
%    2 - g.winrej
%    3 - nested call flag
% 'eegaxis'
%    1 - data
%    2 - colorlist
%    3 - submean    % on or off, subtract the mean
%    4 - maxfreq    % empty [] if no gfrequency content
% 'buttons hold other informations' Eposition for instance hold the current postition

function [outvar1,EEG] = eegplot_w3(EEG, varargin) % p1,p2,p3,p4,p5,p6,p7,p8,p9)

%% Collects component or channel plot, continuous or epoched plot
if isstruct(EEG)
    EEG.varargin = varargin;
    if ~isfield(EEG,'plotIc')
        EEG.plotchannels = 1;
    end
    if ~isfield(EEG,'plotEp')
        EEG.plotEp = 1;
    end
    if EEG.plotchannels == 1
        data = EEG.data;
    else
        data = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
    end
    if EEG.plotEp ~= 1
        data = data(:,:);
    end
else
    data = EEG;
end

%% Defaults (can be re-defined):
%EEG.myVariables = {};
DEFAULT_PLOT_COLOR = { [0 0 1], [0.7 0.7 0.7]};         % EEG line color
try
    icadefs;
	DEFAULT_FIG_COLOR = BACKCOLOR;
	BUTTON_COLOR = GUIBUTTONCOLOR;
catch
	DEFAULT_FIG_COLOR = [1 1 1];
	BUTTON_COLOR =[0.8 0.8 0.8];
end
DEFAULT_AXIS_COLOR = 'k';         % X-axis, Y-axis Color, text Color
DEFAULT_GRID_SPACING = 1;         % Grid lines every n seconds
DEFAULT_GRID_STYLE = '-';         % Grid line style
%YAXIS_NEG = 'off';                % 'off' = positive up 
%DEFAULT_NOUI_PLOT_COLOR = 'k';    % EEG line color for noui option
                                  %   0 - 1st color in AxesColorOrder
SPACING_EYE = 'on';               % g.spacingI on/off
%SPACING_UNITS_STRING = '';        % '\muV' for microvolt optional units for g.spacingI Ex. uV
%MAXEVENTSTRING = 10;
%DEFAULT_AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
                                  % dimensions of main EEG axes
ORIGINAL_POSITION = [50 50 800 500];
                                  
if nargin < 1
   help eegplot_w3
   return
end
				  
% %%%%%%%%%%%%%%%%%%%%%%%%
%% Setup inputs
% %%%%%%%%%%%%%%%%%%%%%%%%

if ~ischar(data) % If NOT a 'noui' call or a callback from uicontrols

   try
       options = varargin;
       if ~isempty( varargin )
           for i = 1:2:numel(options)
               g.(options{i}) = options{i+1};
           end
       else g= [];
       end
   catch
       disp('eegplot_w3() error: calling convention {''key'', value, ... } error'); return;
   end
   
   %% Getting EEG structure from g
   
   if isstruct(EEG)
       g.EEG = EEG;
   end
   
   %% Selection of data range If spectrum plot  
   if isfield(g,'freqlimits') || isfield(g,'freqs')
%        % Check  consistency of freqlimits       
%        % Check  consistency of freqs

       % Selecting data and freqs
       [temp, fBeg] = min(abs(g.freqs-g.freqlimits(1)));
       [temp, fEnd] = min(abs(g.freqs-g.freqlimits(2)));
       data = data(:,fBeg:fEnd,:);
       g.freqs     = g.freqs(fBeg:fEnd);
       
       % Updating settings
       if ndims(data) == 2, g.winlength = g.freqs(end) - g.freqs(1); end 
       g.srate     = length(g.freqs)/(g.freqs(end)-g.freqs(1));
       g.isfreq    = 1;
   end

  %% push button: create/remove window
  % ---------------------------------
  defdowncom   = 'eegplot_w3(''defdowncom'',   gcbf);'; % push button: create/remove window
  defmotioncom = 'eegplot_w3(''defmotioncom'', gcbf);'; % motion button: move windows or display current position
  defupcom     = 'eegplot_w3(''defupcom'',     gcbf);';
  defctrldowncom = 'eegplot_w3(''topoplot'',   gcbf);'; % CTRL press and motion -> do nothing by default
  defctrlmotioncom = ''; % CTRL press and motion -> do nothing by default
  defctrlupcom = ''; % CTRL press and up -> do nothing by default
  
  %% Try Defaults
     try g.rand;                catch g.rand = floor(rand()*1000);  end
     try g.old;                 catch g.old = {};                   end    
     try g.gnumber;             catch g.gnumber     = 1;            end
     try g.typing; 		        catch, g.typing	= 0; 	        end
     try g.thinking; 		    catch, g.thinking	= 0; 	        end
     g.thinking	= 0;
     try g.backcolor; 		    catch, g.backcolor  = [0.93 .96 1]; end
   try g.srate; 		    catch, g.srate		= 256; 	end
     try g.spacing_ch; 			catch, g.spacing_ch	= 0; 	end
     try g.spacing_pc; 			catch, g.spacing_pc	= 4; 	end
   try g.spacing; 			catch, g.spacing	= 0; 	end
     %try g.oldspacing; 	    catch, g.oldspacing	= 0; 	end
   try g.eloc_file; 		catch, g.eloc_file	= 0; 	end % 0 mean numbered
      try g.eloc_file_ch; 		catch, g.eloc_file_ch	= 0; 	end % 0 mean numbered
      try g.eloc_file_pc; 		catch, g.eloc_file_pc	= 0; 	end % 0 mean numbered
   try g.winlength; 		catch, g.winlength	= 5; 	end % Number of seconds of EEG displayed
   try g.fullscreen; 	    catch, g.fullscreen = 'on';	end
   try g.position; 	        catch, g.position	= ORIGINAL_POSITION; g.fullscreen = 'on';	end
   try g.title; 		    catch, g.title		= ['Scroll activity -- eegplot_w3()']; 	end
   try g.plottitle; 		catch, g.plottitle	= ''; 	end
   try g.trialstag; 		catch, g.trialstag	= -1; 	end
   try g.winrej; 			catch, g.winrej		= []; 	end
    try g.winrej_pc; 			catch, g.winrej_pc		= []; 	end
    try g.winrej_ch; 			catch, g.winrej_ch		= []; 	end
   try g.command; 			catch, g.command	= ''; 	end
      try g.command2; 			catch, g.command2	= ''; 	end
   try g.tag; 				catch, g.tag		= 'eegplot_w3'; end
   try g.xgrid;		        catch, g.xgrid		= 'off'; end
   try g.ygrid;		        catch, g.ygrid		= 'off'; end
   try g.color;		        catch, g.color		= 'off'; end
   try g.submean;			catch, g.submean	= 'on'; end
   try g.children;			catch, g.children	= 0; end
   try g.limits;		    catch, g.limits	    = [0 1000*(size(data,2)-1)/g.srate]; end
   try g.freqs;             catch, g.freqs	    = []; end  % Ramon
   try g.freqlimits;	    catch, g.freqlimits	= []; end
   try g.dispchans; 		catch, g.dispchans  = size(data,1); end
   try g.wincolor; 		    catch, g.wincolor   = [.7 1 .9]; end
   try g.butlabel; 		    catch, g.butlabel   = 'Interpolate & Reject'; end
   try g.colmodif; 		    catch, g.colmodif   = { g.wincolor }; end
   try g.scale; 		    catch, g.scale      = 'on'; end
   try g.events; 		    catch, g.events      = []; end
   try g.ploteventdur;      catch, g.ploteventdur = 'off'; end
   try g.data2;             catch, g.data2      = []; end
   try g.plotdata2;         catch, g.plotdata2 = 'off'; end
   try g.mocap;		        catch, g.mocap		= 'off'; end % nima
   try g.selectcommand;     catch, g.selectcommand     = { '' '' '' }; end % { defdowncom defmotioncom defupcom }
   try g.ctrlselectcommand; catch, g.ctrlselectcommand = { '' '' '' }; end % { defctrldowncom defctrlmotioncom defctrlupcom }
   try g.datastd;           catch, g.datastd = []; end %ozgur
    try g.datastd_ch;           catch, g.datastd_ch = []; end %ozgur
    try g.datastd_pc;           catch, g.datastd_pc = []; end %ozgur
   try g.normed;            catch, g.normed = 0; end %ozgur
   try g.normed_ch;            catch, g.normed_ch = 0; end %ozgur
   try g.normed_pc;            catch, g.normed_pc = 0; end %ozgur
   try g.envelope;          catch, g.envelope = 0; end%ozgur
   try g.maxeventstring;    catch, g.maxeventstring = 10; end % JavierLC
   try g.isfreq;            catch, g.isfreq = 0;    end % Ramon
   try g.savecommand;            catch, g.savecommand = '';    end % Ugo
       try g.savecommand2;       catch, g.savecommand2 = '';    end % Ugo
       try g.matrixpos;           catch, g.matrixpos = [ 0.922   0.25      0.075    0.13 ]; end % Ugo
       try g.headpos;           catch, g.headpos = [ 0.92    0.25    0.080    0.13 ]; end % Ugo
   
   
   %% continue defaults
   if strcmpi(g.ploteventdur, 'on')
       g.ploteventdur = 1; 
   else
       g.ploteventdur = 0; 
   end
   
   if ndims(data) > 2
       g.trialstag = size(	data, 2);
   end
   
   gfields = fieldnames(g);
   for index=1:length(gfields)
      switch gfields{index}
          case { 'spacing_ch' 'spacing_pc' 'rand' 'old' 'gnumber' 'typing' 'thinking' 'backcolor' 'EEG' 'winrej' 'winrej_ch' 'winrej_pc' 'srate' 'eloc_file' 'eloc_file_ch' 'eloc_file_pc' 'winlength' 'fullscreen' 'position' 'title' 'plottitle' ...
               'trialstag' 'tag' 'xgrid' 'ygrid' 'color' 'colmodif' 'spacing' 'normed' 'normed_ch' 'normed_pc' 'datastd' 'datastd_ch'  'datastd_pc' ...
               'freqs' 'freqlimits' 'submean' 'children' 'limits' 'matrixpos' 'headpos' 'dispchans' 'wincolor' 'currentoptions' ...
               'maxeventstring' 'ploteventdur' 'butlabel' 'scale' 'events' 'data2' 'plotdata2' 'command'  'command2' 'savecommand' 'savecommand2'...
               'mocap' 'selectcommand' 'ctrlselectcommand' 'envelope' 'isfreq'  'tbtmethods' 'tbtoptions'}
      otherwise, error(['eegplot_w3: unrecognized option: ''' gfields{index} '''' ]);
      end
   end

   % g.data=data; % never used and slows down display dramatically - Ozgur 2010
   
   if length(g.srate) ~= 1
   		disp('Error: srate must be a single number'); return;
   end
   if length(g.spacing) ~= 1
   		disp('Error: ''spacing'' must be a single number'); return;
   end
   if length(g.winlength) ~= 1
   		disp('Error: winlength must be a single number'); return;
   end
   if ischar(g.title) ~= 1
   		disp('Error: title must be is a string'); return;
   end
   if ischar(g.command) ~= 1
   		disp('Error: command must be is a string'); return;
   end
   if ischar(g.tag) ~= 1
   		disp('Error: tag must be is a string'); return;
   end
   if ischar(g.fullscreen) ~= 1
   		disp('Error: position must be is a 4 elements array'); return;
   end
   if length(g.position) ~= 4
   		disp('Error: position must be is a 4 elements array'); return;
   end
   switch lower(g.xgrid)
	   case { 'on', 'off' }
       otherwise
           disp('Error: xgrid must be either ''on'' or ''off'''); return;
   end
   switch lower(g.ygrid)
	   case { 'on', 'off' }
       otherwise
           disp('Error: ygrid must be either ''on'' or ''off'''); return;
   end
   switch lower(g.submean)
	   case { 'on' 'off' }
       otherwise
           disp('Error: submean must be either ''on'' or ''off'''); return;
   end
   switch lower(g.scale)
	   case { 'on' 'off' }
       otherwise
           disp('Error: scale must be either ''on'' or ''off'''); return;
   end
   
   if ~iscell(g.color)
	   switch lower(g.color)
		case 'on', g.color = { 'k', 'm', 'c', 'b', 'g' }; 
		case 'off', g.color = { [ 0 0 0.4] };  
		otherwise 
		 disp('Error: color must be either ''on'' or ''off'' or a cell array'); 
                return;
       end
   end
   if length(g.dispchans) > size(data,1)
	   g.dispchans = size(data,1);
   end
   if ~iscell(g.colmodif)
   		g.colmodif = { g.colmodif };
   end
   if g.maxeventstring>20 % JavierLC
        disp('Error: maxeventstring must be equal or lesser than 20'); return;
   end

   % max event string;  JavierLC
   % ---------------------------------
   MAXEVENTSTRING = g.maxeventstring;
   DEFAULT_AXES_POSITION = [0.05 0.03 0.865 1-(MAXEVENTSTRING-4)/100]; %[0.095 0.35 0.842 0.75-(MAXEVENTSTRING-5)/100];
   
   % convert color to modify into array of float
   % -------------------------------------------
   for index = 1:length(g.colmodif)
       if iscell(g.colmodif{index})
           tmpcolmodif{index} = g.colmodif{index}{1} ...
                                  + g.colmodif{index}{2}*10 ...
                                  + g.colmodif{index}{3}*100;
       else
           tmpcolmodif{index} = g.colmodif{index}(1) ...
                                  + g.colmodif{index}(2)*10 ...
                                  + g.colmodif{index}(3)*100;
       end
   end
   g.colmodif = tmpcolmodif;
   
   [g.chans,g.frames, tmpnb] = size(data);
   g.frames = g.frames*tmpnb;
  
  if g.spacing == 0
    g=optim_scale(data,g);
  end

  %% set g defaults
  % ------------ 
  g.incallback = 0;
  g.winstatus = 1;
  g.setelectrode  = 0;
  [g.chans,g.frames,tmpnb] = size(data);   
  g.frames = g.frames*tmpnb;
  g.nbdat = 1; % deprecated
  g.time  = 0;
  g.elecoffset = 0;
  
  %% Collect winrejs and badchans
  % ------------ 
  if isstruct(EEG)
    % created badchans
    
      if ~isfield(g.eloc_file, 'badchan')
          %if g.EEG.plotchannels == 1
          for ii=1:length(g.eloc_file)
              g.eloc_file(ii).badchan = 0;
          end
      end
      if ~isfield(g.eloc_file_pc, 'badchan')
          if g.eloc_file_pc ~= 0
          %if g.EEG.plotchannels == 1
              for ii=1:length(g.eloc_file_pc)
                  g.eloc_file_pc(ii).badchan = 0;
              end
          end
      end
      if ~isfield(g.eloc_file_ch, 'badchan')
          %if g.EEG.plotchannels == 1
          for ii=1:length(g.eloc_file_ch)
              g.eloc_file_ch(ii).badchan = 0;
          end
      end
    % collects mybadchans and mybadcomps
      if isfield(EEG, 'mybadchan')
          for ch = EEG.mybadchan
              g.eloc_file_ch(ch).badchan = 1;
          end
      end
      %else
      if isfield(EEG, 'mybadcomp')
          for cp = EEG.mybadcomp
              g.eloc_file_pc(cp).badchan = 1;
          end
      end
      % --- still needs work; needs to make sure comps are the same size :/
      % --- collects comprejects from gcompreject

      if isfield(EEG.reject, 'gcompreject')
          if any(EEG.reject.gcompreject)
              mybadcomp2 = find(EEG.reject.gcompreject);
              for ind = 1:size(mybadcomp2,2)
                  try g.eloc_file_pc(mybadcomp2(ind)).badchan = 1; catch; end % marks component as bad
              end
          end
      end
      % --- select which eloc_file to use and collects winrejs

      if g.EEG.plotchannels == 1
          g.eloc_file = g.eloc_file_ch;
          g.chans = size(g.eloc_file_ch,2);
          if isfield(EEG,'chanrej')
              g.winrej = EEG.chanrej;
              g.winrej_ch = EEG.chanrej;
              try g.winrej_pc = EEG.comprej; catch; end
          end
      else
          g.eloc_file = g.eloc_file_pc;
          g.chans = size(g.eloc_file_pc,2);
          if isfield(EEG,'comprej')
              g.winrej = EEG.comprej;
              g.winrej_pc = EEG.comprej;
              g.winrej_ch = EEG.chanrej;
          end
      end
  end

 
  %% %%%%%%%%%%%%%%%%%%%%%%%%
  %  Prepare figure and axes
  %  %%%%%%%%%%%%%%%%%%%%%%%%  

  %[ax0, ax1, figh] = prepare_figure(g,data);

  figh = figure('UserData', g,... % store the settings here
      'Color',DEFAULT_FIG_COLOR, 'name', g.title,...
      'MenuBar','none','tag', g.tag ,'Position',g.position, ...
      'numbertitle', 'off', 'visible', 'off', 'Units', 'Normalized',...
      'interruptible', 'off', 'busyaction', 'queue');

  if strcmp(g.fullscreen,'on')
      %figh.WindowState = 'maximized';
      %set(figh,'OuterPosition',[0 0 1 1]);
      set(figh,'OuterPosition',[ 0	0.06	1	0.94]);
      %0.00087	0.072	1	0.8875
  end
  pos = get(figh,'position'); % plot relative to current axes
  q = [pos(1) pos(2) 0 0];
  s = [pos(3) pos(4) pos(3) pos(4)]./100;
  clf;
  
  % Plot title if provided
  if ~isempty(g.plottitle)
      h = findobj('tag', 'eegplottitle'); 
      if ~isempty(h)
          set(h, 'string',g.plottitle);
      else
          h = textsc(g.plottitle, 'title'); 
          set(h, 'tag', 'eegplottitle');
      end
  end
      
  % Background axis
  % --------------- 
  ax0 = axes('tag','backeeg','parent',figh,...
      'Position',DEFAULT_AXES_POSITION,...
      'Box','off','xgrid','off', 'xaxislocation', 'top', 'Units', 'Normalized'); 

  % Drawing axis
  % --------------- 
  YLabels = num2str((1:g.chans)');  % Use numbers as default
  YLabels = flipud(char(YLabels,' '));
  ax1 = axes('Position',DEFAULT_AXES_POSITION,...
      'userdata', data, ...% store the data here
      'tag','eegaxis','parent',figh,...%(when in g, slow down display)
      'Box','on','xgrid', g.xgrid,'ygrid', g.ygrid,...
      'gridlinestyle',DEFAULT_GRID_STYLE,...
      'Xlim',[0 g.winlength*g.srate],...
      'xtick',[0:g.srate*DEFAULT_GRID_SPACING:g.winlength*g.srate],...
      'Ylim',[0 (g.chans+1)*g.spacing],...
      'YTick',[0:g.spacing:g.chans*g.spacing],...
      'YTickLabel', YLabels,...
      'XTickLabel',num2str((0:DEFAULT_GRID_SPACING:g.winlength)'),...
      'TickLength',[.005 .005],...
      'Color','none',...
      'XColor',DEFAULT_AXIS_COLOR,...
      'YColor',DEFAULT_AXIS_COLOR,...
      'FontSize',8);
  
  if ischar(g.eloc_file) || isstruct(g.eloc_file)  % Read in electrode names
      if isstruct(g.eloc_file) && length(g.eloc_file) > size(data,1)
          g.eloc_file(end) = []; % common reference channel location
      end
      eegplot_w3('setelect', g.eloc_file, ax1);
  end
  
  %% Set up uicontrols
  % %%%%%%%%%%%%%%%%%%%%%%%%%

  defaultsizes = [0.02,0.03,0.04,0.05];

  r = .0;

% positions of buttons
%                  bottom  left    width    heigth
% numbers go from 1 and end at 47 (need to be reorganized)
  posbut(22,:) = [ 0.92    0.98    0.080    defaultsizes(1) ]; % stack channels(same offset)  
  posbut(21,:) = [ 0.92    0.96    0.080    defaultsizes(1) ]; % normalize
  posbut(17,:) = [ 0.92    0.94    0.080    defaultsizes(1) ]; % events types
  
  posbut(14,:) = [ 0.92    0.92    0.080    defaultsizes(1) ]; % elec tag
  posbut(7,:) =  [ 0.92    0.90    0.080    defaultsizes(1) ]; % elec
  
  posbut(16,:) = [ 0.92    0.88    0.080    defaultsizes(1) ]; % value tag
  posbut(9,:) =  [ 0.92    0.86    0.080    defaultsizes(1) ]; % value
  
  posbut(15,:) = [ 0.92    0.84    0.080    defaultsizes(1) ]; % g.time tag
  posbut(8,:) =  [ 0.92    0.82    0.080    defaultsizes(1) ]; % g.time   
    
  posbut(5,:) =  [ 0.92    0.80    0.080    defaultsizes(1) ]; % Eposition .52
   posbut(46,:) =  [ 0.92    0.78    0.010    defaultsizes(1) ]; % |<<  % NEW UGO
  posbut(1,:) =  [ 0.93    0.78    0.015    defaultsizes(1) ]; % <<  
  posbut(2,:) =  [ 0.945    0.78    0.015    defaultsizes(1) ]; % <  
  posbut(3,:) =  [ 0.96    0.78    0.015    defaultsizes(1) ]; % >
  posbut(4,:) =  [ 0.975    0.78    0.015    defaultsizes(1) ]; % >>  
   posbut(47,:) =  [ 0.99    0.78    0.010    defaultsizes(1) ]; % >>|  % NEW UGO

  posbut(23,:) = [ 0.92    0.76    0.040    defaultsizes(1) ]; % Espacing/scale tag
  posbut(6,:) =  [ 0.92    0.74    0.040    defaultsizes(1) ]; % Espacing/scale  

   posbut(48,:) = [ 0.96    0.76    0.040    defaultsizes(1) ]; % NumChan tag % NEW UGO
   posbut(49,:) = [ 0.96    0.74    0.040    defaultsizes(1) ]; % NumChan % NEW UGO

  posbut(52,:) = [ 0.96    0.72    0.040    defaultsizes(1) ]; % Reset chan numbers to max auto % NEW UGO

  posbut(10,:) = [ 0.94    0.72    0.020    defaultsizes(1) ]; % +  
  posbut(11,:) = [ 0.92    0.72    0.020    defaultsizes(1) ]; % -  
  
  posbut(20,:) = [ 0.005   0.02    0.010    0.96 ]; % slider  
  
  % new TBT options #Ugo
  posbut(25,:) = [ 0.92    0.68+r    0.080    defaultsizes(1) ]; % Title tag
  posbut(31,:) = [ 0.93    0.66+r    0.060    defaultsizes(1) ]; % List of methods to run in the data
  posbut(33,:) = [ 0.92    0.63+r    0.080    defaultsizes(1) ]; % List of Channel/Epoch Methods, drop box, select from list
  posbut(34,:) = [ 0.92    0.60+r    0.080    defaultsizes(1) ]; % TextBox with options
  posbut(35,:) = [ 0.92    0.57+r    0.080    defaultsizes(2) ]; % TextBox with option hints!
  posbut(36,:) = [ 0.92    0.55+r    0.040    defaultsizes(1) ]; % Percent of Trials Tag
  posbut(37,:) = [ 0.96    0.55+r    0.040    defaultsizes(1) ]; % Number of Channels Tag
  posbut(38,:) = [ 0.92    0.53+r    0.040    defaultsizes(1) ]; % Percent of Trials box
  posbut(39,:) = [ 0.96    0.53+r    0.040    defaultsizes(1) ]; % Number of Channels Box
  
  posbut(40,:) = [ 0.92    0.51+r    0.040    defaultsizes(1) ]; % Run button % run code from box 1 and 2, add data to winrej, redraw
  posbut(32,:) = [ 0.96    0.51+r    0.040    defaultsizes(1) ]; % Apply Rejections;
  
  posbut(41,:) = [ 0.92    0.49+r    0.040    defaultsizes(1) ]; % Clear marks button
  posbut(50,:) = [ 0.96    0.49+r    0.020    defaultsizes(1) ]; % UNDO BUTTON
  posbut(53,:) = [ 0.98    0.49+r    0.020    defaultsizes(1) ]; % REDO BUTTON

  posbut(30,:) = [ 0.92    0.47+r    0.080    defaultsizes(1) ]; % Counting marks tag #Ugo
  posbut(29,:) = [ 0.92    0.45+r    0.080    defaultsizes(1) ]; % Counting marks #Ugo
  
  posbut(54,:) = [ 0.92    0.43+r    0.040    defaultsizes(1) ]; % plot FFT
  posbut(55,:) = [ 0.96    0.43+r    0.040    defaultsizes(1) ]; % plot ICA headmaps
  posbut(56,:) = [ 0.92    0.41+r    0.040    defaultsizes(1) ]; % plot AVG FFT
  
  posbut(24,:) = [ 0.92    0.38+r    0.080    defaultsizes(1) ]; % Topoplot title

  %this doesnt do anything, just a place so I can remember what the
  %positions are, if I change up top I'll have to change here.
  headpos =     [ 0.922   0.25      0.075    0.13 ]; %position of topoplot
  matrixpos =   [ 0.92    0.25      0.080    0.10 ];  %position of matrix

  % deprecated
  %posbut(26,:) = [ 0.93    0.25    0.080    defaultsizes(1) ]; % Plot data difference #Ugo
  posbut(28,:) = [ 0.92    0.21    0.080    defaultsizes(2) ]; % Epoched/Continuous Mode
  posbut(27,:) = [ 0.92    0.18    0.080    defaultsizes(2) ]; % Rejecting/Interpolating Mode  
  posbut(51,:) = [ 0.92    0.15    0.080    defaultsizes(2) ]; % Components/EEG SWITCH FUNCTION

  posbut(43,:) = [ 0.92    0.13    0.080    defaultsizes(1) ]; % RUN, TAG AND SAVE

  posbut(44,:) = [ 0.92    0.11    0.080    defaultsizes(1) ]; % SAVE TEXT EDIT
  posbut(45,:) = [ 0.92    0.08    0.080    defaultsizes(1) ]; % SAVE FILE BUTTON

  posbut(42,:) = [ 0.92    0.06    0.080    defaultsizes(1) ]; % store marks #Ugo
  posbut(13,:) = [ 0.92    0.04    0.080    defaultsizes(1) ]; % cancel/close
  posbut(12,:) = [ 0.92    0.02    0.080    defaultsizes(1) ]; % accept/close
  

%% Channel rejection callbacks
% get channels for partial interpolation
chaninterp = ['EEG.myVariables{1} = get(findobj(gcf, ''Tag'', ''Channel''),''string'');']; 
% select plot difference
plotdiffcom = ['EEG.myVariables{2} = get(findobj(gcf, ''Tag'', ''datadiff''),''Value'');'];
% get channels for complete interpolation
chaninterp2 = ['EEG.myVariables{3} = get(findobj(gcf, ''Tag'', ''Removal''),''string'');'];


displayep = ['eegplot_w3(''redraw'')'];
togglerej = ['eegplot_w3(''rejection'')'];
displaycomp = ['EEG.plotEp = 1 - EEG.plotEp; eegplot_w3(EEG,varargin)'];

%     function selection(src,event)
%         val = c.Value;
%         str = c.String;
%         str{val};
%         disp(['Selection: ' str{val}]);
%     end

% --- start trial by trial options
% 
%  gettextandsavecommand = ['g = get(gcf,''UserData''); EEG = g.EEG; EEG.reject.gcompreject [EEG] = pop_saveset(EEG, ''filename'', [strcat( EEG.filename(1:end-4),get(findobj(''tag'',''SaveNowText''),''string''),''.set'')],''filepath'',EEG.filepath);'...
%       '[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);g.EEG = EEG;']; %save set ADDED BY UGO

u(54) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(54,:), ...
    'Style','pushbutton',...
	'Tag','plotFFT',...
	'string','plot avg FFT',...
    'callback',['g = get(gcf,''UserData''); quick_spectra(g.EEG,40,2,''AVG'');']);

% newcommand = ['' 'comps = find(EEG.reject.gcompreject);' ,...
%     ['close(gcf); ' ...
%     'g = get(findobj(''tag'',''eegplot_w3''),''UserData'');'  ...
%     'g.eloc_file(comps).badchan = 1;'] ,...
%     'set(gcf,''UserData'',g);',...
%     'update_trial_rejections(g);',...
%     'draw_data([],[],gcf,0,[],g);end' '' ];
% 
% newcommand = ['sprintf('''' hello '''');'];
% 
% %ICLcommand = ['g = get(gcf,''UserData''); [EEG,~] = quick_IClabel(g.EEG,[],[],[],[],''sprintf(''''hello'''')''); '];

ICLcommand = ['g = get(gcf,''UserData''); [EEG,com] = quick_IClabel(g.EEG,[],[],[],[],[''eegplot_w3(''''MERGE_REJECTION'''')'']);'];
%     'comps = find(ICL.reject.gcompreject);' ,...
%     'g.eloc_file(comps).badchan = 1;' ,...
%     'set(gcf,''UserData'',g);',...
%     'update_trial_rejections(g);',...
%     'draw_data([],[],gcf,0,[],g);end'];

u(55) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(55,:), ...
    'Style','pushbutton',...
	'Tag','plotICLABEL',...
	'string','plot ICL',...
    'callback',ICLcommand);

u(50) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(44,:), ...
	'Style','edit', ...
	'Tag','SaveNowText',...
	'string','');

    u(58) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(45,:), ...
    'Style','pushbutton',...
	'Tag','SaveNowButton',...
	'string','+Save To File',...
    'callback',['eegplot_w3(''SAVE'')']);

%% heatmap title
  u(24) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(24,:), ...
    'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Style','text', ...
    'FontSize',8, ...
	'Tag','headmap',...
	'string','Data Matrix');

%% TBT part modified from pop_TBT() scripts
if isstruct(EEG)
QuickLabDefs;

    g.eegmethods = ['ICA|' ...
        'BSS EMG|'...
        'Re-reference|'...
        'Reduce headmodel to 94|'...
        'Re-epoch|'...
        'Quick DotLoc(HM94,Ep6,ICA)|'...
        'BSS + ICA'];

    g.eegoptions = {...
        ['[], ''binica'', 0'],...
        ['components, extended, verbose'],...
        'quick_pca';...
        ...
        [''],...
        'window, windowshift',...
        'quick_bss2';...
        ...
        ['AVG'],...
        'choose reference(s)',...
        'quick_reref';...
        ...
        '',...
        'remove surrounding channels',...
        'quick_HM94';...
        ...
        '0.600,2.648',...
        'time 1, time 2',...
        'quick_epoch';...
        ...
        ['name'],...
        'write the function you want to run',...
        '';...
        [''],...
        '',...
        '';...
        };

    g.iclmethods = ['All but Brain and Other|' ...
        'Brain|'...
        'Muscle|'...
        'Eye|'...
        'Heart|'...
        'Line noise|'...
        'Channel noise|'...
        'Other'];

    g.icloptions = {...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .3 0 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        
        };

    g.tbtmethods = ['Detect Flatline|' ...
        'Abnormal values|'...
        'Abnormal trends|'...
        'Improbable data|'...
        'Abnormal distributions|'...
        'Abnormal spectra|'...
        'Max-Min Threshold|'...
        'Detect Channel Pops'];
    
    g.tbtoptions = {...
        ['5, 20'],...
        ['fl duration, max jitter'],...
        '';...
        ...
        ['-500 , 500 ,' num2str(EEG.xmin) ' , ' num2str(EEG.xmax)],...
        'lowthresh, upthresh, starttime, endtime',...
        'pop_eegthresh';...
        ...
        [num2str(EEG.pnts) ' , 0.5 , 0.3'],...
        'winsize, maxslope, minR',...
        'pop_rejtrend';...
        ...
        '3 , 3',...
        'locthresh, globthresh',...
        'pop_jointprob';...
        ...
        '3 , 3',...
        'locthresh, globthresh',...
        'pop_rejkurt';...
        ...
        ['''method'' , ''FFT'' , ''threshold'' , [-70 , 15] ,''freqlimits'' , [20 , 55]'],...
        'th in Db, limits in Hz >34',...
        'pop_rejspec';...
        ...
        ['[1:' num2str(EEG.nbchan) '],[' num2str([EEG.xmin EEG.xmax]*1000) '],100,' num2str([EEG.xmax - EEG.xmin]*1000) ',1,0'],...
        'chRange,timeRange,minmaxThresh,winSize,stepSize,maW',...
        'pop_eegmaxmin';...
        ...
        ['{5, 8, 100, 2, [],''mean''}'],...
        ['SumWindow, StdRej, max rej win, Chancomps, type'],...
        '';...
        };
else
    g.tbtmethods = {'0','0'};
    g.tbtoptions = {'0','0'};
end

g.allmethods = ['TBT|' ...
        'QUICKLAB|'...
        'ICLABEL'];

g.currentooptions = g.tbtoptions;

% Choose Methods tag
  u(25) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(25,:), ...
	'Style','text', ...
    'FontSize',8, ...
	'Tag','ListTag',...
    'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'string','Select Methods');

% Methods tag
  u(32) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(31,:), ...
    'BackgroundColor',[1 1 1], ...
	'Style','popupmenu', ...
    'HorizontalAlignment', 'center',...
    'FontSize',10, ...
	'Tag','ListPopup',...
	'string',g.allmethods,...
    'callback',@change_list);

% methods
  u(33) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(33,:), ...
	'Style','popupmenu', ...
	'Tag','ALLmethods',...
	'string',g.tbtmethods,...
    'callback',@change_options);

% options
  u(34) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(34,:), ...
	'Style','edit', ...
	'Tag','ALLoptions',...
	'string',g.tbtoptions{1});

% options hints
  u(35) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(35,:), ...
	'Style','text', ...
    'BackgroundColor',DEFAULT_FIG_COLOR, ...
    'FontSize',8,...
	'Tag','ALLhints',...
	'string',g.tbtoptions{1,2});
% hint
% tag
  u(36) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
    'FontSize',8,...
	'Position', posbut(36,:), ...
	'Style','text', ...
	'Tag','TBT%tag',...
	'string','% trials 4 rej');

  u(37) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
    'FontSize',8,...
	'Position', posbut(37,:), ...
	'Style','text', ...
	'Tag','TBTnchanstag',...
	'string','#chans 4 rej');

  u(38) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(38,:), ...
	'Style','edit', ...
	'Tag','TBT%',...
	'string','60');

  u(39) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(39,:), ...
	'Style','edit', ...
	'Tag','TBTnchans',...
	'string','10');

  u(40) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(40,:), ...
	'Tag','TBT',...
    'BackgroundColor',[1 .5 0.5],...
	'string','Run Method',...
	'Callback', 'eegplot_w3(''METHODS'')' );

  u(60) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(32,:), ...
	'Tag','APPLY',...
    'BackgroundColor',[1 .5 0.5],...
	'string','Interp & Rej',...
	'Callback', ['eegplot_w3(''APPLY'')'] );

  %posbut(32
  u(41) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(41,:), ...
	'Tag','ClearMarks',...
    'BackgroundColor',[1 .5 0.5],...
	'string','Clear Marks',...
	'Callback', ['eegplot_w3(''ClearMarks'')']);

%% Save, Tag and ICA attempts #Ugo 5/27/2022
% u(43) = uicontrol('Parent',figh, ...
% 	'Units', 'normalized', ...
% 	'Position', posbut(43,:), ...
% 	'Tag','SaveTagICA',...
%     'BackgroundColor',[.5 1 0.5],...
% 	'string','Tag, Save & ICA',...
% 	'Callback', ['eegplot_w3(''saveandtag'')'] );

%% bss attempts #Ugo 6/25/2022

g.scripts = ['BSS|' ...
        'ICA|'...
        'Reference|'...
        'Epoch|'...
        'Channel Reduction'];
% 
% u(45) = uicontrol('Parent',figh, ...
% 	'Units', 'normalized', ...
% 	'Position', posbut(51,:), ...
% 	'Tag','Scripts',...
%     'BackgroundColor',[1 1 1],...
% 	'Style','popupmenu', ...
% 	'string',g.scripts,...
% 	'Callback', ['eegplot_w3(''BSS'')']);

if g.EEG.plotchannels
    cmodecolor = [0.5 1 0.5];
    cmode = 'EEG DATA ON';
else
    cmodecolor = [1 0.5 0.5];
    cmode = 'COMPONENT DATA ON';
end

u(45) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(51,:), ...
	'Tag','SWITCH',...
    'BackgroundColor',cmodecolor,...
	'string',cmode,...
	'Callback', ['eegplot_w3(''SWITCH'')']);

% u(46) = uicontrol('Parent',figh, ...
% 	'Units', 'normalized', ...
% 	'Position', posbut(50,:), ...
% 	'Tag','UNDO',...
%     'BackgroundColor',[.7 .7 1],...
% 	'string','Undo',...
% 	'Callback', ['eegplot_w3(''UNDO'')']);
% 
% u(47) = uicontrol('Parent',figh, ...
% 	'Units', 'normalized', ...
% 	'Position', posbut(53,:), ...
% 	'Tag','REDO',...
%     'BackgroundColor',[.7 .7 1],...
% 	'string','Redo',...
% 	'Callback', ['eegplot_w3(''REDO'')']);

%% channel or epoch, rejection or interpolation buttons #Ugo

 u(27) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(27,:), ...
	'Tag','Rejection',...
    'BackgroundColor',[.5 1 0.5],...
	'string','Interpolating ON',...
	'Callback', togglerej );

if g.trialstag == -1
    modecolor = [0.5 1 0.5];
    mode = 'Epoch OFF';
else
    modecolor = [1 0.5 0.5];
    mode = 'Epoched ON';
end

 u(28) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(28,:), ...
	'Tag','Display',...
    'BackgroundColor',modecolor,...
	'string',mode,...
	'Callback', displayep );

%% number of marked areas for control #Ugo

  u(29) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(29,:), ...
    'Style','text', ...
    'FontSize',8,...
	'Tag','Count_Trials',...
	'string','');

  u(30) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(30,:), ...
	'Style','text', ...
    'FontSize',8,...
	'Tag','Count_Channels',...
	'string','');

%% plot data difference checkbox

% u(26)= uicontrol('Parent',figh, ...
% 	'Units', 'normalized', ...
% 	'BackgroundColor',DEFAULT_FIG_COLOR, ...
% 	'Position', posbut(26,:), ...
% 	'Style','checkbox', ...
% 	'FontSize',8,...
% 	'Tag','datadiff',...
% 	'string','plot Data Difference',...
%     'Callback', plotdiffcom );

%% Five move buttons: |< << < text > >> >|
% NEW: GOES TO THE BEGGINING % UGO
  u(46) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(46,:), ...
	'Tag','Pushbutton0',...
	'string','|<',...
    'FontSize',8,...
	'Callback',{@draw_data,figh,8,[],[],ax1});

  u(1) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(1,:), ...
	'Tag','Pushbutton1',...
	'string','<<',...
    'FontSize',8,...
	'Callback',{@draw_data,figh,1,[],[],ax1});
  u(2) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(2,:), ...
	'Tag','Pushbutton2',...
	'string','<',...
	'Callback',{@draw_data,figh,2,[],[],ax1});
  u(5) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(5,:), ...
	'Style','edit', ...
	'Tag','EPosition',...
	'string', fastif(g.trialstag(1) == -1, '0', '1'),...
	'Callback', {@draw_data,figh,0,[],[],ax1});
  u(3) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(3,:), ...
	'Tag','Pushbutton3',...
	'string','>',...
	'Callback',{@draw_data,figh,3,[],[],ax1});
  u(4) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(4,:), ...
	'Tag','Pushbutton4',...
	'string','>>',...
    'FontSize',8,...
	'Callback',{@draw_data,figh,4,[],[],ax1});

  % NEW GO TO THE END #UGO
  u(47) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(47,:), ...
	'Tag','Pushbutton4',...
	'string','>|',...
    'FontSize',8,...
	'Callback',{@draw_data,figh,7,[],[],ax1});

%% Text edit fields: NumChans

  u(49) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(49,:), ...
	'Style','edit', ...
	'Tag','NumChan',...
	'string',num2str(g.chans),...
	'Callback', 'eegplot_w3(''winelec_text'')' );

  %% Text edit fields: ESpacing
    u(6) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(6,:), ...
	'Style','edit', ...
	'Tag','ESpacing',...
	'string',num2str(g.spacing),...
	'Callback', {@change_scale,figh,0,ax1} );

%% Slider for vertical motion
  u(20) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(20,:), ...
   'Style','slider', ...
   'visible', 'off', ...
   'sliderstep', [0.9 1], ...
   'Tag','eegslider', ...
   'callback',{@draw_data,figh,0,[],[],ax1,'g.elecoffset = get(gcbo, ''value'')*(g.chans-g.dispchans);'}, ...
   'value', 0);

%% Channels, position, value and tag

  u(9) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(7,:), ...
	'Style','text', ...
	'Tag','Eelec',...
	'string',' ');
  u(10) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(8,:), ...
	'Style','text', ...
	'Tag','Etime',...
	'string','0.00');
  u(11) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position',posbut(9,:), ...
	'Style','text', ...
	'Tag','Evalue',...
	'string','0.00');

  u(14)= uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(14,:), ...
	'Style','text', ...
	'FontSize',8,...
	'Tag','Eelecname',...
	'string','Channel/Component');

  u(23)= uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(23,:), ...
	'Style','text', ...
	'FontSize',8,...
	'Tag','thescale',...
	'string','Scale');

    u(48)= uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(48,:), ...
	'Style','text', ...
	'FontSize',8,...
	'Tag','NumChansTag',...
	'string','Chan Display');

%% Values of time/value and freq/power in GUI
  if g.isfreq
      u15_string =  'Freq';
      u16_string  = 'Power';
  else
      u15_string =  'Time';
      u16_string  = 'Value';
  end
      
  u(15) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(15,:), ...
	'Style','text', ...
	'FontSize',8,...
	'Tag','Etimename',...
	'string',u15_string);

  u(16) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position',posbut(16,:), ...
	'Style','text', ...
	'FontSize',8,...
	'Tag','Evaluename',...
	'string',u16_string);

%% ESpacing buttons: + -
  u(7) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(10,:), ...
	'Tag','Pushbutton5',...
	'string','+',...
	'FontSize',10,...
	'Callback',{@change_scale,figh,1,ax1});
  u(8) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(11,:), ...
	'Tag','Pushbutton6',...
	'string','-',...
	'FontSize',10,...
	'Callback',{@change_scale,figh,2,ax1});
  
  u(61) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(52,:), ...
	'Tag','Pushbutton6',...
	'string','Show all',...
	'FontSize',10,...
	'Callback',['eegplot_w3(''winelec_auto'')']);

%% Button for Normalizing data
u(21) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(21,:), ...
    'Tag','Norm',...
    'string','Norm', 'callback', {@normalize_chan,figh});

cb_envelope = ['g = get(gcbf,''userdata'');'...
    'hmenu = findobj(gcf, ''Tag'', ''Envelope_menu'');' ...
    'g.envelope = ~g.envelope;' ...
    'set(gcbf,''userdata'',g);'...
    'set(gcbo,''string'',fastif(g.envelope,''Spread'',''Stack''));' ...
    'set(hmenu, ''Label'', fastif(g.envelope,''Spread channels'',''Stack channels''));' ...
    'eegplot_w3(''drawp'',0);clear g;'];

%% Button to plot envelope of data
u(22) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(22,:), ...
    'Tag','Envelope',...
    'string','Stack', 'callback', cb_envelope);

  if isempty(g.command) tmpcom = 'fprintf(''Rejections saved in variable TMPREJ\n'');';   
  else tmpcom = g.command;
  end
  closecommand = ['g = get(gcbf,''userdata''); EEG = g.EEG; if g.children, delete(g.children); end'...
                 'delete(gcbf);' ...
                 'eval(get(findobj(''tag'',''LoadDir''),''Callback''));' ...
                 'eval(get(findobj(''tag'',''LoadFileList''),''Callback''));'];

  acceptcommand = [ 'g = get(gcbf, ''userdata'');' ... 
                    'TMPREJ = g.winrej;' ...
                    'if isfield(g, ''eloc_file'') && isfield(g.eloc_file, ''badchan''); '...
                         'TMPREJCHN = find([g.eloc_file.badchan]); '...
                    'else TMPREJCHN = [];'...
                    'end ' ...
                          closecommand ...
		  				  tmpcom ...
                    '; clear g;']; % quitting expression
  if ~isempty(g.command)
% 	  u(12) = uicontrol('Parent',figh, ...
% 						'Units', 'normalized', ...
% 						'Position',posbut(12,:), ...
% 						'Tag','Accept',...
% 						'string',g.butlabel, 'callback', acceptcommand);
  end
  
  u(13) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(13,:), ...
	'string',fastif(isempty(g.command),'CLOSE', 'CLOSE'), 'callback', ...
		[	'g = get(gcbf, ''userdata'');' ... 
            'if g.children, delete(g.children); end;' ...
			'close(gcbf);'] );

% save button #Ugo
if isempty(g.command) 
    tmpsavecom = 'fprintf(''Rejections saved in variable TMPREJ\n'');';   
else 
    if g.EEG.plotchannels == 1
        tmpsavecom = g.savecommand;
    else
        tmpsavecom = g.savecommand_pc;
    end
end
  savecommand = [ 'g = get(gcbf, ''userdata'');' ...               
                    'TMPREJ = g.winrej;' ...
                    'if isfield(g, ''eloc_file'') && isfield(g.eloc_file, ''badchan''); '...
                         'TMPREJCHN = find([g.eloc_file.badchan]); '...
                    'else TMPREJCHN = [];'...
                    'end; ' ...
		  				  tmpsavecom]; % quitting expression
                      
  if ~isempty(g.savecommand)
    u(42) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(42,:), ...
	'Tag','SaveButton',...
    'BackgroundColor',[.5 1 0.5],...
	'string','Store Marks to eeglab',...
	'Callback', savecommand );
  end

 acceptandsavecommand = [savecommand acceptcommand];


  if ~isempty(g.events)
      u(17) = uicontrol('Parent',figh, ...
                        'Units', 'normalized', ...
                        'Position',posbut(17,:), ...
                        'string', 'Events', 'callback', 'eegplot_w3(''drawlegend'', gcbf)');
  end

  for i = 1: length(u) % Matlab 2014b compatibility
      if isprop(eval(['u(' num2str(i) ')']),'Style')
          set(u(i),'Units','Normalized');
      end
  end
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set up uimenus
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Figure Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  m(7) = uimenu('Parent',figh,'Label','Figure');
  m(8) = uimenu('Parent',m(7),'Label','Print');
  uimenu('Parent',m(7),'Label','Edit figure', 'Callback', 'eegplot_w3(''noui'');');
  uimenu('Parent',m(7),'Label','Accept and close','Tag','AcceptAndSave', 'Callback', acceptandsavecommand );
  uimenu('Parent',m(7),'Label','Cancel and close', 'Callback','delete(gcbf)')
  
  % Portrait %%%%%%%%

  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'PANT1 = get(OBJ1,''parent'');',...
	        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
		'set(OBJ2,''checked'',''off'');',...
		'set(OBJ1,''checked'',''on'');',...
		'set(FIG1,''PaperOrientation'',''portrait'');',...
		'clear OBJ1 FIG1 OBJ2 PANT1;'];
		
  uimenu('Parent',m(8),'Label','Portrait','checked',...
      'on','tag','orient','callback',timestring)
  
  % Landscape %%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'PANT1 = get(OBJ1,''parent'');',...
	        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
		'set(OBJ2,''checked'',''off'');',...
		'set(OBJ1,''checked'',''on'');',...
		'set(FIG1,''PaperOrientation'',''landscape'');',...
		'clear OBJ1 FIG1 OBJ2 PANT1;'];
  
  uimenu('Parent',m(8),'Label','Landscape','checked',...
      'off','tag','orient','callback',timestring)

  % Print command %%%%%%%
  uimenu('Parent',m(8),'Label','Print','tag','printcommand','callback',...
  		['RESULT = inputdlg2( { ''Command:'' }, ''Print'', 1,  { ''print -r72'' });' ...
		 'if size( RESULT,1 ) ~= 0' ... 
		 '  eval ( RESULT{1} );' ...
		 'end;' ...
		 'clear RESULT;' ]);
  
  % Display Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  m(1) = uimenu('Parent',figh,...
      'Label','Display', 'tag', 'displaymenu');
  
  % window grid %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % userdata = 4 cells : display yes/no, color, electrode yes/no, 
  %                      trial boundary adapt yes/no (1/0)  
  m(11) = uimenu('Parent',m(1),'Label','Data select/mark', 'tag', 'displaywin', ...
            'userdata', { 1, [0.8 1 0.8], 0, fastif( g.trialstag(1) == -1, 0, 1)});

          uimenu('Parent',m(11),'Label','Hide marks','Callback', ...
  	        ['g = get(gcbf, ''userdata'');' ...
            'if ~g.winstatus' ... 
            '  set(gcbo, ''label'', ''Hide marks'');' ...
            'else' ...
            '  set(gcbo, ''label'', ''Show marks'');' ...
            'end;' ...
            'g.winstatus = ~g.winstatus;' ...
            'set(gcbf, ''userdata'', g);' ...
            'eegplot_w3(''drawb''); clear g;'] )

	% color %%%%%%%%%%%%%%%%%%%%%%%%%%
    if isunix % for some reasons, does not work under Windows
        uimenu('Parent',m(11),'Label','Choose color', 'Callback', ...
               [ 'g = get(gcbf, ''userdata'');' ...
                 'g.wincolor = uisetcolor(g.wincolor);' ...
                 'set(gcbf, ''userdata'', g ); ' ...
                 'clear g;'] )
    end

  % plot durations
  % --------------
  if g.ploteventdur && isfield(g.events, 'duration')
      disp(['Use menu "Display > Hide event duration" to hide colored regions ' ...
           'representing event duration']);
  end
  if isfield(g.events, 'duration')
      uimenu('Parent',m(1),'Label',fastif(g.ploteventdur, 'Hide event duration', 'Plot event duration'),'Callback', ...
             ['g = get(gcbf, ''userdata'');' ...
              'if ~g.ploteventdur' ... 
              '  set(gcbo, ''label'', ''Hide event duration'');' ...
              'else' ...
              '  set(gcbo, ''label'', ''Show event duration'');' ...
              'end;' ...
              'g.ploteventdur = ~g.ploteventdur;' ...
              'set(gcbf, ''userdata'', g);' ...
              'eegplot_w3(''drawb''); clear g;'] )
  end

  % X grid %%%%%%%%%%%%
  m(3) = uimenu('Parent',m(1),'Label','Grid');
  timestring = ['FIGH = gcbf;',...
	            'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
	            'if size(get(AXESH,''xgrid''),2) == 2' ... %on
		        '  set(AXESH,''xgrid'',''off'');',...
		        '  set(gcbo,''label'',''X grid on'');',...
		        'else' ...
		        '  set(AXESH,''xgrid'',''on'');',...
		        '  set(gcbo,''label'',''X grid off'');',...
		        'end;' ...
		        'clear FIGH AXESH;' ];
  uimenu('Parent',m(3),'Label',fastif(strcmp(g.xgrid, 'off'), ...
         'X grid on','X grid off'), 'Callback',timestring)
  
  % Y grid %%%%%%%%%%%%%
  timestring = ['FIGH = gcbf;',...
	            'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
	            'if size(get(AXESH,''ygrid''),2) == 2' ... %on
		        '  set(AXESH,''ygrid'',''off'');',...
		        '  set(gcbo,''label'',''Y grid on'');',...
		        'else' ...
		        '  set(AXESH,''ygrid'',''on'');',...
		        '  set(gcbo,''label'',''Y grid off'');',...
		        'end;' ...
		        'clear FIGH AXESH;' ];
  uimenu('Parent',m(3),'Label',fastif(strcmp(g.ygrid, 'off'), ...
         'Y grid on','Y grid off'), 'Callback',timestring)

  % Grid Style %%%%%%%%%
  m(5) = uimenu('Parent',m(3),'Label','Grid Style');
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''--'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','- -','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''-.'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','_ .','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'','':'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','. .','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''-'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','__','Callback',timestring)
  
  % Submean menu %%%%%%%%%%%%%
  cb =       ['g = get(gcbf, ''userdata'');' ...
              'if strcmpi(g.submean, ''on''),' ... 
              '  set(gcbo, ''label'', ''Remove DC offset'');' ...
              '  g.submean =''off'';' ...
              'else' ...
              '  set(gcbo, ''label'', ''Do not remove DC offset'');' ...
              '  g.submean =''on'';' ...
              'end;' ...
              'set(gcbf, ''userdata'', g);' ...
              'eegplot_w3(''drawp'', 0); clear g;'];
  uimenu('Parent',m(1),'Label',fastif(strcmp(g.submean, 'on'), ...
         'Do not remove DC offset','Remove DC offset'), 'Callback',cb)

  % Scale Eye %%%%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'eegplot_w3(''scaleeye'',OBJ1,FIG1);',...
		'clear OBJ1 FIG1;'];
  m(7) = uimenu('Parent',m(1),'Label','Show scale','Callback',timestring);
  
  % Title %%%%%%%%%%%%
  uimenu('Parent',m(1),'Label','Title','Callback','eegplot_w3(''title'')')
  
  % Stack/Spread %%%%%%%%%%%%%%%
  cb =       ['g = get(gcbf, ''userdata'');' ...
              'hbutton = findobj(gcf, ''Tag'', ''Envelope'');' ...  % find button
              'if g.envelope == 0,' ... 
              '  set(gcbo, ''label'', ''Spread channels'');' ...
              '  g.envelope = 1;' ...
              '  set(hbutton, ''String'', ''Spread'');' ...
              'else' ...
              '  set(gcbo, ''label'', ''Stack channels'');' ...
              '  g.envelope = 0;' ...
              '  set(hbutton, ''String'', ''Stack'');' ...
              'end;' ...
              'set(gcbf, ''userdata'', g);' ...
              'eegplot_w3(''drawp'', 0); clear g;'];
  uimenu('Parent',m(1),'Label',fastif(g.envelope == 0, ...
         'Stack channels','Spread channels'), 'Callback',cb, 'Tag', 'Envelope_menu')
     
  % Normalize/denormalize %%%%%%%%%%%%%%%
  uimenu('Parent',m(1),'Label',fastif(g.envelope == 0, ...
         'Normalize channels','Denormalize channels'), 'Callback', {@normalize_chan,figh}, 'Tag', 'Normalize_menu')

  
  % Settings Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  m(2) = uimenu('Parent',figh,...
      'Label','Settings'); 
  
  % Window %%%%%%%%%%%%
  uimenu('Parent',m(2),'Label','Time range to display',...
      'Callback','eegplot_w3(''window'')')
  
  % Electrode window %%%%%%%%
  uimenu('Parent',m(2),'Label','Number of channels to display',...
      'Callback','eegplot_w3(''winelec'')')
  
  % Electrodes %%%%%%%%
  m(6) = uimenu('Parent',m(2),'Label','Channel labels');
  
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'YTICK = get(AXESH,''YTick'');',...
		'YTICK = length(YTICK);',...
		'set(AXESH,''YTickLabel'',flipud(char(num2str((1:YTICK-1)''),'' '')));',...
		'clear FIGH AXESH YTICK;'];
  uimenu('Parent',m(6),'Label','Show number','Callback',timestring)
  uimenu('Parent',m(6),'Label','Load .loc(s) file',...
      'Callback','eegplot_w3(''loadelect'');')
  
  % Zooms %%%%%%%%
 % if ismatlab && verLessThan('matlab','8.4.0')
 %     zm = uimenu('Parent',m(2),'Label','Zoom off/on');
 %     commandzoom = [ 'set(gcbf, ''WindowButtonDownFcn'', [ ''zoom(gcbf,''''down''''); eegplot_w3(''''zoom'''', gcbf, 1);'' ]);' ...
 %         'tmpg = get(gcbf, ''userdata'');' ...
 %         'clear tmpg tmpstr;'];
 %     uimenu('Parent',zm,'Label','Zoom on', 'callback', commandzoom);
 %     uimenu('Parent',zm,'Label','Zoom off', 'separator', 'on', 'callback', ...
 %         ['zoom(gcbf, ''off''); tmpg = get(gcbf, ''userdata'');' ...
 %         'set(gcbf, ''windowbuttondownfcn'', tmpg.commandselect{1});' ...
 %         'set(gcbf, ''windowbuttonupfcn'', tmpg.commandselect{3});' ...
 %         'clear tmpg;' ]);
 % else
 %      % This is failing for us http://undocumentedmatlab.com/blog/enabling-user-callbacks-during-zoom-pan
 %      uimenu('Parent',m(2),'Label','Zoom off/on', 'callback', 'warning(''FIXME: Zoom not work in MATLAB >= 8.4.0'')');
 % end
      
  uimenu('Parent',m(2),'Label', 'Help', 'callback', 'pophelp(''eegplot_w3'');'); %changed from figh to m(2) > settings

  % Events %%%%%%%%
  ev = uimenu('Parent',m(2),'Label','Events');
  comeventmaxstring   = [ 'tmpg = get(gcbf, ''userdata'');' ...
                'tmpg.plotevent = ''on'';' ...
                'set(gcbf, ''userdata'', tmpg); clear tmpg; eegplot_w3(''emaxstring'');']; % JavierLC      
  comeventleg  = [ 'eegplot_w3(''drawlegend'', gcbf);'];
    
  uimenu('Parent',ev,'Label','Events on'    , 'callback', {@draw_data,figh,0,[],[],ax1,'g.plotevent = ''on'';'},  'enable', fastif(isempty(g.events), 'off', 'on'));
  uimenu('Parent',ev,'Label','Events off'   , 'callback', {@draw_data,figh,0,[],[],ax1,'g.plotevent = ''off'';'}, 'enable', fastif(isempty(g.events), 'off', 'on'));
  uimenu('Parent',ev,'Label','Events'' string length'   , 'callback', comeventmaxstring, 'enable', fastif(isempty(g.events), 'off', 'on')); % JavierLC
  uimenu('Parent',ev,'Label','Events'' legend', 'callback', comeventleg , 'enable', fastif(isempty(g.events), 'off', 'on'));
  

  % %%%%%%%%%%%%%%%%%
  % Set up autoselect                                                        
  % NOTE: commandselect{2} option has been moved to a
  %       subfunction to improve speed
  %%%%%%%%%%%%%%%%%%%

   mouse_motion_com = {'@eegplot_w3,''mouse_motion'';'};


  if ~isempty(g.ctrlselectcommand{1}) || ~isempty(g.ctrlselectcommand{3}) || ...
         ~isempty(g.selectcommand{1}) || ~isempty(g.selectcommand{3})
      g.commandselect{1} = [ 'if strcmp(get(gcbf, ''SelectionType''),''alt''),' ...
           g.ctrlselectcommand{1} '; else ' g.selectcommand{1} '; end;' ];
      g.commandselect{3} = [ 'if strcmp(get(gcbf, ''SelectionType''),''alt''),' ...
           g.ctrlselectcommand{3} '; else ' g.selectcommand{3} '; end;' ];
      set(figh, 'WindowButtonDownFcn',   g.commandselect{1});
      set(figh, 'WindowButtonupFcn',     g.commandselect{3});
  else
      set(figh, 'WindowButtonDownFcn',   {@mouse_down,figh});
      set(figh, 'WindowButtonupFcn',     {@mouse_up,figh});
  end;

  set(figh, 'WindowScrollWheelFcn',  {@mouse_scroll_wheel,figh,ax0,ax1,u(10),u(11),u(9)});
  set(figh, 'WindowButtonMotionFcn', {@mouse_motion,figh,ax0,ax1,u(10),u(11),u(9)});
  %set(figh, 'windowbuttonmotionfcn', EEG = eegplot_w3('mouse_motion'));
  set(figh, 'WindowKeyPressFcn',     {@eegplot_readkey,figh,ax0,ax1,u(10),u(11),u(9)});
  set(figh, 'interruptible', 'on');
%  set(figh, 'busyaction', 'cancel');
%  set(figh, 'windowbuttondownfcn', commandpush);
%  set(figh, 'windowbuttonmotionfcn', commandmove);
%  set(figh, 'windowbuttonupfcn', commandrelease);
  
  % prepare event array if any
  % --------------------------
  if ~isempty(g.events)
      if ~isfield(g.events, 'type') || ~isfield(g.events, 'latency'), g.events = []; end;
  end;
      
  if ~isempty(g.events)
      if ischar(g.events(1).type)
           [g.eventtypes, ~, indexcolor] = unique_bc({g.events.type}); % indexcolor countinas the event type
      else [g.eventtypes, ~, indexcolor] = unique_bc([ g.events.type ]);
      end;
      %indexcolor=length(indexcolor)-indexcolor+1;
      g.eventcolors     = { 'r', [0 0.8 0], 'b', 'm', [1 0.5 0],  [0.5 0 0.5], [0.6 0.3 0] };  
      g.eventstyle      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'};
      g.eventwidths     = [ 2.5 1 ];
      g.eventtypecolors = g.eventcolors(mod([1:length(g.eventtypes)]-1 ,length(g.eventcolors))+1);
      g.eventcolors     = g.eventcolors(mod(indexcolor-1               ,length(g.eventcolors))+1);
      g.eventtypestyle  = g.eventstyle (mod([1:length(g.eventtypes)]-1 ,length(g.eventstyle))+1);
      g.eventstyle      = g.eventstyle (mod(indexcolor-1               ,length(g.eventstyle))+1);
      
      % for width, only boundary events have width 2 (for the line)
      % -----------------------------------------------------------
      indexwidth = ones(1,length(g.eventtypes))*2;
      if iscell(g.eventtypes)
          index=find(ismember(g.eventtypes,{'boundary'}));
          if ~isempty(index)
              indexwidth(index) = 1;
              g.eventtypestyle{index} = '-';
              g.eventtypecolors{index} = 'c';
              g.eventstyle(find(indexcolor==index))={'-'};
              g.eventcolors(find(indexcolor==index))={'c'};
          end;
      end;
      g.eventtypewidths = g.eventwidths (mod(indexwidth([1:length(g.eventtypes)])-1 ,length(g.eventwidths))+1);
      g.eventwidths     = g.eventwidths (mod(indexwidth(indexcolor)-1               ,length(g.eventwidths))+1);
      
      % latency and duration of events
      % ------------------------------
      g.eventlatencies  = [ g.events.latency ]+1;
      if isfield(g.events, 'duration')
           durations = { g.events.duration };
           durations(cellfun(@isempty, durations)) = { NaN };
           g.eventlatencyend   = g.eventlatencies + [durations{:}]+1;
      else g.eventlatencyend   = [];
      end;
      g.plotevent       = 'on';
  end;
  if isempty(g.events)
      g.plotevent      = 'off';
  end;

  set(figh, 'userdata', g);
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot EEG Data
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  axes(ax1)
  hold on
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot Spacing I
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  YLim = get(ax1,'Ylim');
  A = DEFAULT_AXES_POSITION;
  axes('Position',[A(1)+A(3) 0.3 1-A(1)-A(3) A(4)],'Visible','off','Ylim',YLim,'tag','eyeaxes')
  axis manual
  if strcmp(SPACING_EYE,'on')
      set(m(7),'checked','on')
  else
      set(m(7),'checked','off');
  end 
  eegplot_w3('scaleeye', [], gcf);
  if strcmp(lower(g.scale), 'off')
	  eegplot_w3('scaleeye', 'off', gcf);
  end;
  
  eegplot_w3('drawp', 0);
  if g.dispchans ~= g.chans
  	   eegplot_w3('zoom', gcf);
  end 
  eegplot_w3('scaleeye', [], gcf);
  
  h = findobj(gcf, 'style', 'pushbutton');
  set(h, 'backgroundcolor', BUTTON_COLOR);
  
  % set button colors #Ugo
  h = findobj(gcf, 'tag', 'Rejection');
  set(h, 'backgroundcolor', [0.5 1 0.5]);
  h = findobj(gcf, 'tag', 'APPLY');
  set(h, 'backgroundcolor', [1 1 0]);
  h = findobj(gcf, 'tag', 'TBT');
  set(h, 'backgroundcolor', [1 1 0]);
  h = findobj(gcf, 'tag','SaveNowButton');
  set(h, 'backgroundcolor', [1 1 0]);
  h = findobj(gcf, 'tag', 'SaveTagICA');
  set(h, 'backgroundcolor', [1 1 0]);
  h = findobj(gcf, 'tag', 'Display');
  set(h, 'backgroundcolor', modecolor);
  h = findobj(gcf, 'tag', 'eegslider');
  set(h, 'backgroundcolor', BUTTON_COLOR);
  set(figh, 'visible', 'on');
  h = findobj(gcf, 'tag', 'SWITCH');
  set(h, 'backgroundcolor', cmodecolor);
  
  update_trial_rejections(g)
  
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Main Function
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
  try p1 = varargin{1}; p2 = varargin{2}; catch, end;
  switch data

  case 'MERGE_REJECTION'
    tmpstatus = get(findobj('parent', gcf, 'Style', 'checkbox'), 'value');
    comps = fliplr([tmpstatus{:}]);
    close(gcf);
    %EEG = p1;
    
    fig = findobj('tag','eegplot_w3');
%     g = get(fig,'UserData'); 
%     if size(fig,1) > 2
         g = get(gcf,'UserData');
%     end
    
    %[ICL,~] = quick_IClabel(g.EEG); 
    comps = find(comps);
    set(gcf,'UserData',g);
    if g.EEG.plotchannels == 1
        g = SWITCH(g);
        g.eloc_file = g.eloc_file_pc;
    else
    for i = comps
        g.eloc_file(i).badchan = 1;
    end
    end
    update_trial_rejections(g);
    draw_data([],[],gcf,0,[],g);

      case 'TYPING'
        g = get(gcf,'UserData'); 
        %g = TYPING(g,p1);

  case 'mouse_motion'

      %mouse_motion(varargin)
      
      figh = findobj('tag','eegplot_w3');
      ax0 = findobj('tag','backeeg','parent',figh);
      ax1 = findobj('tag','eegaxis','parent',figh);

      A = findobj('Style','text');
      B = findobj('Tag','Eelec');
      C = findobj('Tag','Evalue');

      mouse_motion([],[],figh,ax0,ax1,B,C,A)

  case 'SAVE'
      %fig = findobj('tag','eegplot_w3');
      g = get(gcf,'UserData'); 
      EEG = g.EEG; 
       if EEG.plotchannels == 1
           EEG.chanrej = g.winrej;
           EEG.comprej = g.winrej_pc;
           try EEG.mybadchan = find([g.eloc_file.badchan]);catch; end
           try EEG.mybadcomp = find([g.eloc_file_pc.badchan]); EEG.gcompreject = find([g.eloc_file.badchan]);catch; end
       else
           EEG.chanrej = g.winrej_ch;
           EEG.comprej = g.winrej;
           try EEG.mybadchan = find([g.eloc_file_ch.badchan]);catch; end
           try EEG.mybadcomp = find([g.eloc_file.badchan]); EEG.gcompreject = find([g.eloc_file.badchan]); catch; end
       end
      
      suffix = get(findobj(gcf,'tag','SaveNowText'),'string');
      EEG.filename(1:end-4)
      [EEG] = pop_saveset(EEG, 'filename', [strcat( EEG.filename(1:end-4),suffix,'.set')],'filepath',EEG.filepath);
      set(findobj(gcf,'tag','SaveNowText'),'String','');
      [EEG] = eeg_store([], EEG);
      g.EEG = EEG; %save set ADDED BY UGO
      set(gcf,'UserData',g);

  case 'METHODS'
    g = get(gcf,'UserData');
    g = methods(g);

  case 'APPLY'
    g = get(gcf,'UserData');
    if g.normed
        normalize_chan([],[],gcf);
    end
    g = APPLY(g);
    
  case 'SWITCH'
    g = get(gcf,'UserData');
    g = SWITCH(g);

    h = findobj(gcf, 'tag', 'SWITCH');
    if ~isempty(g.EEG.icaact)
        if g.EEG.plotchannels
            set(h,'string','EEG data ON');
            set(h, 'BackGroundColor', [0.5 1 0.5]);
        else
            set(h,'string','Component Data On');
            set(h, 'BackgroundColor', [1 0.5 0.5]);
        end
    end
    %change_scale([],[],gcf,p1)
%    eegplot_w3('zoom', gcf);
%    egplot_w3('updateslider', gcf);
%    eegplot_w3('drawp',0);	
%    eegplot_w3('scaleeye', [], gcf);
    ax2 = findobj('tag','eegaxis','parent',fig);
    change_scale([],[],gcf,4,ax2);

  case 'UNDO'

    g = get(gcf,'UserData');
    g = UNDO(g);

  case 'REDO'

    g = get(gcf,'UserData');
    g = REDO(g);

  case 'saveandtag'
    g = get(gcf,'UserData');
    EEG = g.EEG;
    EEG.save = 1;
    EEG.ICA = 1;
    eval(get(findobj(gcf,'tag','AcceptAndSave'),'Callback'));
      
      %     g = get(gcf,'UserData');
%     EEG = g.EEG;
%     tmpcolor = g.color;
%     draw_data2(gcf,[],[],tmpcolor)
    %figure; spy(g.winrej)
    %interpolation_plot(g)
    %draw_matrix(gcf,g);
    %[EEG, ~] = quick_spectra(EEG,40,2,'AVG');

  case 'TBT'
      g = get(gcf,'UserData');
      g = TBT(g);
      ax2 = findobj('tag','eegaxis','parent',gcf);
      change_scale([],[],gcf,4,ax2);

  case 'QUICKLAB'     
      g = get(gcf,'UserData');
      g = QUICKLAB(g);
      ax2 = findobj('tag','eegaxis','parent',gcf);
      change_scale([],[],gcf,4,ax2);
  
  case 'ICLABEL'
      g = get(gcf,'UserData');
      ax2 = findobj('tag','eegaxis','parent',gcf);
      g = ICLABEL(g);
      change_scale([],[],gcf,4,ax2);

  case 'ClearMarks'
      g = get(gcf,'UserData');
      g.winrej = [];
      for ii=1:length(g.eloc_file)
          g.eloc_file(ii).badchan = 0;
      end
      update_trial_rejections(g);
      draw_data([],[],gcf,0,[],g);
      
  case 'rejection'
    g = get(gcf,'UserData');
    dis = findobj(gcf,'tag', 'Rejection');
    figh = findobj(gcf,'tag', g.tag);
    if dis.String == "Interpolating ON"
        g.wincolor = [1 0.8 0.8];
        set(dis,'BackgroundColor',[1 0.5 0.5]);
        set(dis,'string','Rejecting ON');
        set(figh,'Color',[.9 .7 .7])
        set(findobj(gcf,'Style','Text'),'BackgroundColor',[.9 .7 .7])
    else
        g.wincolor = [0.7 1 0.9];
        set(dis,'BackgroundColor',[0.5 1 0.5]);
        set(dis,'string','Interpolating ON');
        set(figh,'Color',[.93 .96 1])
        set(findobj(gcf,'Style','Text'),'BackgroundColor',[.93 .96 1])
    end
    
    draw_data([],[],gcf,0,[],g);
      
   case 'redraw'
    g = get(gcf,'UserData');
    EEG = g.EEG;
    epoch = abs(EEG.xmin - EEG.xmax);
    dis = findobj('tag', 'Display');
    
    if g.trialstag == -1
        
        g.trialstag = (g.srate * epoch)+1 ;
        g.winlength =  g.winlength / epoch;
        g.time = g.time * epoch;
        
        set(dis,'BackgroundColor',[1 0.5 0.5]); %make display red
        set(dis,'string','Epoched ON');
        
        draw_data([],[],gcf,5,[],g);
    else
        g.trialstag = -1;
        g.winlength = g.winlength * epoch;
        
        g.time = g.time * epoch;
        set(dis,'BackgroundColor',[0.5 1 0.5]); %make display green
        set(dis,'string','Epoched OFF');

        draw_data([],[],gcf,5,[],g);
    end
      
  case 'drawp'
    % Redraw EEG and change position
    draw_data([],[],gcf,p1)
    
  case 'drawb' 
    % Draw background
    draw_background
    
  case 'draws'
    % Redraw EEG and change scale
    change_scale([],[],gcf,p1)

  case 'draww'
    % Redraw EEG and change window size
    change_eeg_window_length([],[],gcf,p1)
    
  case 'window'  % change window size
    % get new window length with dialog box
    % -------------------------------------
    g = get(gcf,'UserData');
	result       = inputdlg2( { fastif(g.trialstag==-1,'New window length (s):', 'Number of epoch(s):') }, 'Change window length', 1,  { num2str(g.winlength) });
	if size(result,1) == 0 return; end;

	g.winlength = eval(result{1}); 
	set(gcf, 'UserData', g);
	eegplot_w3('drawp',0);	
	return;
    
  case 'winelec_auto'  % change channel window size
                  % get new window length with dialog box
                  % -------------------------------------
   fig = gcf;
   g = get(gcf,'UserData');
   %g = THINKING(g,1);
   
   g.dispchans = g.chans;

   set(gcf, 'UserData', g);
    ax1 = findobj('tag','eegaxis','parent',fig);
    try
    set(ax1,...
    'YTick', [0:g.spacing:g.chans*g.spacing],...
    'Ylim',  [g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] ); % 'YLim',[0 (g.chans+1)*g.spacing]
    catch
    end

% update scaling eye (I) if it exists
% -----------------------------------
eyeaxes = findobj('tag','eyeaxes','parent',fig);
if ~isempty(eyeaxes)
    eyetext = findobj('type','text','parent',eyeaxes,'tag','thescalenum');
    set(eyetext,'string',num2str(g.spacing,4))
end
   eegplot_w3('setelect');
   eegplot_w3('updateslider', fig);
   eegplot_w3('drawp',0);	
   eegplot_w3('scaleeye', [], fig);

   %g = THINKING(g,0);
   set(gcf, 'UserData', g);

  case 'winelec'  % change channel window size
                  % get new window length with dialog box
                  % -------------------------------------
   fig = gcf;
   g = get(gcf,'UserData');
   %g = THINKING(g,1);
   
   result = inputdlg2( ...
{ 'Number of channels to display:' } , 'Change number of channels to display', 1,  { num2str(g.dispchans) });
   if size(result,1) == 0 return; end
   
   g.dispchans = eval(result{1});
   if g.dispchans<0 || g.dispchans>g.chans
       g.dispchans = g.chans;
   end;
   set(gcf, 'UserData', g);
   
   eegplot_w3('updateslider', fig);
   eegplot_w3('drawp',0);	
   eegplot_w3('scaleeye', [], fig);
   %g = THINKING(g,0);
   set(gcf, 'UserData', g);

   %MarkChannel([],[],fig,0,0);
   %Fixing UGO
   %set(gcf,'UserData',g);
   %draw_data([],[],fig,0,[],g);
   
   return;
   
  case 'winelec_text'  % change channel window size
                  % get new window length with dialog box
                  % -------------------------------------
   fig = gcf;
   g = get(gcf,'UserData');
   
   g.dispchans = str2num(get(findobj('tag','NumChan'),'String'));

   if isempty(g.dispchans) || g.dispchans < 0 || g.dispchans > g.chans
       g.dispchans = g.chans;
   end

   set(gcf, 'UserData', g);
   
   eegplot_w3('updateslider', fig);
   eegplot_w3('drawp',0);	
   eegplot_w3('scaleeye', [], fig);
   %MarkChannel([],[],fig,0,0);
   %Fixing UGO
   %set(gcf,'UserData',g);
   %draw_data([],[],fig,0,[],g);
   
   return;

   case 'emaxstring'  % change events' string length  ;  JavierLC
      % get dialog box
      % -------------------------------------
      g = get(gcf,'UserData');
      result = inputdlg2({ 'Max events'' string length:' } , 'Change events'' string length to display', 1,  { num2str(g.maxeventstring) });
      if size(result,1) == 0 return; end                 
      g.maxeventstring = eval(result{1});
      set(gcf, 'UserData', g);
      eegplot_w3('drawb');
      return;
      
  case 'loadelect' % load channels
	[inputname,inputpath] = uigetfile('*','Channel locations file');
	if inputname == 0 return; end;
	if ~exist([ inputpath inputname ],'file')
		error('no such file');
	end;

	AXH0 = findobj('tag','eegaxis','parent',gcf);
	eegplot_w3('setelect',[ inputpath inputname ],AXH0);
	return;
  
  case 'setelect'
    % Set channels    
    g = get(gcf,'UserData');
    if nargin < 3
        axeshand = findobj('tag','eegaxis','parent',gcf);
    else 
        axeshand = p2;
    end
    if nargin < 2
        eloc_file = g.eloc_file;
    else
        eloc_file = p1;
    end
    
    
    outvar1 = 1;
    if isempty(eloc_file)
      outvar1 = 0;
      return
    end
    
    tmplocs = readlocs(eloc_file);
	YLabels = { tmplocs.labels };
    YLabels = strvcat(YLabels);
    
    YLabels = flipud(char(YLabels,' '));
    set(axeshand,'YTickLabel',YLabels)
  
  case 'title'
    % Get new title
	h = findobj('tag', 'eegplottitle');
	
	if ~isempty(h)
		result       = inputdlg2( { 'New title:' }, 'Change title', 1,  { get(h(1), 'string') });
		if ~isempty(result), set(h, 'string', result{1}); end;
	else 
		result       = inputdlg2( { 'New title:' }, 'Change title', 1,  { '' });
		if ~isempty(result), h = textsc(result{1}, 'title'); set(h, 'tag', 'eegplottitle');end;
	end;
	
	return;

  case 'scaleeye'
    % Turn scale I on/off
    obj = p1;
    figh = p2;
	g = get(figh,'UserData');
    % figh = get(obj,'Parent');

    if ~isempty(obj)
		eyeaxes = findobj('tag','eyeaxes','parent',figh);
		children = get(eyeaxes,'children');
		if ischar(obj)
			if strcmp(obj, 'off')
				set(children, 'visible', 'off');
				set(eyeaxes, 'visible', 'off');
				return;
			else
				set(children, 'visible', 'on');
				set(eyeaxes, 'visible', 'on');
			end;
		else
			toggle = get(obj,'checked');
			if strcmp(toggle,'on')
				set(children, 'visible', 'off');
				set(eyeaxes, 'visible', 'off');
				set(obj,'checked','off');
				return;
			else
				set(children, 'visible', 'on');
				set(eyeaxes, 'visible', 'on');
				set(obj,'checked','on');
			end;
        end
    end;
	
	eyeaxes = findobj('tag','eyeaxes','parent',figh);
    ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
	YLim = double(get(ax1, 'ylim'));
    
	ESpacing = findobj('tag','ESpacing','parent',figh);
	g.spacing= str2num(get(ESpacing,'string'));
	
	axes(eyeaxes); cla; axis off;
    set(eyeaxes, 'ylim', YLim);
    set(eyeaxes, 'xlim', [0 1]);
    
	Xl = double([.01 .05; .03 .03; .01 .05]);
    Yl = double([ g.spacing g.spacing; g.spacing 0; 0 0] + YLim(1));
	plot(Xl(1,:),Yl(1,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline'); hold on;
	plot(Xl(2,:),Yl(2,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline');
	plot(Xl(3,:),Yl(3,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline');
    set(eyeaxes, 'tag', 'eyeaxes');
    
  case 'noui'
      if ~isempty(varargin)
          eegplot_w3( varargin{:} ); fig = gcf;
      else 
          fig = findobj('tag', 'eegplot_w3');
      end
      set(fig, 'menubar', 'figure');
      
      % find button and text
      obj = findobj(fig, 'style', 'pushbutton'); delete(obj);
      obj = findobj(fig, 'style', 'edit'); delete(obj);
      obj = findobj(fig, 'style', 'text'); 
      %objscale = findobj(obj, 'tag', 'thescale');
      %delete(setdiff(obj, objscale));
	  obj = findobj(fig, 'tag', 'Eelec');delete(obj);
	  obj = findobj(fig, 'tag', 'Etime');delete(obj);
	  obj = findobj(fig, 'tag', 'Evalue');delete(obj);
	  obj = findobj(fig, 'tag', 'Eelecname');delete(obj);
	  obj = findobj(fig, 'tag', 'Etimename');delete(obj);
	  obj = findobj(fig, 'tag', 'Evaluename');delete(obj);
	  obj = findobj(fig, 'type', 'uimenu');delete(obj);
 
   case 'zoom' % if zoom
      fig = varargin{1};
      ax1 = findobj('tag','eegaxis','parent',fig); 
      ax2 = findobj('tag','backeeg','parent',fig); 
      tmpxlim  = get(ax1, 'xlim');
      tmpylim  = get(ax1, 'ylim');
      tmpxlim2 = get(ax2, 'xlim');
      set(ax2, 'xlim', get(ax1, 'xlim'));
      g = get(fig,'UserData');
      
      % deal with abscissa
      % ------------------
      if g.trialstag ~= -1
          Eposition = str2num(get(findobj('tag','EPosition','parent',fig), 'string'));
          g.winlength = (tmpxlim(2) - tmpxlim(1))/g.trialstag;
          Eposition = Eposition + (tmpxlim(1) - tmpxlim2(1)-1)/g.trialstag;
          Eposition = round(Eposition*1000)/1000;
          set(findobj('tag','EPosition','parent',fig), 'string', num2str(Eposition));
      else
          Eposition = str2num(get(findobj('tag','EPosition','parent',fig), 'string'))-1;
          g.winlength = (tmpxlim(2) - tmpxlim(1))/g.srate;	
          Eposition = Eposition + (tmpxlim(1) - tmpxlim2(1)-1)/g.srate;
          Eposition = round(Eposition*1000)/1000;
          set(findobj('tag','EPosition','parent',fig), 'string', num2str(Eposition+1));
      end 
      
      % deal with ordinate
      % ------------------
      g.elecoffset = tmpylim(1)/g.spacing;
      g.dispchans  = round(1000*(tmpylim(2)-tmpylim(1))/g.spacing)/1000;      
      
      set(fig,'UserData', g);
      eegplot_w3('updateslider', fig);
      eegplot_w3('drawp', 0);
      eegplot_w3('scaleeye', [], fig);

      % reactivate zoom if 3 arguments
      % ------------------------------
      if exist('p2', 'var') == 1
          if ismatlab && verLessThan('matlab','8.4.0')
              set(gcbf, 'windowbuttondownfcn', [ 'zoom(gcbf,''down''); eegplot_w3(''zoom'', gcbf, 1);' ]);
          else
              warning('FIXME: Zoom not work in MATLAB >= 8.4.0')
          end
      end

	case 'updateslider' % if zoom
      fig = varargin{1};
      g = get(fig,'UserData');
      sliider = findobj('tag','eegslider','parent',fig);
      if g.elecoffset < 0
         g.elecoffset = 0;
      end
      if g.dispchans >= g.chans
         g.dispchans = g.chans;
         g.elecoffset = 0;
         set(sliider, 'visible', 'off');
      else
         set(sliider, 'visible', 'on');         
		 set(sliider, 'value', g.elecoffset/g.chans, ...
					  'sliderstep', [1/(g.chans-g.dispchans) g.dispchans/(g.chans-g.dispchans)]);
         %'sliderstep', [1/(g.chans-1) g.dispchans/(g.chans-1)]);
      end
      if g.elecoffset < 0
         g.elecoffset = 0;
      end
      if g.elecoffset > g.chans-g.dispchans
         g.elecoffset = g.chans-g.dispchans;
      end
      set(fig,'UserData', g);
	  eegplot_w3('scaleeye', [], fig);
   
   case 'drawlegend'
      fig = varargin{1};
      g = get(fig,'UserData');
      
      if ~isempty(g.events) % draw vertical colored lines for events, add event name text above
          nleg = length(g.eventtypes);
          fig2 = figure('numbertitle', 'off', 'name', '', 'visible', 'off', 'menubar', 'none', 'color', DEFAULT_FIG_COLOR);
          pos = get(fig2, 'position');
          set(fig2, 'position', [ pos(1) pos(2) 130 14*nleg+20]);
          
          for index = 1:nleg
              plot([10 30], [(index-0.5) * 10 (index-0.5) * 10], 'color', g.eventtypecolors{index}, 'linestyle', ...
                          g.eventtypestyle{ index }, 'linewidth', g.eventtypewidths( index )); hold on;
              if iscell(g.eventtypes)
                  th=text(35, (index-0.5)*10, g.eventtypes{index}, ...
                                    'color', g.eventtypecolors{index});
              else
                  th=text(35, (index-0.5)*10, num2str(g.eventtypes(index)), ...
                                    'color', g.eventtypecolors{index});
              end
          end
          xlim([0 130]);
          ylim([0 nleg*10]);
          axis off;
          set(fig2, 'visible', 'on');
      end


  % motion button: move windows or display current position (channel, g.time and activation)
  % ----------------------------------------------------------------------------------------
   % case moved as subfunction    
  % add topoplot
  % ------------
  case 'topoplot'
    fig = varargin{1};
    plot_topoplot(fig);
%     g = get(fig,'UserData');
%     if ~isstruct(g.eloc_file) || ~isfield(g.eloc_file, 'theta') || isempty( [ g.eloc_file.theta ])
%         return;
%     end;
%     ax1 = findobj('tag','backeeg','parent',fig); 
%     tmppos = get(ax1, 'currentpoint');
%     ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
%     % plot vertical line
%     %yl = ylim(ax1);
%     %plot(ax1, [ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
%     
%     if g.trialstag ~= -1
%           lowlim = round(g.time*g.trialstag+1);
%     else, lowlim = round(g.time*g.srate+1);
%     end;
%     data = get(ax1,'UserData');
%     datapos = max(1, round(tmppos(1)+lowlim));
%     datapos = min(datapos, g.frames);
    
    %STOPPED HERE
    
    %axes = get(findobj('tag','Topoplot'));
    %figure; topoplot(data(:,datapos), g.eloc_file);
%     if g.trialstag == -1
%          latsec = (datapos-1)/g.srate;
%          title(sprintf('Latency of %d seconds and %d milliseconds', floor(latsec), round(1000*(latsec-floor(latsec)))));
%     else
%         trial = ceil((datapos-1)/g.trialstag);
%         latintrial = eeg_point2lat(datapos, trial, g.srate, g.limits, 0.001);
%         title(sprintf('Latency of %d ms in trial %d', round(latintrial), trial));
%     end;
    
  % release button: check window consistency, add to trial boundaries
  % -------------------------------------------------------------------
  case 'defupcom'
    mouse_up([],[],varargin{1}); % Just for compatibility with original eegplot()
         
  % push button: create/remove window
  % ---------------------------------
  case 'defdowncom'
      mouse_down([],[],varargin{1}); % Just for compatibility with original eegplot()
   otherwise
      error(['Error - invalid eegplot_w3() parameter: ',data])
  end
  
end

% NEW FUNCTION: FAST PLOTTING ONE CHANNEL OR ONE PART AT A TIME.

function draw_data2(figh,g,channel,winrej,tmpcolor)
%tic
ax1 = findobj('tag','eegaxis','parent',figh);

data = get(ax1,'UserData');

%meandata = zeros(1,g.chans);

if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
else
        multiplier = g.srate;
end

lowlim = round(g.time*multiplier+1);
highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));

switch lower(g.submean) % subtract the mean ?
    case 'on'
        if ~isempty(g.data2)
            meandata = nan_mean(g.data2(:,lowlim:highlim)');
        else
            meandata = nan_mean(data(:,lowlim:highlim)');
        end
    otherwise, meandata = zeros(1,g.chans);
end

oldspacing = g.spacing;

% plot data
% ---------
hold(ax1,'on')

% fixes the channel order
channel = abs(channel - g.chans - 1);
% --- plotting individual bad region or area
if isempty(winrej)

    tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,channel,lowlim,highlim);
    plot(ax1,tmp_plot_data_y', 'color', tmpcolor, 'clipping','on');

else

    winrej2 = winrej( (winrej(:,1) >= lowlim) & (winrej(:,1) <= highlim) | ...
        (winrej(:,2) >= lowlim & winrej(:,2) <= highlim) | ...
        (winrej(:,1) <= lowlim & winrej(:,2) >= highlim),:);

    abscmin = max(1,round(winrej2(1,1)-lowlim));
    abscmax = round(winrej2(1,2)-lowlim);
    maxXlim = get(gca, 'xlim');

    plot(ax1,abscmin+1:abscmax+1,data(g.chans-channel+1,abscmin+lowlim:abscmax+lowlim) ...
        -meandata(g.chans-channel+1)+channel*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing), 'color',tmpcolor,'clipping','on')

end


% Redraw EEG and change position
% ---------------------------------
function draw_data(varargin)

    if nargin >= 3
        figh = varargin{3};
        %figure(figh);
    else
        figh = findobj('tag','eegplot_w3');
    end
    if strcmp(get(figh,'tag'),'dialog')
        figh = get(figh,'UserData');
    end
    
    if nargin >= 4
        p1 = varargin{4};
        if ~isnumeric(p1)
            p1 = 0;
        end
    else
        p1 = 0;
    end
    
    if nargin >= 5 % Children Object
        p2 = varargin{5};
    else
        p2 = [];
    end
    
    g = [];
    if nargin >= 6
        g = varargin{6};
    end
    if isempty(g)
        g = get(figh,'UserData');
    end
    if ~isfield(g,'trialstag')
        return;
    end
    
    ax1 = [];
    if nargin >= 7
        ax1 = varargin{7};
    end
    if isempty(ax1)
        ax1 = findobj('tag','eegaxis','parent',figh); % axes handle
    end
    
    if nargin >= 8
        custom_command = varargin{8};
    else
        custom_command = '';
    end
    
    % compare versions once, because it slows down drawing
    verLessThan_matlab_9 = ismatlab && verLessThan('matlab','9.0.0');
    
    %axes(ax1);
    data = get(ax1,'UserData');
    ESpacing  = findobj('tag','ESpacing', 'parent',figh); % ui handle
    EPosition = findobj('tag','EPosition','parent',figh); % ui handle
    if ~isempty(EPosition) && ~isempty(ESpacing)
        EPosition_new = str2num(get(EPosition,'string'));
        if ~isempty(EPosition_new)
            g.time = EPosition_new;
        end
        if g.trialstag(1) ~= -1
            g.time = g.time - 1;
        end
        g.spacing = str2num(get(ESpacing,'string'));
    end
    
    if ~isempty(custom_command)
        try eval(custom_command); catch, end;
    end
    
    switch p1
        case 1
        g.time = g.time-g.winlength;     % << subtract one window length
        case 2
        g.time = g.time-g.winlength/5;   % < subtract one second
        case 3
        g.time = g.time+g.winlength/5;   % > add one second
        case 4
        g.time = g.time+g.winlength;     % >> add one window length
        case 5
            tmpEEG = g.EEG;
            epoch = abs(tmpEEG.xmin - tmpEEG.xmax);
            if g.trialstag(1) ~= -1
                g.time = (g.time + 1) / epoch;
            else
                g.time = (g.time - 1) * epoch;
            end
        case 6
        g.time = g.time;
        case 7 
            tmpEEG = g.EEG;
            epoch = abs(tmpEEG.xmin - tmpEEG.xmax);
        if g.trialstag(1) ~= -1
            g.time = epoch*tmpEEG.trials;
        else
            g.time = tmpEEG.xmax;
        end
        case 8 
        g.time = 0;
        case 9
        data = g.data;
    end
    
    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end
    
    % Update edit box
    % ---------------
    g.time = max(0,min(g.time,ceil((g.frames-1)/multiplier)-g.winlength));
    if g.trialstag(1) == -1
        set(EPosition,'string',num2str(g.time)); 
    else 
        set(EPosition,'string',num2str(g.time+1)); 
    end
    set(figh, 'userdata', g);

    lowlim = round(g.time*multiplier+1);

    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));

    
    % Plot data and update axes
    % -------------------------
    switch lower(g.submean) % subtract the mean ?
        case 'on'
            if ~isempty(g.data2)
                meandata = nan_mean(g.data2(:,lowlim:highlim)');
            else
                meandata = nan_mean(data(:,lowlim:highlim)');
            end
        otherwise, meandata = zeros(1,g.chans);
    end
    
    if strcmpi(g.plotdata2, 'off')
        cla(ax1)
    end
    
    oldspacing = g.spacing;
    if g.envelope
        g.spacing = 0;
    end
    
    % plot data
    % ---------
    hold(ax1,'on')
    
%     if ~isfield(g.eloc_file, 'display')
%         for ii=1:length(g.eloc_file)
%             g.eloc_file(ii).display = 1;
%         end
%     end
    
    chans_list_bad=[];
    list_bad_chans=[];
    chans_list_good=[];
    chans_list_good2=[];
    if ~isfield(g, 'eloc_file')
        %chans_list_good=find([g.eloc_file.display]);
        %chans_list_good2=find([g.eloc_file.display]);
    else
        if isstruct(g.eloc_file) 
            if ~isfield(g.eloc_file, 'badchan')
                for ii=1:length(g.eloc_file)
                    g.eloc_file(ii).badchan = 0;
                end
            end

        chans_list_bad=g.chans-find([g.eloc_file.badchan])+1;
        chans_list_good=setdiff(1:g.chans,chans_list_bad);
        %chans_list_good2=find([g.eloc_file.display]);
        end
    end
    
    % plot channels whose "badchan" field is set to 1.
    % Bad channels are plotted first so that they appear behind the good
    % channels in the eegplot_w3 figure window.

    %THIS IS THE PLOT FUNCTION FOR CHANGING THE COLOR OF THE CHANNEL UGO
    % attempting to print the selected areas UGO LEFT HERE
    if ~isempty(g.winrej)
        
        % --- PLOT THE WHOLE DATA IN BLUE
        tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,chans_list_good2,lowlim,highlim);
        plot(ax1,tmp_plot_data_y', 'color', g.color{1}, 'clipping','on');
        % --- MAKE NEW LIMITS
        highlim2 = highlim;
        lowlim2 = lowlim;
        
        tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim,highlim);
        plot(ax1,tmp_plot_data_y', 'color', [1 0 0], 'clipping','on');
        chans_list_bad = [chans_list_bad,list_bad_chans];
        % plot the blue parts
        tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim,highlim2);
    else
         tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim,highlim);
         plot(ax1,tmp_plot_data_y', 'color', [ 1 0 0 ], 'clipping','on');  
    end
    
    %NORMAL PLOT RED LINE 
    
    if ~isempty(chans_list_bad)
        %tmp_plot_data_x=1:length(lowlim:highlim);
        tmp_plot_data_x=1:length(lowlim:highlim);
        tmp_plot_data_y=nan(length(chans_list_bad),length(lowlim:highlim));
        for ii = 1:length(chans_list_bad)
            i=chans_list_bad(ii);
            tmp_plot_data_y(ii,tmp_plot_data_x)=data(g.chans-i+1,lowlim:highlim) ...
                - meandata(g.chans-i+1) ...
                + i*g.spacing ...
                + (g.dispchans+1)*(oldspacing-g.spacing)/2 ...
                + g.elecoffset*(oldspacing-g.spacing);
        end

    end
    % REPLOT channels adjusting for channel errors 
    % SOMETHING IS OFF ABOUT THIS CODE?! INVESTIGATE IMMEDIATLY
    if ~isempty(chans_list_good)
        chans_list_good_N=length(chans_list_good);
        tmp_plot_data_x_N=length(lowlim:highlim);
        plot_at_once=2; % mode: 0, 1 or 2
        if strcmpi(g.plotdata2, 'on')
            tmpcolor = [ 1 0 0 ];
        elseif length(g.color) == 1
            tmpcolor = g.color{1};
            %tmpcolor = [ 1 0 0 ];
        else
            plot_at_once=0; % in this case only mode "0" allowed
        end
        switch plot_at_once
            case 1
                tmp_plot_data_x=1:tmp_plot_data_x_N;
                tmp_plot_data_y=nan(length(chans_list_good),tmp_plot_data_x_N);
            case 2
                tmp_plot_data_x= repmat([1:tmp_plot_data_x_N NaN],1,chans_list_good_N) ;
                tmp_plot_data_y= nan(1, chans_list_good_N*(tmp_plot_data_x_N+1));
        end
        for ii = 1:chans_list_good_N
            i=chans_list_good(ii);
            tmp_plot_data_y_i=data(g.chans-i+1,lowlim:highlim) ...
                - meandata(g.chans-i+1)+i*g.spacing ...
                + (g.dispchans+1)*(oldspacing-g.spacing)/2 ...
                + g.elecoffset*(oldspacing-g.spacing);
            switch plot_at_once
                case 0
                    tmpcolor = g.color{mod(g.chans-i,length(g.color))+1};
                    plot(tmp_plot_data_y_i, 'color', tmpcolor, 'clipping','on')
                case 1
                    tmp_plot_data_y(ii,tmp_plot_data_x)=tmp_plot_data_y_i;
                case 2
                    tmp_plot_data_y(1,(ii-1)*(tmp_plot_data_x_N+1)+[1:tmp_plot_data_x_N])=tmp_plot_data_y_i;
            end
        end
        switch plot_at_once
            case 1
                plot(ax1,tmp_plot_data_y', 'color', tmpcolor, 'clipping','on');
                %plot(ax1,tmp_plot_data_x,tmp_plot_data_y, 'color', tmpcolor, 'clipping','on');
            case 2
                plot(ax1,tmp_plot_data_x,tmp_plot_data_y, 'color', tmpcolor, 'clipping','on');
        end
    end
    
    % draw selected channels
    % ------------------------
    if ~isempty(g.winrej) && size(g.winrej,2) > 2
        winrej = g.winrej( (g.winrej(:,1) >= lowlim) & (g.winrej(:,1) <= highlim) | ...
            (g.winrej(:,2) >= lowlim & g.winrej(:,2) <= highlim) | ...
            (g.winrej(:,1) <= lowlim & g.winrej(:,2) >= highlim),:);

        for tpmi = 1:size(winrej,1) % scan rows

            abscmin = max(1,round(winrej(tpmi,1)-lowlim));
            abscmax = round(winrej(tpmi,2)-lowlim);
            maxXlim = get(gca, 'xlim');
            chanrej = find(winrej(tpmi,6:end));
            chanrej = abs(chanrej - g.chans - 1);
            for i = chanrej
                plot(ax1,abscmin+1:abscmax+1,data(g.chans-i+1,abscmin+lowlim:abscmax+lowlim) ...
                    -meandata(g.chans-i+1)+i*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing), 'color','r','clipping','on')
            end
        end
    end
    g.spacing = oldspacing;
    set(ax1, 'Xlim', [1 g.winlength*multiplier+1]);

    % ordinates: even if all elec are plotted, some may be hidden
    set(ax1, 'ylim',[g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] );
    
    if g.children ~= 0
        draw_data([],[],g.children,p1,p2);
        figure(figh);
    end

     % draw second data if necessary
     if ~isempty(g.data2)
         tmpdata = data;
         set(ax1, 'userdata', g.data2);
         g.data2 = [];
         g.plotdata2 = 'on';
         set(figh, 'userdata', g);
         draw_data([],[],figh,0,[],g,ax1);
         g.plotdata2 = 'off';
         g.data2 = get(ax1, 'userdata');
         set(ax1, 'userdata', tmpdata);
         set(figh, 'userdata', g);
     else 
         draw_background([],[],figh,g);
     end

%draw_matrix(g)



% Draw background
% ---------------------------------
function draw_background(varargin)

if nargin >= 3
    fig = varargin{3};
else
    fig = gcf;
end
if nargin >= 4
    g = varargin{4};
else
    g = get(fig,'UserData');  % Data (Note: this could also be global);
end
if ~isfield(g,'trialstag')
    return;
end

ax0 = findobj('tag','backeeg','parent',fig); % axes handle
ax1 = findobj('tag','eegaxis','parent',fig); % axes handle

% compare versions once, because it slows down drawing
verLessThan_matlab_9 = ismatlab && verLessThan('matlab','9.0.0');

% Plot data and update axes
if verLessThan_matlab_9
    axes(ax0); % changing axes very slows down drawing
end
cla(ax0);
hold(ax0,'on');
% plot rejected windows
if g.trialstag ~= -1
    multiplier = g.trialstag;
else
    multiplier = g.srate;
end

% draw rejection windows
% ----------------------
lowlim = round(g.time*multiplier+1);
highlim = round(min((g.time+g.winlength)*multiplier+1));
%displaymenu = findobj('tag','displaymenu','parent',gcf);
if ~isempty(g.winrej) && g.winstatus
%     if g.trialstag ~= -1 % epoched data
%         indices = find((g.winrej(:,1)' >= lowlim & g.winrej(:,1)' <= highlim) | ...
%             (g.winrej(:,2)' >= lowlim & g.winrej(:,2)' <= highlim));
%         if ~isempty(indices)
%             tmpwins1 = g.winrej(indices,1)';
%             tmpwins2 = g.winrej(indices,2)';
%             if size(g.winrej,2) > 2
%                 tmpcols  = g.winrej(indices,3:5);
%             else
%                 tmpcols  = g.wincolor;
%             end;
%             try    [cumul, indicescount] = histc(  tmpwins1, (min(tmpwins1)-1):g.trialstag:max(tmpwins2));
%             catch, [cumul, indicescount] = myhistc(tmpwins1, (min(tmpwins1)-1):g.trialstag:max(tmpwins2));
%             end;
%             count = zeros(size(cumul));
%             %if ~isempty(find(cumul > 1)), find(cumul > 1), end;
%             for tmpi = 1:length(tmpwins1)
%                 poscumul = indicescount(tmpi);
%                 heightbeg = count(poscumul)/cumul(poscumul);
%                 heightend = heightbeg + 1/cumul(poscumul);
%                 count(poscumul) = count(poscumul)+1;
%                 winrej = [tmpwins1(tmpi)-lowlim tmpwins2(tmpi)-lowlim ...
%                           tmpwins2(tmpi)-lowlim tmpwins1(tmpi)-lowlim];
%                 winheigh = [heightbeg heightbeg heightend heightend];
%                 patch_params = {winrej, winheigh, tmpcols(tmpi,:), 'EdgeColor', tmpcols(tmpi,:)};
%                 if verLessThan_matlab_9
%                     patch(patch_params{:});
%                 else
%                     patch(ax0, patch_params{:});
%                 end;
%             end;
%         end;
%    else
        event2plot1 = find ( g.winrej(:,1) >= lowlim & g.winrej(:,1) <= highlim );
        event2plot2 = find ( g.winrej(:,2) >= lowlim & g.winrej(:,2) <= highlim );
        event2plot3 = find ( g.winrej(:,1) <  lowlim & g.winrej(:,2) >  highlim );
        event2plot  = union_bc(union(event2plot1, event2plot2), event2plot3);
        
        for tpmi = event2plot(:)'
            if size(g.winrej,2) > 2
                tmpcols  = g.winrej(tpmi,3:5);
            else
                tmpcols  = g.wincolor;
            end
            winrej=[g.winrej(tpmi,1)-lowlim g.winrej(tpmi,2)-lowlim ...
                   g.winrej(tpmi,2)-lowlim g.winrej(tpmi,1)-lowlim];
            patch_params={winrej, [0 0 1 1], tmpcols, 'EdgeColor', tmpcols};
            if verLessThan_matlab_9
                patch(patch_params{:});
            else
                patch(ax0, patch_params{:});
            end
        end
%    end;
end

% plot tags
% ---------
%if trialtag(1) ~= -1 & displaystatus % put tags at arbitrary places
% 	for tmptag = trialtag
%		if tmptag >= lowlim & tmptag <= highlim
%			plot([tmptag-lowlim tmptag-lowlim], [0 1], 'b--');
%		end;
%	end;
%end;

% draw events if any
% ------------------
if strcmpi(g.plotevent, 'on')
    % JavierLC ###############################
    MAXEVENTSTRING = g.maxeventstring;
    if MAXEVENTSTRING<0
        MAXEVENTSTRING = 0;
    elseif MAXEVENTSTRING>75
        MAXEVENTSTRING=75;
    end
    % JavierLC ###############################
    AXES_POSITION = [0.05 0.03 0.865 1-(MAXEVENTSTRING-4)/100];
else % JavierLC
    AXES_POSITION = [0.05 0.03 0.865 0.94];
end

if ~isempty(g.events)
      if ischar(g.events(1).type)
          eventlist={g.events.type};
          evnt_groups=g.eventtypes;
      else
          eventlist=arrayfun(@(x) num2str(g.events(x).type), 1:length(g.events),'UniformOutput',false);
          evnt_groups=arrayfun(@(x) num2str(g.eventtypes(x)), 1:length(g.eventtypes),'UniformOutput',false);
      end
else
    eventlist={};
end
if strcmpi(g.plotevent, 'on') || ismember('boundary',eventlist)
    % find event to plot
    % ------------------
    event2plot    = find ( g.eventlatencies >=lowlim & g.eventlatencies <= highlim );
    if ~isempty(g.eventlatencyend)
        event2plot2 = find ( g.eventlatencyend >= lowlim & g.eventlatencyend <= highlim );
        event2plot3 = find ( g.eventlatencies  <  lowlim & g.eventlatencyend >  highlim );
        event2plot  = union_bc(union(event2plot, event2plot2), event2plot3);
    end
    [event2plot_ut,~,event2plot_uti]=unique_bc(eventlist(event2plot));
    if ~strcmpi(g.plotevent, 'on')
        event2plot=event2plot(find(ismember(eventlist(event2plot),{'boundary'})));
        event2plot_ut=eventlist(event2plot);
        event2plot_uti=ones(1,length(event2plot));
    end
    for evnt_group_idx_tmp=1:length(event2plot_ut)
        %Just repeat for the first one
        if evnt_group_idx_tmp == 1
            EVENTFONT = ' \fontsize{8} ';
            ylims=ylim(ax0);
        end
        evnt_group=event2plot_ut{evnt_group_idx_tmp};
        evnt_group_idx=find(ismember(evnt_groups,evnt_group));
        evnt_group_color = g.eventtypecolors{evnt_group_idx};
        event2plot_activ = event2plot(find(event2plot_uti==evnt_group_idx_tmp));
        
        % draw latency line
        % -----------------
        tmplat = g.eventlatencies(event2plot_activ)-lowlim-1; % [lat1 lat2]
        plot_x = reshape([ tmplat; tmplat; NaN(1,length(tmplat))], [1 3*length(tmplat)]); % [lat1 lat1 NaN lat2 lat2 NaN]
        plot_y = repmat([ylims NaN],1,length(tmplat));
        plot(ax0, plot_x, plot_y, ...
            'color', evnt_group_color,...
            'linestyle', g.eventtypestyle{evnt_group_idx}, ...
            'linewidth', g.eventtypewidths(evnt_group_idx));
        
        if ~strcmpi(g.plotevent, 'on')
            break;
        end
        % schtefan: add Event types text above event latency line
        % -------------------------------------------------------
        evntxt = strrep(evnt_group,'_','-');
        if length(evntxt)>MAXEVENTSTRING
            evntxt = [ evntxt(1:MAXEVENTSTRING-1) '...' ]; % truncate
        end
        for index = 1:length(event2plot_activ)
            tmplat1=tmplat(index);
            try
                text_prop={tmplat1, ylims(2)-0.005, [EVENTFONT evntxt], ...
                    'color', evnt_group_color, ...
                    'horizontalalignment', 'left',...
                    'rotation',90};
                if verLessThan_matlab_9
                    text(text_prop{:});
                else
                    text(ax0, text_prop{:});
                end
            catch
            end
            
            % draw duration is not 0
            % ----------------------
            if g.ploteventdur && ~isempty(g.eventlatencyend) ...
                    && g.eventtypewidths(evnt_group_idx) ~= 2.5 % do not plot length of boundary events
                tmplatend = g.eventlatencyend(event2plot_activ(index))-lowlim-1;
                if tmplatend ~= 0
                    tmplim = ylims;
                    patch_params = {[ tmplat1 tmplatend tmplatend tmplat1 ], ...
                        [ tmplim(1) tmplim(1) tmplim(2) tmplim(2) ], ...
                        evnt_group_color, ...  % this argument is color
                        'EdgeColor', 'none' };
                    if verLessThan_matlab_9
                        patch(patch_params{:});
                    else
                        patch(ax0, patch_params{:});
                    end
                end
            end
        end
    end
end

if g.trialstag(1) ~= -1
    
    % plot trial limits
    % -----------------
    tmptag = [lowlim:highlim];
    tmpind = find(mod(tmptag-1, g.trialstag) == 0);
    for index = tmpind
        plot(ax0, [tmptag(index)-lowlim-1 tmptag(index)-lowlim-1], [0 1], 'b--');
    end
    alltag = tmptag(tmpind);
    
    % compute Xticks
    % --------------
    tagnum = (alltag-1)/g.trialstag+1; % modified, added FLOOR to make sure epoched # displayed was correct. UGO
    set(ax0,'XTickLabel', tagnum,'YTickLabel', [],...
        'Xlim',[0 g.winlength*multiplier],...
        'XTick',alltag-lowlim+g.trialstag/2, 'YTick',[], 'tag','backeeg');
    
    tagpos  = [];
    if ~isempty(alltag)
        alltag = [alltag(1)-g.trialstag alltag alltag(end)+g.trialstag]; % add border trial limits % NEEDED to add -1 to g.trialstag to correct for display problems  UGO
    else
        alltag = [ floor(lowlim/g.trialstag)*g.trialstag ceil(highlim/g.trialstag)*g.trialstag ]+1;
    end
    
    nbdiv = 20/g.winlength; % approximative number of divisions
    divpossible = [ 100000./[1 2 4 5] 10000./[1 2 4 5] 1000./[1 2 4 5] 100./[1 2 4 5 10 20]]; % possible increments
    [~, indexdiv] = min(abs(nbdiv*divpossible-(g.limits(2)-g.limits(1)))); % closest possible increment
    incrementpoint = divpossible(indexdiv)/1000*g.srate;
    
    % tag zero below is an offset used to be sure that 0 is included
    % in the absicia of the data epochs
    if g.limits(2) < 0, tagzerooffset  = (g.limits(2)-g.limits(1))/1000*g.srate+1;
    else                tagzerooffset  = -g.limits(1)/1000*g.srate;
    end
    if tagzerooffset < 0, tagzerooffset = 0; end
    
    for i=1:length(alltag)-1
        if ~isempty(tagpos) && tagpos(end)-alltag(i)<2*incrementpoint/3
            tagpos  = tagpos(1:end-1);
        end
        if ~isempty(g.freqlimits)
            tagpos  = [ tagpos linspace(alltag(i),alltag(i+1)-1, nbdiv) ];
        else
            if tagzerooffset ~= 0
                tmptagpos = [alltag(i)+tagzerooffset:-incrementpoint:alltag(i)];
            else
                tmptagpos = [];
            end
            tagpos  = [ tagpos [tmptagpos(end:-1:2) alltag(i)+tagzerooffset:incrementpoint:(alltag(i+1)-1)]];
        end
    end
    
    % find corresponding epochs
    % -------------------------
    if ~g.isfreq
        tmplimit = g.limits;
        tpmorder = 1E-3;
    else
        tmplimit = g.freqlimits;
        tpmorder = 1;
    end
    tagtext = eeg_point2lat(tagpos, floor((tagpos)/g.trialstag)+1, g.srate, tmplimit,tpmorder);
    set(ax1,'XTickLabel', tagtext,'XTick', tagpos-lowlim);
%if g.trialstag(1) == -1
    else
    DEFAULT_GRID_SPACING = 10^ceil(log10(g.winlength)-1);
    if g.winlength / DEFAULT_GRID_SPACING < 2
        DEFAULT_GRID_SPACING = DEFAULT_GRID_SPACING / 2;
    end
    set(ax0,'XTickLabel', [],'YTickLabel', [],...
        'Xlim', [0 g.winlength*multiplier],...
        'XTick',[], 'YTick',[], ...
        'Position', AXES_POSITION);
    set(ax1,'Position', AXES_POSITION);
    if g.isfreq
        set(ax1,'XTick', [1:multiplier*DEFAULT_GRID_SPACING:g.winlength*multiplier+1]);
        set(ax1,'XTickLabel', num2str((g.freqs(1):DEFAULT_GRID_SPACING:g.freqs(end))'));
    else
        XTickStartSec = DEFAULT_GRID_SPACING*ceil(g.time/DEFAULT_GRID_SPACING);
        XTickStart = multiplier*(XTickStartSec-g.time) + 1;
        set(ax1,'XTick', [XTickStart:(multiplier*DEFAULT_GRID_SPACING):(g.winlength*multiplier+1)]);
        set(ax1,'XTickLabel', num2str((XTickStartSec:DEFAULT_GRID_SPACING:g.time+g.winlength)'));
    end
end
if verLessThan_matlab_9
    axes(ax1); % changing axes very slows down drawing
end

%draw_matrix(g);

% Redraw EEG and change window size
function change_eeg_window_length(~,~,fig,p1)
    g = get(fig,'UserData');
    switch p1
        case 0
            g.winlength = 5 ;
        case 1
            if g.trialstag==-1
                g.winlength = g.winlength * 0.8 ;
            else                
                g.winlength = max(1, g.winlength - 1) ;
            end
        case 2
            if g.trialstag==-1
                g.winlength = g.winlength * 1.25 ;
            else                
                g.winlength = g.winlength + 1 ;
            end
    end
	%set(fig, 'UserData', g);
	draw_data([],[],fig,0,[],g);


function change_scale(varargin)

    if nargin >= 3
        fig = varargin{3};
    else
        fig = gcf;
    end
%     if strcmp(get(fig,'tag'),'dialog')
%         fig = get(fig,'UserData');
%     end
    
    if nargin >= 4
        p1 = varargin{4};
        if ~isnumeric(p1)
            p1 = 0;
        end
    else
        p1 = 0;
    end
        
    if nargin >= 5
        ax1 = varargin{5};
    else
        ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
    end
    
    g = get(fig,'UserData');
    %g = THINKING(g,1);

    if ~isfield(g,'trialstag')
        return;
    end
    data = get(ax1, 'userdata');
    ESpacing = findobj('tag','ESpacing','parent',fig);   % ui handle
    EPosition = findobj('tag','EPosition','parent',fig); % ui handle
    if g.trialstag(1) == -1
        g.time = str2num(get(EPosition,'string'));  
    else 
        g.time = str2num(get(EPosition,'string'))-1;   
    end
    g.spacing = str2num(get(ESpacing,'string'));
    if isempty(g.spacing)
        g.spacing=0;
    end
    switch p1
        case 1
            g.spacing = g.spacing * 1.25;
        case 2
            g.spacing = max(0.005, g.spacing * 0.8);
        case 3
            g.spacing = 0;
        case 4 
            g.spacing = g.spacing;
    end
    if ismember(p1, [1 2])
        spacing_deka=10^(floor(log10(g.spacing))-1);
        g.spacing = spacing_deka*round(g.spacing/spacing_deka);
    end
    if round(g.spacing*100) == 0
        if g.spacing == 0
            g=optim_scale(data,g);
        else
            maxindex = min(10000, g.frames);
            g.spacing = 0.01*max(max(data(:,1:maxindex),[],2),[],1)-min(min(data(:,1:maxindex),[],2),[],1);  % Set g.spacingto max/min data
        end
    end
    %g = THINKING(g,0);
    % update edit box
    % ---------------
    set(ESpacing,'string',num2str(g.spacing,4))  
    %set(fig, 'userdata', g);
    draw_data([],[],fig,0,[],g);
    set(ax1,...
        'YTick', [0:g.spacing:g.chans*g.spacing],...
        'Ylim',  [g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] ); % 'YLim',[0 (g.chans+1)*g.spacing]
    
    % update scaling eye (I) if it exists
    % -----------------------------------
    eyeaxes = findobj('tag','eyeaxes','parent',fig);
    if ~isempty(eyeaxes)
      eyetext = findobj('type','text','parent',eyeaxes,'tag','thescalenum');
      set(eyetext,'string',num2str(g.spacing,4))
    end
    %g = THINKING(g,0);

% push mouse button
% ---------------------------------
function mouse_down(varargin)
fig = varargin{3};
%get(fig, 'SelectionType') % prints what selection has been done
if strcmp(get(fig, 'SelectionType'),'extend')
    eegplot_w3('topoplot', fig);
    return;
end
%show_mocap_timer = timerfind('tag','mocapDisplayTimer'); if ~isempty(show_mocap_timer),  end% nima
SelectionType=get(fig, 'SelectionType');
if ismember(SelectionType, {'normal', 'alt'})
    ax1 = findobj('tag','backeeg','parent',fig);
    tmppos = get(ax1, 'currentpoint');
    g = get(fig,'UserData'); % get data of backgroung image {g.trialstag g.winrej incallback}
    g.thinking = 0;
    %if g.thinking == 0
        if g.incallback ~= 1 % interception of nestest calls
            if g.trialstag ~= -1
                lowlim = round(g.time*g.trialstag+1);
                highlim = round(g.winlength*g.trialstag);
            else
                lowlim  = round(g.time*g.srate+1);
                highlim = round(g.winlength*g.srate);
            end
            if (tmppos(1) >= 0) && (tmppos(1) <= highlim)
                %g = TYPING(g,0);
                if isempty(g.winrej)
                    Allwin=0;
                else
                    Allwin = (g.winrej(:,1) < lowlim+tmppos(1)) & (g.winrej(:,2) > lowlim+tmppos(1));
                end
                if strcmp(SelectionType,'alt') || (any(Allwin) && g.setelectrode)
                    ax2 = findobj('tag','eegaxis','parent',fig);
                    tmppos = get(ax2, 'currentpoint');
                    tmpelec = g.chans + 1 - round(tmppos(1,2) / g.spacing);
                    tmpelec = min(max(tmpelec, 1), g.chans);
                end
                if strcmp(SelectionType,'alt')
                    if ~isempty(tmpelec)
                        MarkChannel([],[],fig,tmpelec,tmppos);
                    end
                else
                    if any(Allwin) % remove the mark or select electrode if necessary
                        lowlim = find(Allwin==1);
                        if g.setelectrode  % select electrode
                            g.winrej(lowlim,tmpelec+5) = ~g.winrej(lowlim,tmpelec+5); % set the electrode
                        else  % remove mark
                            g.winrej(lowlim,:) = [];
                            draw_data([],[],fig,0,[],g);
                        end
                    else
                        if g.trialstag ~= -1 % find nearest trials boundaries if epoched data
                            alltrialtag = [0:g.trialstag:g.frames]; % NEEDED FIXING, ADDED + 1 to count for trialstag variance
                            I1 = find(alltrialtag < (tmppos(1)+lowlim) );
                            if ~isempty(I1) && I1(end) ~= length(alltrialtag)
                                g.winrej = [g.winrej' [alltrialtag(I1(end))+1 (alltrialtag(I1(end)+1)) g.wincolor zeros(1,g.chans)]']';
                            end
                        else
                            g.incallback = 1;  % set this variable for callback for continuous data
                            if size(g.winrej,2) < 5
                                g.winrej(:,3:5) = repmat(g.wincolor, [size(g.winrej,1) 1]);
                            end
                            if size(g.winrej,2) < 5+g.chans
                                g.winrej(:,6:(5+g.chans)) = zeros(size(g.winrej,1),g.chans);
                            end
                            tmppos_x=mouse_near_boundary_correction(tmppos(1)+lowlim,g);
                            g.winrej = [g.winrej' [tmppos_x tmppos_x g.wincolor zeros(1,g.chans)]']';
                        end
                    end
                    set(fig,'UserData', g);
                    %draw_data([],[],fig,0,[],g);
                    draw_background([],[],fig,g); % redraw background
                end
            else
                %g = TYPING(g,1);
            end
        %end
    end
end

% release mouse button
% ---------------------------------
function mouse_up(varargin)
fig = varargin{3};
g = get(fig,'UserData');

%if g.thinking == 1

g.incallback = 0;
%set(fig,'UserData', g);  % early save in case of bug in the following
if strcmp(g.mocap,'on'), g.winrej = g.winrej(end,:);end % nima
if ~isempty(g.winrej)'
    if g.winrej(end,1) == g.winrej(end,2) % remove unitary windows
        g.winrej = g.winrej(1:end-1,:);
    else
        if g.winrej(end,1) > g.winrej(end,2) % reverse values if necessary
            g.winrej(end, 1:2) = [g.winrej(end,2) g.winrej(end,1)];
        end
        g.winrej(end,1) = max(1, g.winrej(end,1));
        g.winrej(end,2) = min(g.frames, g.winrej(end,2));
        if g.trialstag == -1 % find nearest trials boundaries if necessary
            I1 = find((g.winrej(end,1) >= g.winrej(1:end-1,1)) & (g.winrej(end,1) <= g.winrej(1:end-1,2)) );
            if ~isempty(I1)
                g.winrej(I1,2) = max(g.winrej(I1,2), g.winrej(end,2)); % extend epoch
                g.winrej = g.winrej(1:end-1,:); % remove if empty match
            else
                I2 = find((g.winrej(end,2) >= g.winrej(1:end-1,1)) & (g.winrej(end,2) <= g.winrej(1:end-1,2)) );
                if ~isempty(I2)
                    g.winrej(I2,1) = min(g.winrej(I2,1), g.winrej(end,1)); % extend epoch
                    g.winrej = g.winrej(1:end-1,:); % remove if empty match
                else
                    I2 = find((g.winrej(end,1) <= g.winrej(1:end-1,1)) & (g.winrej(end,2) >= g.winrej(1:end-1,1)) );
                    if ~isempty(I2)
                        g.winrej(I2,:) = []; % remove if empty match
                    end
                end
            end
        end
    end
end

g.winrej = sortrows(g.winrej,'ascend');

update_trial_rejections(g)

set(fig,'UserData', g);

draw_background([],[],fig,g);

if strcmp(g.mocap,'on')
    show_mocap_for_eegplot_w3(g.winrej); 
    g.winrej = g.winrej(end,:); 
end % nima
%end


% Function to show the value and electrode at mouse position
function mouse_motion(varargin)

try

fig = varargin{3};
%eegplot_w3('topoplot', fig);
% --- idea: make plot component headmap if mouse changes component?
ax0 = varargin{4};
try tmppos = get(ax0, 'currentpoint'); catch return; end
try g = get(fig,'UserData'); catch return; end

if iscell(g)
    g = g(1);
    g = g{:};
    set(fig,'UserData',g);
end
g.thinking = 0;
%if g.thinking == 0
    g.thinking = 1; % THIS IS THE FIX hopefully the damn error of mouse_motion
    set(fig,'UserData',g);
    if g.trialstag ~= -1
        lowlim = round(g.time*g.trialstag+1);
    else
        lowlim = round(g.time*g.srate+1);
        highlim = round(g.winlength*g.srate);
    end
    
    if g.incallback && g.trialstag == -1
        tmppos_x=mouse_near_boundary_correction(tmppos(1)+lowlim,g);
        g.winrej = [g.winrej(1:end-1,:)' [g.winrej(end,1) tmppos_x g.winrej(end,3:end)]']';
        set(fig,'UserData', g);
        if tmppos_x < lowlim - highlim * 0.03
            draw_data([],[],fig,2,[],g);
        elseif tmppos_x > lowlim + highlim * 1.03
            draw_data([],[],fig,3,[],g);
        else
            draw_background([],[],fig,g);
        end
    else
      hh = varargin{6}; % h = findobj('tag','Etime','parent',fig);
      if ~isnumeric(hh) && isobject(hh) && isvalid(hh)
        ax1 = varargin{5};% ax1 = findobj('tag','eegaxis','parent',fig);
        hv = varargin{7}; % hh = findobj('tag','Evalue','parent',fig);
        he = varargin{8}; % hh = findobj('tag','Eelec','parent',fig);  % put electrode in the box
        if g.trialstag ~= -1
            point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
        else
            point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
        end
        if point_is_valid
            %g = TYPING(g,0);
            if g.trialstag ~= -1
                tmpval = mod(tmppos(1)+lowlim-1,g.trialstag)/g.trialstag*(g.limits(2)-g.limits(1)) + g.limits(1);
                if g.isfreq, tmpval = tmpval/1000 + g.freqs(1); end
            else
                tmpval = (tmppos(1)+lowlim-1)/g.srate;
                if g.isfreq, tmpval = tmpval+g.freqs(1); end
            end
            set(hh, 'string', num2str(tmpval)); % put g.time in the box
        else
            %g = TYPING(g,1);
            set(hh, 'string', ' ');
        end
        if ~g.envelope && point_is_valid
            %g = TYPING(g,0);
            eegplotdata = get(ax1, 'userdata');
            if isempty(eegplotdata); return; end
            tmppos = get(ax1, 'currentpoint');
            tmpelec = round(tmppos(1,2) / g.spacing);
            tmpelec = min(max(double(tmpelec), 1),g.chans);
            labls = get(ax1, 'YtickLabel');
            set(hv, 'string', num2str(eegplotdata(g.chans+1-tmpelec, min(g.frames,max(1,double(round(tmppos(1)+lowlim)))))));  % put value in the box
            Class = '';
%             if issubfield(g,'EEG.etc.ic_classification.ICLabel.classifications') && g.EEG.plotchannels == 2
%                 Classification = g.EEG.etc.ic_classification.ICLabel.classifications(tmpelec,:);
%                 Classes = g.EEG.etc.ic_classification.ICLabel.classes;
%                 ClassName = Classes(ismember(Classification,max(Classification)));
%                 ClassName = ClassName{:};
%                 Percent = string(round(max(Classification)*100,1));
%                 Class = strcat({' '},ClassName,{' '},Percent,'%');
%             end
            set(he, 'string', strcat(labls(tmpelec+1,:),Class));
        else
            %g = TYPING(g,1);
            set(hv, 'string', ' ');
            set(he, 'string', ' ');
        end
        
      end
    %end
    
end
g.thinking = 0;
catch
    try g.thinking = 0; catch ;end
end

    
% Attract position to boundaries
function [tmppos_x]=mouse_near_boundary_correction(tmppos_x,g)
boundaries_lat=[0 g.frames] + 0.5;
if isfield(g,'eventtypes')
    if iscellstr(g.eventtypes)
        if ismember({'boundary'},g.eventtypes)
            boundaries_lat=unique([boundaries_lat ...
                g.eventlatencies(find(ismember({g.events.type},{'boundary'}))) ]);
        end
    end
end
[~,boundary_closest_id]=min(abs(boundaries_lat-tmppos_x));
boundary_closest_lat=boundaries_lat(boundary_closest_id);
if abs(boundary_closest_lat - tmppos_x) < (g.srate*g.winlength*0.02)
    tmppos_x=round(boundary_closest_lat);
elseif tmppos_x > boundaries_lat(end)
    tmppos_x = boundaries_lat(end);
end

% function not supported under Mac
% --------------------------------
function [reshist, allbin] = myhistc(vals, intervals)
reshist = zeros(1, length(intervals));
allbin = zeros(1, length(vals));
for index=1:length(vals)
    minvals = vals(index)-intervals;
    bintmp  = find(minvals >= 0);
    [~, indextmp] = min(minvals(bintmp));
    bintmp = bintmp(indextmp);
    
    allbin(index) = bintmp;
    reshist(bintmp) = reshist(bintmp)+1;
end

function g=optim_scale(data,g)
    maxindex = min(10000, g.frames);
	stds = std(data(:,1:maxindex),[],2);
    g.datastd = stds;
	stds = sort(stds);
	if length(stds) > 2
		stds = mean(stds(2:end-1));
	else
		stds = mean(stds);
	end
    g.spacing = stds*3;
    if g.spacing > 10
      g.spacing = round(g.spacing);
    end
    if g.spacing  == 0 || isnan(g.spacing)
        g.spacing = 1; % default
    elseif g.spacing > 1.9 && g.spacing < 10000
        optim_scale=[2 3 5 7 10 15 20 30 50 75 100 150 200 250 300 500 750 1000 1500 2000 2500 3000 10000];
        i=find(optim_scale > g.spacing);
        g.spacing = optim_scale(i(1));
    end

% Mouse scroll wheel
function mouse_scroll_wheel(~,eventdata,fig,varargin)
try
modifiers = get(fig,'currentModifier');
wheel_up=eventdata.VerticalScrollCount < 0;
if wheel_up
    if ismember('shift',modifiers)
        draw_data([],[],fig,1);
    elseif ismember('control',modifiers)
        change_eeg_window_length([],[],fig,2);
    elseif ismember('alt',modifiers)
        change_scale([],[],fig,1);
    else
        draw_data([],[],fig,2);
    end
else
    if ismember('shift',modifiers)
        draw_data([],[],fig,4);
    elseif ismember('control',modifiers)
        change_eeg_window_length([],[],fig,1);
    elseif ismember('alt',modifiers)
        change_scale([],[],fig,2);
    else
        draw_data([],[],fig,3);
    end
end
if nargin > 3
    %mouse_motion([],[],fig,varargin{:});
end
catch return; end

function normalize_chan(~,~,fig)
g = get(fig,'userdata');
if g.normed
    disp('Denormalizing...');
else
    disp('Normalizing...'); 
end
hmenu = findobj(fig, 'Tag', 'Normalize_menu');
hbutton = findobj(fig, 'Tag', 'Norm');
ax1 = findobj('tag','eegaxis','parent',fig);
data = get(ax1,'UserData');

EEG = g.EEG;

% if EEG.plotchannels == 1
%     g.datastd = std(EEG.data(:,1:min(1000,g.frames)),[],2); 
% else
%     g.datastd = std(EEG.icaact(:,1:min(1000,g.frames)),[],2); 
% end

if isempty(g.datastd) %|| size(g.data,1) ~= size(g.datastd,1)
    %data(:,1:min(1000,g.frames));
    g.datastd = std(data(:,1:min(1000,g.frames)),[],2); 
end

%     if ~isfield(g,'oldspacing')
%         g.oldspacing = 0;
%     end
if g.normed == 1
    for i = 1:size(data,1)
        
        data(i,:,:) = data(i,:,:)*g.datastd(i);
        
        if ~isempty(g.data2)
            g.data2(i,:,:) = g.data2(i,:,:)*g.datastd(i);
        end
    end
    set(hbutton,'string', 'Norm');
    set(findobj('tag','ESpacing','parent',fig),'string',num2str(g.oldspacing));
else
    g.datastd = std(data(:,1:min(1000,g.frames)),[],2); 
    
    % because of interpolation, a few channels std will be 0, which makes
    % bizarre data display. This substitute the chanel std for the avg std of
    % all channels
    
    if any(g.datastd < 0.001)
       g.datastd(find(g.datastd < 0.001)) = mean(g.datastd);
    end

    for i = 1:size(data,1)
        
        data(i,:,:) = data(i,:,:)/g.datastd(i);
        if ~isempty(g.data2)
            g.data2(i,:,:) = g.data2(i,:,:)/g.datastd(i);
        end
    end
    set(hbutton,'string', 'Denorm');
    g.oldspacing = g.spacing;
end

g.normed = 1 - g.normed;
%change_scale([],[],fig,0,ax1);
set(hmenu, 'Label', fastif(g.normed,'Denormalize channels','Normalize channels'));
set(fig,'userdata',g);
set(ax1,'UserData',data);
%eegplot_w3('setelect');
draw_data([],[],fig,0,[],g,ax1);

disp('Done.');

%THIRD MOUSE BUTTON
function MarkChannel(~,~,fig,channel_index,tmppos)
if nargin < 4
    tmppos = 0;
end

g=get(fig,'UserData');

% COPIED THIS PORTION FROM MOUSEMOVEMENT FUNCTION -- UGO MODS
if g.trialstag ~= -1 % time in second or in trials
    multiplier = g.trialstag;
else
    multiplier = g.srate;
end

% gets low and high limits of the page
lowlim = round(g.time*multiplier+1);
highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
% makes sure click is in valid position
if g.trialstag ~= -1
    point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
else
    point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
end
% if valid, gets temporary TIME value within the displayed eeg window 
if point_is_valid
    %if g.trialstag ~= -1
    %    tmpval = mod(tmppos(1)+lowlim-1,g.trialstag)/g.trialstag*(g.limits(2)-g.limits(1)) + g.limits(1);
    %    if g.isfreq, tmpval = tmpval/1000 + g.freqs(1); end
    %else
        tmpval = (tmppos(1)+lowlim-1);%/g.srate; %COMMENTED THIS OUT
        if g.isfreq, tmpval = tmpval+g.freqs(1); end
    %end
    %set(hh, 'string', num2str(tmpval)); % put g.time in the box
else
    %set(hh, 'string', ' ');
    tmpval = 0;
end

%HOW TO GET THE WINREJ TO GET THE CHANNELS IN IT, IN AND OUT

if isempty(g.command)
    clear global in_callback; return;
end

if isfield(g, 'eloc_file')
    %make sure to recreate the badchannel option in the channel struct
    if ~isfield(g.eloc_file, 'badchan')
        for ii=1:length(g.eloc_file)
            g.eloc_file(ii).badchan = 0;
        end
    end
    
    % UGO MODS
    
    if channel_index ~= 0
    % badchan is a dummy variable which makes sure only channels selected
    % for complete rejection and added to g.eloc_file.badchan 
    % new FAST code
    % --- Creates empty variables
    rejection_indexes = [];
    winrej = [];
    tmpcolor = g.color{1};

    % if winrej for this channel is empty

    if ~isempty(g.winrej)
        % Checks for click within a rejection window

        rejection_indexes = tmpval >= g.winrej(:,1) & tmpval <= g.winrej(:,2); % get epoch index(es), if any

        % CHECKS FOR MOUSE POSITION WITHIN A REJECTION STRETCH
        if any(rejection_indexes)
            epoch_id = find(rejection_indexes); %get selected epoch number
            winrej = g.winrej(epoch_id,:); % get winrej
            winrej(channel_index+5) = 1 - winrej(channel_index+5); % changes the number from 1 to 0 or vice-versa
            g.winrej(epoch_id,:) = winrej; % alters the original winrej
            if winrej(channel_index+5) == 1
                tmpcolor = [1 0 0]; % makes color red if channel is rejected
            end
        end
    end

    if ~any(rejection_indexes)
        % no rejection was previously there, so rejects the epoch
        g.eloc_file(channel_index).badchan = 1-g.eloc_file(channel_index).badchan; % changes the number from 1 to 0 or vice-versa

        if g.eloc_file(channel_index).badchan == 1
            tmpcolor = [1 0 0]; % makes color red if channel is rejected
        end
    end
    
    
    % removes all repetitive marks
    %g.winrej = merge_trials(g.winrej);

    % new FAST code
    set(fig,'UserData',g);
    
    %draw_data([],[],fig,0,[],g); % draws data
    
    draw_data2(gcf,g,channel_index,winrej,tmpcolor)
    %draw_matrix(g); % draws matrix
    end
end

function MarkChannel2(~,~,fig,channel_index) %MarkChannel original for BACKUP!
g=get(fig,'UserData');
%channel_index=get(channel_obj,'userdata')
if isempty(g.command)
    clear global in_callback; return;
end
if isfield(g, 'eloc_file')
    if ~isfield(g.eloc_file, 'badchan')
        for ii=1:length(g.eloc_file)
            g.eloc_file(ii).badchan = 0;
        end
    end
    g.eloc_file(channel_index).badchan = 1-g.eloc_file(channel_index).badchan;
    %set(fig,'UserData',g);
    draw_data([],[],fig,0,[],g);
    draw_matrix(g);

end

function MarkChannel3(fig)

ax1 = findobj('tag','backeeg','parent',fig);
tmppos = get(ax1, 'currentpoint');
g = get(fig,'UserData'); % get data of backgroung image {g.trialstag g.winrej incallback}

if g.incallback ~= 1 % interception of nestest calls
    if g.trialstag ~= -1
        lowlim = round(g.time*g.trialstag+1);
        highlim = round(g.winlength*g.trialstag);
    else
        lowlim  = round(g.time*g.srate+1);
        highlim = round(g.winlength*g.srate);
    end
    if (tmppos(1) >= 0) && (tmppos(1) <= highlim)
        if isempty(g.winrej)
            Allwin=0;
        else
            Allwin = (g.winrej(:,1) < lowlim+tmppos(1)) & (g.winrej(:,2) > lowlim+tmppos(1));
        end
        %if any(Allwin) && g.setelectrode
            ax2 = findobj('tag','eegaxis','parent',fig);
            tmppos = get(ax2, 'currentpoint');
            tmpelec = g.chans + 1 - round(tmppos(1,2) / g.spacing);
            tmpelec = min(max(tmpelec, 1), g.chans);
        %end
        if ~isempty(tmpelec)
            %MarkChannel2([],[],fig,tmpelec,tmppos);
            %g = get(fig,'UserData');
            %channel_index=get(channel_obj,'userdata')
            if isempty(g.command)
                clear global in_callback; return;
            end
            if isfield(g, 'eloc_file')
                if ~isfield(g.eloc_file, 'badchan')
                    for ii=1:length(g.eloc_file)
                        g.eloc_file(ii).badchan = 0;
                    end
                end
                g.eloc_file(tmpelec).badchan = 1-g.eloc_file(tmpelec).badchan;
                %set(fig,'UserData',g);
                draw_data([],[],fig,0,[],g);
                draw_matrix(g);

            end
        end
    end
end

function eegplot_readkey(~,evnt,varargin)
try
if nargin >= 3
    fig = varargin{1};
else
    fig = gcf;
end
g = get(fig,'UserData');

%if g.thinking == 0
    g.thinking = 1;
    ax1 = findobj('tag','backeeg','parent',fig);
    ax2 = findobj('tag','eegaxis','parent',fig);

    modifiers = get(fig,'currentModifier');
    switch evnt.Key
        case 'pageup'
            draw_data([],[],fig,1,[],g);
        case 'leftarrow'
            draw_data([],[],fig,2,[],g);
        case 'rightarrow'
            draw_data([],[],fig,3,[],g);
        case 'pagedown'
            draw_data([],[],fig,4,[],g);
        case {'home' 'end'}
            EPosition = findobj('tag','EPosition','parent',fig);
            id=find(ismember({'home' 'end'},evnt.Key));
            if g.trialstag == -1
                limi=[g.limits(1)/1000 ceil(g.limits(2)/1000-g.winlength)];
            else
                limi=[1 1 + g.frames/g.trialstag - g.winlength];
            end
            set(EPosition,'string',num2str(limi(id)));
            draw_data([],[],fig,0,[],g);
        case 'uparrow'
            if ismember('control',modifiers)
                change_eeg_window_length([],[],fig,2);
            elseif ismember('alt',modifiers)
                change_scale([],[],fig,1);
            end
        case 'downarrow'
            if ismember('control',modifiers)
                change_eeg_window_length([],[],fig,1);
            elseif ismember('alt',modifiers)
                change_scale([],[],fig,2);
            end
        case {'insert'} %CHANGED UGO
            eegplot_w3('window');

        case {'tab'}
            eegplot_w3('winelec');

        case {'z'} % MARK FULL CHANNEL FOR INTERPOLATION, REGARDLESS OF EPOCH STATUS
            %plot_topoplot_CHANNEL(fig,evnt.Key)
            MarkChannel3(fig)

        case {'v'} % VARIANCE
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'b'} % STD DEV
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'n'} % ABS MEAN
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'m'} % LOG
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'l'} % EXPONENTIAL
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'s'} % CHANGE REJECTION MODE
            eegplot_w3('rejection')

        case {'a'} % GO BACK
            draw_data([],[],fig,1,[],[])

        case {'d'} % GO FORWARD
            draw_data([],[],fig,4,[],[])

        case {'t'} % GO FORWARD
            eegplot_w3('TBT')

%         case {'y'}% TAG AND SAVE
%             eegplot_w3('SAVE')

        case {'q'} % GO back to beginning
            draw_data([],[],fig,8,[],[])

%         case {'`'}
%             %g = THINKING(g,0);
%             set(gcf,'UserData',g);

        case {'r'}
            normalize_chan([],[],gcf);

        case {'e'} % GO FORWARD to end
            draw_data([],[],fig,7,[],[])

        case {'w'} % GO FORWARD to end
            eegplot_w3('SWITCH')

        case {'p'}
            %g = THINKING(g,0);

        case {'x'}
            change_scale([],[],fig,1,ax2)

        case {'c'}
            change_scale([],[],fig,2,ax2)

    end
    if nargin > 3
        %mouse_motion([],[],varargin{:})
    end
%else
%     ax1 = findobj('tag','backeeg','parent',fig);
%     ax2 = findobj('tag','eegaxis','parent',fig);
% 
%     modifiers = get(fig,'currentModifier');
%     switch evnt.Key
%         case 'u'
%             %g = THINKING(g,0);
%             set(gcf,'UserData',g);
%     end
%end
g.thinking = 0;

catch g.thinking = 0; return;
end


% Created this function to facilitate drawing and plotting channels, Ugo 2021

function [tmp_y] = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim,highlim)

tmp_x=1:length(lowlim:highlim);
tmp_y=nan(length(chans_list_bad),length(lowlim:highlim));
warning('off');
for ii = 1:length(chans_list_bad)
    i=chans_list_bad(ii);
    tmp_y(ii,tmp_x)=data(g.chans-i+1,lowlim:highlim) ...
        - meandata(g.chans-i+1) ...;
        + i*g.spacing ...;
        + (g.dispchans+1)*(oldspacing-g.spacing)/2 ...
        + g.elecoffset*(oldspacing-g.spacing);
    
end

function plot_topoplot(fig)

g = get(fig,'UserData');
EEG = g.EEG;

if EEG.plotchannels == 1
    if ~isstruct(g.eloc_file) || ~isfield(g.eloc_file, 'theta') || isempty( [ g.eloc_file.theta ])
        return;
    end
    ax1 = findobj('tag','backeeg','parent',fig);
    tmppos = get(ax1, 'currentpoint');
    ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
    % plot vertical line
    %yl = ylim(ax1);
    %plot(ax1, [ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end
    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
    % makes sure click is in valid position

    if g.trialstag ~= -1
        point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
    else
        point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
    end
    if point_is_valid
        data = get(ax1,'UserData');
        datapos = max(1, round(tmppos(1)+lowlim));
        datapos = min(datapos, g.frames);
        
        axes('Parent', fig, 'position',g.headpos,'units','normalized');

        % get color
        BackColor = get(fig,'Color');

        Printed = 0;
        % plot topo % it changes the background color of the figure to EEGLAB's default
        %topoplot(data(:,datapos), g.eloc_file);
        if ~isempty(g.winrej)
            % LOOPS FOR EVERY STRETCH OF REJECTION
            for k=1:size(g.winrej,1)

                % CHECKS FOR MOUSE POSITION WITHIN A REJECTION STRETCH
                if datapos >= g.winrej(k,1) && datapos <= g.winrej(k,2)
                    % Calculates the average for that stretch
                    EpochAverage = mean(data(:,g.winrej(k,1):g.winrej(k,2)),2);
                    %EpochAverage = std(data(:,g.winrej(k,1):g.winrej(k,2)),0,2);
                    MeanDeviation = mean(EpochAverage);
                    EpochAverage = EpochAverage - MeanDeviation;
                    % PLOTS AVERAGE OF THAT STRETCH
                    topoplot(EpochAverage, g.eloc_file);
                    % This makes sure it only prints once
                    Printed = 1;
                    break;
                end
            end
            if ~Printed
                % if no prints have been done, then there's no matching
                % rejected areas, therefore prints normal topoplot for that
                % column
                topoplot(data(:,datapos), g.eloc_file);
            end
        else
            topoplot(data(:,datapos), g.eloc_file);
        end

        % set background color back to whatever it was before.
        set(fig,'Color',BackColor);
    end
else
    %     ax1 = findobj('tag','backeeg','parent',fig);
    %     tmppos = get(ax1, 'currentpoint');
    ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
    tmppos = get(ax1, 'currentpoint');
    % plot vertical line
    %yl = ylim(ax1);
    %plot(ax1, [ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end
    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
    % makes sure click is in valid position

    if g.trialstag ~= -1
        point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
    else
        point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
    end
    if point_is_valid
        tmpelec = g.chans + 1 - round(tmppos(1,2) / g.spacing);
        tmpelec = min(max(tmpelec, 1), g.chans);

        %labls = get(ax1, 'YtickLabel');
        %component = str2num(labls(tmpelec+1,:));

        pop_prop_extended2(EEG, 0, tmpelec,'NaN',{'freqrange', [2 55]});
    end
end
%     if g.trialstag == -1
%          latsec = (datapos-1)/g.srate;
%          title(sprintf('Latency of %d seconds and %d milliseconds', floor(latsec), round(1000*(latsec-floor(latsec)))));
%     else
%         trial = ceil((datapos-1)/g.trialstag);
%         latintrial = eeg_point2lat(datapos, trial, g.srate, g.limits, 0.001);
%         title(sprintf('Latency of %d ms in trial %d', round(latintrial), trial));
%     end

function plot_topoplot_CHANNEL(fig,button)

if nargin < 2
    button = {'b'};
end

g = get(fig,'UserData');
EEG = g.EEG;

%if EEG.plotchannels == 1
    if ~isstruct(g.eloc_file) || ~isfield(g.eloc_file, 'theta') || isempty( [ g.eloc_file.theta ])
        g.eloc_file = EEG.chanlocs(:);
        %return;
    end
    ax1 = findobj('tag','backeeg','parent',fig);
    tmppos = get(ax1, 'currentpoint');
    ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
    % plot vertical line
    %yl = ylim(ax1);
    %plot(ax1, [ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end
    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
    % makes sure click is in valid position

    if g.trialstag ~= -1
        point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
    else
        point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
    end
    if point_is_valid
        data = get(ax1,'UserData');
        datapos = max(1, round(tmppos(1)+lowlim));
        datapos = min(datapos, g.frames);
        
        colormap("default")
        ax_pic = findobj('tag','topo');
        ax_matrix = findobj('tag','figure');

%         if isempty(ax_pic)
%             ax_pic = axes('Parent', gcf, 'position',g.matrixpos,'units','normalized','tag','topo','XTickLabel',{[]},'YTickLabel',{[]},Color=[.93 .96 1]);
%         else
%             %delete(ax_pic,ax_matrix);
             ax_pic = axes('Parent', gcf, 'position',g.matrixpos,'units','normalized','tag','topo','XTickLabel',{[]},'YTickLabel',{[]},Color=[.93 .96 1]);
%         end
        % get color
        BackColor = get(fig,'Color');

        Printed = 0;
        % plot topo % it changes the background color of the figure to EEGLAB's default
        %topoplot(data(:,datapos), g.eloc_file);
        if ~isempty(g.winrej)
            % LOOPS FOR EVERY STRETCH OF REJECTION
            %for k=1:size(g.winrej,1)
            print_id = datapos >= g.winrej(:,1) & datapos <= g.winrej(:,2);
                % CHECKS FOR MOUSE POSITION WITHIN A REJECTION STRETCH
                if any(print_id)
                    rej_part = find(print_id);
                    % Calculates the averageb for that stretch
                    switch button
                        case 'v'
                        EpochAverage = var(EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2)),0,2);
                        set(findobj(gcf,'Tag','headmap'),'String','Variance');

                        case 'b'
                        EpochAverage = std((EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2))),0,2);
                        set(findobj(gcf,'Tag','headmap'),'String','Std. Dev.');
                        
                        case 'n'
                        EpochAverage = mean(abs(EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2))),2);
                        set(findobj(gcf,'Tag','headmap'),'String','Abs. Mean');
                        
                        case 'm'
                        EpochAverage = mean(log10(abs(EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2)))),2);
                        set(findobj(gcf,'Tag','headmap'),'String','log Mean');

                        case 'l'
                        EpochAverage = mean(exp(EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2))),2);
                        set(findobj(gcf,'Tag','headmap'),'String','exp Mean');
                    end
                    MeanDeviation = mean(EpochAverage);
                    EpochAverage = EpochAverage - MeanDeviation;
                    % PLOTS AVERAGE OF THAT STRETCH
                    colormap("default")
                    topoplot(EpochAverage, EEG.chanlocs(:));
                    %set(topo,'tag','topo');
                    % This makes sure it only prints once
                    Printed = 1;
                    %break;
                end
            %end
            if ~Printed
                % if no prints have been done, then there's no matching
                % rejected areas, therefore prints normal topoplot for that
                % column
                %
                colormap("default")
                topoplot(EEG.data(:,datapos), EEG.chanlocs(:));
                %set(topo,'tag','topo');
            end
        else
            colormap("default")
            topoplot(EEG.data(:,datapos), EEG.chanlocs(:));
            set(topo,'tag','topo');
        end
        
        % set background color back to whatever it was before.
        set(fig,'Color',BackColor);
    end


function plot_topoplot_old(fig)
    %fig = varargin{1};
    g = get(fig,'UserData');
    EEG = g.EEG;
    
    if EEG.plotchannels == 1
    if ~isstruct(g.eloc_file) || ~isfield(g.eloc_file, 'theta') || isempty( [ g.eloc_file.theta ])
        return;
    end
    ax1 = findobj('tag','backeeg','parent',fig); 
    tmppos = get(ax1, 'currentpoint');
    ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
    % plot vertical line
    %yl = ylim(ax1);
    %plot(ax1, [ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end
    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
    % makes sure click is in valid position
    
    if g.trialstag ~= -1
        point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
    else
        point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
    end
    if point_is_valid
        data = get(ax1,'UserData');
        datapos = max(1, round(tmppos(1)+lowlim));
        datapos = min(datapos, g.frames);
        axes('Parent', fig, 'position',g.headpos,'units','normalized');
        % get color
        BackColor = get(fig,'Color');
        
        % plot topo % it changes the background color of the figure to EEGLAB's default
        topoplot(data(:,datapos), g.eloc_file);
        
        % set background color back to whatever it was before.
        set(fig,'Color',BackColor);
    end
    else
%     ax1 = findobj('tag','backeeg','parent',fig); 
%     tmppos = get(ax1, 'currentpoint');
    ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
    tmppos = get(ax1, 'currentpoint');
    % plot vertical line
    %yl = ylim(ax1);
    %plot(ax1, [ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end
    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
    % makes sure click is in valid position
    
    if g.trialstag ~= -1
        point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
    else
        point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
    end
    if point_is_valid
        tmpelec = g.chans + 1 - round(tmppos(1,2) / g.spacing);
        tmpelec = min(max(tmpelec, 1), g.chans);
        
        %labls = get(ax1, 'YtickLabel');
        %component = str2num(labls(tmpelec+1,:));
        
        pop_prop_extended2(EEG, 0, tmpelec,'NaN',{'freqrange', [2 55]});
    end
    end
%     if g.trialstag == -1
%          latsec = (datapos-1)/g.srate;
%          title(sprintf('Latency of %d seconds and %d milliseconds', floor(latsec), round(1000*(latsec-floor(latsec)))));
%     else
%         trial = ceil((datapos-1)/g.trialstag);
%         latintrial = eeg_point2lat(datapos, trial, g.srate, g.limits, 0.001);
%         title(sprintf('Latency of %d ms in trial %d', round(latintrial), trial));
%     end

%% These functions below are brand new, to be used by the new METHODS section

    function change_list(x,y)
        g = get(gcf,'UserData');
        list = findobj(gcf,'tag', 'ListPopup');

        choice = list.Value;
        
        met = findobj(gcf,'tag', 'ALLmethods');
        opt = findobj(gcf,'tag', 'ALLoptions');
        hint = findobj(gcf,'tag', 'ALLhints');
        switch choice
            case 1
                met.String = g.tbtmethods;
                g.currentooptions = g.tbtoptions;
            case 2
                met.String = g.eegmethods;
                g.currentooptions = g.eegoptions;
            case 3
                met.String = g.iclmethods;
                g.currentooptions = g.icloptions;
        end
        met.Value = 1;
        set(gcf,'UserData',g);
        change_options(x,y);
    
    function change_options(x,y)
        g = get(gcf,'UserData');
        
        list = findobj(gcf,'tag', 'ListPopup');
        
        met = findobj(gcf,'tag', 'ALLmethods');
        opt = findobj(gcf,'tag', 'ALLoptions');
        hint = findobj(gcf,'tag', 'ALLhints');
        
        current = g.currentooptions;
       
        try opt(1).String = current{met(1).Value}; catch, end
        try hint(1).String = current{met(1).Value,2};catch, end
    
    function g = methods(g)

        g = get(gcf,'UserData');
        %set(gcf,'UserData',g);
        
        list = findobj(gcf,'tag', 'ListPopup');

%         if ~isfield(g,'old')
%             if isempty(g.old)
%                 g.old{1} = g;
%                 g.gnumber = 1;
%             end
%         end
        %g = THINKING(g,1);
        %g.old(end) = g;
        set(gcf,'UserData',g);

        switch list.Value
            case 1
                g = TBT(g);
            case 2
                g = QUICKLAB(g);
            case 3
                g = ICLABEL(g);
        end
        
        %g = THINKING(g,0);
       %set(gcf,'Color',[g.backcolor]);
%         
%         g.old{end+1} = g;
%         g.gnumber = length(g.old);

        g = make_eloc_file(g);
        set(gcf,'UserData',g);
        eegplot_w3('setelect');
        eegplot_w3('winelec_auto');
        draw_matrix(g);

function g = SWITCH(g)
    
    g = get(gcf,'UserData');
    if ~isempty(g.EEG.icaact)
    %g = THINKING(g,1);

    EEG = g.EEG;
    ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle

    if EEG.plotchannels == 1 
        g.EEG.plotchannels = 0;

        g.eloc_file_ch = g.eloc_file;
        g.eloc_file = g.eloc_file_pc;

        g.datastd_ch = g.datastd;
        g.datastd = g.datastd_pc;

        if g.normed == 1
            normalize_chan([],[],gcf)
        end

        g.winrej_ch = g.winrej;
        g.winrej = g.winrej_pc;
        
        g.data = EEG.icaact;
        g.chans = size(EEG.icaact,1);
        g.spacing = 0;
        fprintf('Showing ICA data \r');
    else
        g.EEG.plotchannels = 1;

        g.eloc_file_pc = g.eloc_file;
        g.eloc_file = g.eloc_file_ch;

        g.datastd_pc = g.datastd;
        g.datastd = g.datastd_ch;
    
        if g.normed == 1
            normalize_chan([],[],gcf)
        end

        g.winrej_pc = g.winrej;
        g.winrej = g.winrej_ch;
        
        g.spacing = 0;
        g.data = EEG.data;
        g.chans = EEG.nbchan;
        fprintf('Showing EEG data \r');
    end

    %g = THINKING(g,0);
    %g.normed = 0;
    %g = make_eloc_file(g);
    %set(gcf,'Color',g.backcolor);
    set(gcf,'UserData',g);
    set(ax1,'UserData',g.data);
    
    draw_data([],[],gcf,9,[],g);
    
    eegplot_w3('winelec_auto');
    draw_matrix(g);
    %change_scale(ax1,gcf,1);
    end

function g = APPLY(g)

    g = get(gcf,'UserData');
    %g = THINKING(g,1); %blocks all clicks and movements to avoid crashes and errors

    EEG = g.EEG;

    %store current g in backup g.old
%     if ~isfield(g,'old')
%         g.old = {};
%         g.old{1} = {g};
%         g.gnumber = 1;
%     else
%         g.old{end+1} = g;
%         g.gnumber = length(g.old);
%     end
    
    set(gcf,'UserData',g); %store info in the plot
    
    if ~isfield(g.eloc_file, 'badchan')
        for ii=1:length(g.eloc_file)
            g.eloc_file(ii).badchan = 0;
        end
    end
    
    EEG.save = 1;
    EEG.ICA = 0;
    if g.EEG.plotchannels
        g.winrej_ch = g.winrej;
        applycom_ch = 'NEW=EEG;[NEW LASTCOM1] = eeg_eegrej2(NEW,g.winrej,1,find([g.eloc_file.badchan])); ' ; %modified for eegrej2
        eval(applycom_ch);
    else
        g.winrej_pc = g.winrej;
        applycom_pc = 'NEW=EEG;[NEW LASTCOM1] = eeg_eegrej2(NEW,g.winrej,2,find([g.eloc_file.badchan])); ' ; %modified for eegrej2
        eval(applycom_pc);
%         if isempty(NEW.icaact)
%             NEW.icaact = (NEW.icaweights*NEW.icasphere)*NEW.data(NEW.icachansind,:);
%         end
        %g = SWITCH(g);
        %g.EEG.icaact = []; g.EEG.icawinv = []; g.EEG.icasphere = []; g.EEG.icaweights = []; g.EEG.icachansind = [];
    end
    % collect new EEG
    g.EEG = NEW;
    % clear winrej variables of the new file
    g.winrej = [];
    g.winrej_pc = [];
    g.winrej_ch = [];
    % clear suffix
    g.EEG.suffix = [];
    set( findobj(gcf,'tag','SaveNowText'),'String','');
    % reset norm
    g.normed = 1;
    
    % get correct data
    if isfield(EEG,'plotchannels')
        %fastif(EEG.plotchannels,g.data = g.EEG.data;g.data = g.EEG.icaact;)
        if EEG.plotchannels == 1
            g.data = g.EEG.data;
        else
            g.data = g.EEG.icaact;
        end
    end
    
    % make new eloc_file based on new channels/components
    g = make_eloc_file(g);
    % turn on mouse movement and key presses
    %g = THINKING(g,0);
    
    % save new backup
%     g.old{end+1} = g;
%     g.gnumber = g.gnumber +1;
    
    % make suffix, store the bool of a NEW vs OLD data.

    fprintf('Rejections applied to new dataset');

    set(gcf,'UserData',g);
    [g.EEG] = eeg_store([], g.EEG);
    ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
    set(ax1,'UserData',g.data);
    draw_matrix(g);
    %draw_data([],[],gcf,9,[],g);
    eegplot_w3('winelec_auto');

    
function g = UNDO(g)

g = get(gcf,'UserData');
%g = THINKING(g,1);
%set(gcf,'Color',[0 0 .8]);

EEG = g.EEG;
% 
% if isfield(g,'old')
% 
%     % get number of gs stored.
%     if ~isfield(g,'gnumber')
%         g.gnumber = size(g.old,2);
%         tempgnumber = size(g.old,2);
%     else
%         tempgnumber = g.gnumber;
%     end
%     if tempgnumber > 1
%         tempgs = g.old; %collect all gs
%         g = tempgs{tempgnumber-1}; % get end-1 g
%         %try g = g{:}; catch; end % remove it from cell if inside cell
%         g.gnumber = tempgnumber-1; % correctly name it as the end-1 g.
%         g.old = tempgs;
% 
%         set(gcf,'UserData',g);
%         ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
% 
%         if isfield(g.EEG,'plotchannels')
%             if g.EEG.plotchannels == 1
%                 g.data = g.EEG.data;
%             else
%                 g.data = g.EEG.icaact;
%             end
%         end
%         g = make_eloc_file(g);
%         
%         set(ax1,'UserData',g.data);
%         draw_data([],[],gcf,9,[],g);
%         eegplot_w3('winelec_auto');
%         %g = THINKING(g,0);
%         draw_matrix(g);
%     end
% end
%g = THINKING(g,0);
%set(gcf,'Color',g.backcolor);

function g = REDO(g)
% 
% g = get(gcf,'UserData');
% %g = THINKING(g,1);
% %set(gcf,'Color',[0 0 .8]);
% EEG = g.EEG;
% 
% if isfield(g,'old')
%     % get number of gs stored.
%     if ~isfield(g,'gnumber')
%         g.gnumber = size(g.old,1);
%         tempgnumber = size(g.old,1);
%     else
%         tempgnumber = g.gnumber;
%     end
%     if tempgnumber < size(g.old,2)
%         tempgs = g.old; %collect all gs
%         g = tempgs{tempgnumber+1}; % get end-1 g
%         g.gnumber = tempgnumber+1; % correctly name it as the end-1 g.
%         g.old = tempgs;
%         g.EEG.plotchannels = EEG.plotchannels;
% 
%         set(gcf,'UserData',g);
%         ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
%     
%         if isfield(EEG,'plotchannels')
%             if EEG.plotchannels == 1
%                 g.data = g.EEG.data;
%             else
%                 g.data = g.EEG.icaact;
%             end
%         end
%         g = make_eloc_file(g);
%         
%         set(ax1,'UserData',g.data);
%         draw_data([],[],gcf,9,[],g);
%         eegplot_w3('winelec_auto');
%         draw_matrix(g);
%     end
% end

%g = THINKING(g,0);
%set(gcf,'Color',g.backcolor);


   function g = ICLABEL(g)

   g = get(gcf,'UserData');
   EEG = g.EEG;
   % set parameters
   if EEG.plotchannels == 1
       g = SWITCH(g);
   end

   g.EEGpre = EEG;
   if ~isfield(g,'NEW')
       g.NEW = [];
   end
   % get methods
   method = findobj(gcf,'tag', 'ALLmethods');
   options = findobj(gcf,'tag', 'ALLoptions');
   nbadchans = findobj(gcf,'tag', 'TBTnchans');
   pctbadtrial = findobj(gcf,'tag', 'TBT%');
   mybadcomps = [];
   % run methods
   [NEW] = pop_iclabel(EEG, 'default');

   opt = str2num(options(1).String);

   switch method(1).Value
       case 1
           [NEW] = pop_par_icflag(NEW, [NaN NaN;opt(1) opt(2);opt(1) opt(2);opt(1) opt(2);opt(1) opt(2);opt(1) opt(2);NaN NaN]);
       case 2
           [NEW] = pop_par_icflag(NEW, [opt(1) opt(2);NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
       case 3
           [NEW] = pop_par_icflag(NEW, [NaN NaN;opt(1) opt(2);NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
       case 4
           [NEW] = pop_par_icflag(NEW, [NaN NaN;NaN NaN;opt(1) opt(2);NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
       case 5 
           [NEW] = pop_par_icflag(NEW, [NaN NaN;NaN NaN;NaN NaN;opt(1) opt(2);NaN NaN;NaN NaN;NaN NaN]);
       case 6
           [NEW] = pop_par_icflag(NEW, [NaN NaN;NaN NaN;NaN NaN;NaN NaN;opt(1) opt(2);NaN NaN;NaN NaN]);
       case 7
           [NEW] = pop_par_icflag(NEW, [NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN;opt(1) opt(2);NaN NaN]);
       case 8
           [NEW] = pop_par_icflag(NEW, [NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN;opt(1) opt(2)]);
   end

   % store new data in .NEW and .EEG
   g.EEG = NEW;
   %g.NEW = NEW;

   if EEG.plotchannels == 1
       g = SWITCH(g);
   end

   mybadcomps = find(NEW.reject.gcompreject);
   if ~isempty(mybadcomps)
       for ind = 1:size(mybadcomps)
           g.eloc_file(mybadcomps(ind)).badchan = 1; % marks channels as bad
       end
   end

   % make suffix, store the bool of a NEW vs OLD data.
   g.EEG.suffix = 'IcL';
   fprintf('Showing Tagged ICLABEL dataset');
  
   % store and draw data
   set(gcf,'UserData',g);
   ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
   %set(ax1,'UserData',g);

   draw_data([],[],gcf,0,[],g);
   draw_matrix(g);
   eegplot_w3('setelect');


   function g = QUICKLAB(g)

   g = get(gcf,'UserData');
   EEG = g.EEG;
   if ~isfield(g,'NEW')
       g.NEW = [];
   end
   % get methods
   method = findobj(gcf,'tag', 'ALLmethods');
   options = findobj(gcf,'tag', 'ALLoptions');
   nbadchans = findobj(gcf,'tag', 'TBTnchans');
   pctbadtrial = findobj(gcf,'tag', 'TBT%');
   opt = options.String;
   if isempty(opt)
       opt = '[]';
   end
   % run methods
   suffix = '';
   com = '';
   display_eeg_or_ica = 1; % if 1 EEG, if 2 ICA
   switch method(1).Value
       case 1
           newcom = ['[NEW] = quick_PCA(EEG,' opt ');'];
           %NEW = quick_PCA(EEG,[],'binica',0);
           suf = str2num(opt(1:4));
           if isempty(suf)
               suffix = 'ICA';
           else
               suffix = strcat('PCA',num2str(suf));
           end
           display_eeg_or_ica = 2;
       case 2
           newcom = [strcat('[NEW,com] = quick_bss2(EEG,', opt, ');')];
           suffix = 'BSS';
       case 3
           newcom = [strcat('[NEW,com] = quick_reref(EEG,', opt, ');')];
           suffix = strcat('ref',opt);
       case 4
           newcom = ['[NEW,com] = quick_HM94(EEG);'];
           suffix = 'HM94';
       case 5 
           newcom = [strcat('[NEW,com] = quick_epoch(EEG,', opt, ');')];
           suffix = 'Ep6';
       case 6
           newcom = '[NEW,com] = quick_dotloc(EEG)';
           %suffix = 'Hm92Ep6bssICA';
       case 7
           newcom = '[NEW,com] = quick_bss2(EEG);[NEW,com] = quick_PCA(NEW,[],[],0);';
           suffix = 'BSSICA';
   end
    
   eval(newcom);
   % store new data in .NEW and .EEG
   
   g.EEG = NEW;
   if ~isfield(g.EEG,'suffix'); g.EEG.suffix = ''; end

   currsuf = get(findobj(gcf,'tag','SaveNowText'),'String');
   set( findobj(gcf,'tag','SaveNowText'),'String',strcat(currsuf,suffix));
   g.EEG.suffix = strcat(g.EEG.suffix,suffix);
   
   %g.NEW = NEW;
    
   if g.EEG.plotchannels == 1
       g.data = NEW.data;
   else
       if ~isempty(NEW.icaact)
           g.data = NEW.icaact;
       else
           g = SWITCH(g);
       end
   end
   %GET ICA DATA AS WELL

   % make new eloc_file based on new channels/components
   g = make_eloc_file(g);
   g.winrej = []; g.winrej_pc = []; g.winrej_ch = [];

   % make suffix, store the bool of a NEW vs OLD data.
   fprintf(strcat('Showing processed dataset after running:', newcom, com, '/r'));
  
   % store and draw data
   set(gcf,'UserData',g);
   ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
   set(ax1,'UserData',g.data);

   draw_data([],[],gcf,9,[],g);
   eegplot_w3('setelect');
   eegplot_w3('winelec_auto');

    function g = TBT(g)
        % This function was adapted from TBT plugin by 
        g = get(gcf,'UserData');
        EEG = g.EEG;

        % storing old data
        g.EEGpre = EEG;
        g.winrejPRE = g.winrej;

        if EEG.plotchannels ~= 1
            icacomp = '0';
            chancomps = '1:size(EEG.icaact,1)';
            ica = 'ica'; 
        else
            icacomp = '1';
            chancomps = '1:EEG.nbchan';
            ica = ''; 
        end
        method = findobj(gcf,'tag', 'ALLmethods');
        options = findobj(gcf,'tag', 'ALLoptions');
        nbadchans = findobj(gcf,'tag', 'TBTnchans');
        pctbadtrial = findobj(gcf,'tag', 'TBT%');
        
        switch method(1).Value

            case 1
                opt = options(1).String;
                g = detect_flatline(g);
                update_trial_rejections(g);
                return;
            case 2
                comrej  = ['EEG = pop_eegthresh(EEG, ' icacomp ',' chancomps ',' options(1).String ', 1, 0);'];
                chosen_func    = 'rejthreshE';
            case 3
                comrej  = ['[EEG, comrej] = pop_rejtrend(EEG, ' icacomp ', ' chancomps ',' options(1).String ', 1, 0,0);'];
                chosen_func    = 'rejconstE';
            case 4
                comrej  = ['[EEG, ~,~,~,comrej] = pop_jointprob(EEG, ' icacomp ', ' chancomps ',' options(1).String ', 1, 0, 0);'];
                chosen_func    = 'rejjpE';
            case 5
                comrej  = ['[EEG, ~,~,~,comrej] = pop_rejkurt(EEG, ' icacomp ', ' chancomps ',' options(1).String ', 1, 0, 0);'];
                chosen_func    = 'rejkurtE';
            case 6
                comrej  = ['[EEG, ~, comrej]    = pop_rejspec(EEG, ' icacomp ',' options(1).String , ',''elecrange'',' chancomps ');'];
                chosen_func    = 'rejfreqE';
            case 7
                comrej  = ['[EEG, comrej]    = pop_eegmaxmin(EEG,' options(1).String ');'];
                chosen_func    = 'rejmaxminE';
                ica = ''; %rejmaxminE doesn't have options for ICA
            case 8
                comrej = ['[EEG,comrej] = pop_eegchannelpop(EEG,' icacomp ',' chancomps ',' options(1).String ');'];
                chosen_func = 'rejchanpops';
        end
        
        fprintf(strcat('Running function:',comrej)); % Prints function being run
        % RUN FUNCTION!
        eval(comrej);
        
        winrej = EEG.reject.(strcat(ica,chosen_func)); % Gets rejected data into winrej
%         
%         if ~isempty(winrej)
%            winrej = winrej | g.winrej(:,6:end);
%         end
            
        %% Find bad trials and Channels
        
        % Find channels that have been marked as bad in more than X% of trials:
        channel_index       = sum(winrej,2)/EEG.trials >= str2double(pctbadtrial(1).String)/100;   % boolean list
        % if sum(channel_index)
        %     bChan_lab           = EEG.chanlocs(channel_index).labels;     % Channel label list
        %     nbadchan            = length(bChan_lab);                    % count bad channels
        %     %winrej(channel_index,:)   = 1;                                    % mark for plotting
        % else
        %     bChan_lab = [];
        %     nbadchan = 0;
        % end
        if ~isfield(g.eloc_file, 'badchan')
            for ii=1:length(g.eloc_file)
                g.eloc_file(ii).badchan = 0;
            end
        end
        
        % Collects rejected trials BUG
        if sum(channel_index)
            badchannels = find(channel_index);
            for ind = badchannels'
                g.eloc_file(ind).badchan = 1; % marks channels as bad
                % removes these channels from trial rejections!
                winrej(ind,:) = 0;
            end
        end
        
        % Find trial with more than X bad channels:
        trials_ind  = 1:EEG.trials;
        bTrial_ind  = sum(winrej,1) >= str2double(nbadchans(1).String);     % boolean list
        bTrial_num  = trials_ind(bTrial_ind);	% trial list
        nbadtrial   = length(bTrial_num);       % count bad trials
        
        % trying to combine the trials
%         old_bad_trials = find(g.winrej(:,3) == 1 & g.winrej(:,4) ~= 1)';
%         old_chan_interp = find(g.winrej(:,4) == 1 & g.winrej(:,3) ~= 1)';
%         
        % Paints rejections red-ish and interpolations green-ish
        if ~isempty(winrej)
            mark                    = ones([0,5] + size(winrej'));
            mark(:,6:end)           = double(winrej');
            mark(:,1)               = 1:EEG.pnts:EEG.pnts*EEG.trials;   % start sample
            mark(:,2)               = mark(:,1)+EEG.pnts-1;               % end   sample

            mark(bTrial_ind,3)      = 1;                                % R for bad trials
            mark(bTrial_ind,4)      = 0.8;                              % G for bad trials
            mark(bTrial_ind,5)      = 0.9;                              % B for bad trials
            
            mark(~bTrial_ind,3)      = 0.7;                              % R for bad chans
            mark(~bTrial_ind,4)      = 1;                                % G for bad chans
            mark(~bTrial_ind,5)      = 0.8;                              % B for bad chans
            

            % paints the trials with empty selected channels white
            %mark((sum(mark(:,5:end),2) < 1),3:5) = 1;                    % cleaner code compared with the for loop
            mark((sum(mark(:,5:end),2) < 1),:) = [];                    % cleaner code compared with the for loop
            
            % clean non-rejected trials from winrej.
            %mark((sum(mark(:,5:end),2) < 1),3:5) = 1
%             for i=size(mark,1):-1:1
%                 if ~sum(mark(i,6:end))
%                     mark(i,3:5) = 1; % paint their background white!
%                 end
%             end
            
            % collects all marks and adds to g.winrej
             %try 
                 % combines previous g.winrej with new marks
             %    g.winrej(:,6:end) = g.winrej(:,6:end) | mark(:,6:end);
                 % combine the paints of greens, reds and whites.
                 %mark(mark(:,3:5) == [1,0.8,0.9])
                 %not greens)

             %catch
            g.winrej = [g.winrej;mark];
             %end

            % --- Updating and organizing winrej
            g.winrej = unique(g.winrej,'rows');
            g.winrej = sortrows(g.winrej,'ascend');
            g.winrej = merge_trials(g.winrej); 
            % --- storing new winrej
            g.winrejNEW = g.winrej;
            update_trial_rejections(g);
           
        end
       

function update_trial_rejections(g)
%% this function updates the tags for trial rejection and partial interpolations
%g = get(gcf,'UserData');

% calculate total numbers of rejections and interpolations
g.winrej = sortrows(g.winrej,'ascend');

reds = num2str(0);
greens = num2str(0);
bad_chans = num2str(0);
partial_interps = num2str(0);

% removes all repetitive marks
g.winrej = unique(g.winrej,'rows');

if ~isempty(g.winrej)
    % calculate reds and greens using RGB 'R' (3) and 'G' (4)
    reds = num2str(sum(g.winrej(:,3) == 1));
    greens = num2str(sum(g.winrej(:,4) == 1));

% gets total sum of bad channels and partial interpolations
if ~isfield(g.eloc_file, 'badchan')
    for ii=1:length(g.eloc_file)
        g.eloc_file(ii).badchan = 0;
    end
end
    try bad_chans = num2str(sum([g.eloc_file.badchan])); catch; end
    partial_interps = num2str(sum(sum(g.winrej(find(g.winrej(:,4) == 1),6:end),2))); %finds greends, get columns sum, get total sum
end
% creates strings for printing
total_chanmarks = strcat('Chan: ',{' '},bad_chans,' +',{' '}, partial_interps, ' p','art');
total_marks = strcat('Trial: ',{' '},reds,' red + ',{' '}, greens, ' g','reen');

% prints on menu using these tags
set(findobj(gcf, 'Tag', 'Count_Channels'),'string',total_chanmarks);%
set(findobj(gcf, 'Tag', 'Count_Trials'),'string',total_marks);%
draw_matrix(g);




function tf = issubfield(S,FIELD)
    % Posted by Geoff McVittie on Matlab Answers on https://www.mathworks.com/matlabcentral/answers/103924-is-it-possible-to-check-for-existence-of-fields-in-nested-structures-with-isfield-in-matlab-8-1-r20
%ISSUBFIELD Determine if FIELD is valid in struct S
%   Determine if the specified FIELD or nested FIELD is present in the
%   given structure.
%
%   A.b.c.d = 1;
%   issubfield(A,"b.c.d")       % TRUE
%   issubfield(A,"b")           % TRUE
%   issubfield(A,"b.c.d.e")     % FALSE
%   issubfield(A,"f")           % FALSE
% arguments
%      S (1,1)  = struct
%      FIELD (1,1)  = string
% end
SUBFIELD = strsplit(FIELD,'.');
if numel(SUBFIELD) == 1
    tf = isfield(S,FIELD);
    return;    
end
tf = true;
for i = 2:numel(SUBFIELD)    
    S = S.(SUBFIELD(i-1));
    if ~isfield(S,SUBFIELD(i))
        tf = false;
        break;
    end
end


function winrej_merged = merge_trials(winrej)
    %% merges repetitive regions rejection 
    
    % get bollean list of repetitive 
    % merge
    % make it red if X, green if > 1, delete if empty;
    winrej_merged = [];
    og_winrej = winrej;
    counter = 0;

    winrej = sortrows(winrej,'ascend');
        
    for i = 1:size(winrej,1)
        if size(winrej,1) < i-counter
            break;
        else
        %try
            copies = winrej( winrej(:,1) == winrej(i-counter,1) & winrej(:,2) == winrej(i-counter,2),: );
        %catch
        %    break;
        %end
        if size(copies,1) > 1
            %fullcopies = rejlist(rejlist(:,1) == copies(1),:);

            new_rej_row      = zeros(1,size(winrej,2));
            new_rej_row(1,1:2) = copies(1,1:2);
            new_rej_row(1,3:5) = copies(1,3:5);                              % R for bad chans

            %for j = 1:size(copies,1)-1
                
            %templist(1,6:end) = copies(j,6:end) | copies(j+1,6:end);
            
            % --- collects aany flagged channels in this trial
            new_rej_row(6:end) = any(copies(:,6:end));

            % --- gets any of the copies that is red, if any
            anyreds = copies(copies(1:size(copies,1),3) == 1,3:5);

            % --- if any of the flagged channels are red, paint new flag red
            if size(anyreds,1) > 0 
                new_rej_row(3:5) = anyreds(1,:);
            end
            %end
            %--- merges the new line in the new flags
            winrej_merged = [winrej_merged;new_rej_row];
            
            % --- adds number of flagged copies to counter
            counter = counter + size(copies,1)-1;
            winrej(winrej(:,1) == copies(1),:) = [];
        else
            winrej_merged = [winrej_merged;copies];
        end
        end
    end
   
    
    %% not used!
function g = storemarks(g)
        
   if isstruct(EEG)
       g.EEG = EEG;
       if isempty(g.winrej)
           % makes an empty array of winrej
%            g.winrej                    = zeros(EEG.trials,5+EEG.nbchan);
%            g.winrej(:,1)               = 1:EEG.pnts:EEG.pnts*EEG.trials;   % start sample
%            g.winrej(:,2)               = g.winrej(:,1)+EEG.pnts-1;               % end   sample
%            g.winrej(:,3:5) = 1;
%            
           if EEG.plotchannels == 1
               if isfield(EEG,'chanrej')
                   g.winrej = EEG.chanrej;
               end
           else
               if isfield(EEG,'comprej')
                   g.winrej = EEG.comprej;
               end
           end
       end
   end

function g = detect_flatline(g,max_flatline_duration,max_allowed_jitter)
   % modified from cleanline plugin
   % Copyright (C) Christian Kothe, SCCN, 2012, ckothe@ucsd.edu

   EEG = g.EEG;
   if nargin < 2
       max_flatline_duration = 5;
       max_allowed_jitter = 0.1;
   end
   for c = 1:EEG.nbchan
       zero_intervals = reshape(find(diff([false abs(diff(EEG.data(c,:)))<(max_allowed_jitter) false])),2,[])';
       if max(zero_intervals(:,2) - zero_intervals(:,1)) > max_flatline_duration*EEG.srate
           g.eloc_file(c).badchan = 1;
       end
   end

function g = detect_channelpop(g,max_num_changes,min_threshold)
   % modified from cleanline plugin
   % Copyright (C) Christian Kothe, SCCN, 2012, ckothe@ucsd.edu

   EEG = g.EEG;
%    if ica
%    winrej = zeros(size(EEG.nbchan,EEG))
%    
%    else
% 
%    end
   ipt = [];
   for i=1:size(EEG.icaact,1)
        for j=1:size(EEG.icaact,2)
            [ipt,res] = findchangepts(EEG.icaact(i,j,:),"MaxNumChanges",max_num_changes,"MinThreshold",min_threshold,"MinDistance",minDistance)
        if ~isempty(ipt)
            winrej(i,j) = 1;
        end
        end
   end


%     merged_list = [];
%     for i = 1:size(list,1)
%         if list(i,1:5) == list(i+1,1:5)
%             list(i,6:end) = list(i,6:end) | list(i+1,6:end);
%         end
%     end

 %% plotting matrix

function draw_matrix(g)
% --- get EEG data
EEG = g.EEG;
First = 0;

% --- make axis for plot
ax_pic_topo = findobj('tag','topo');
ax_pic = findobj('tag','matrix_axis');

if ~isempty(ax_pic_topo)
    delete(ax_pic_topo);
    First = 1;
end

if isempty(ax_pic)
    First = 1;
    ax_pic = axes('Parent', gcf, 'position',g.matrixpos,'units','normalized','tag','matrix_axis','XTickLabel',{[]},'YTickLabel',{[]},Color=[.93 .96 1]);
end
hold on; % not sure if necessary

% --- making empty matrix
%if EEG.plotchannels
    plot_matrix = zeros(g.chans,EEG.trials);
%else
%    plot_matrix = zeros(size(g.eloc_file,1),EEG.trials);
%end

plot_matrix = plot_matrix - 10;

if ~isempty(g.winrej)
    winrej = g.winrej;

    %% paints red trials
    % --- check for red trials
    rej_winrej = winrej(winrej(:,3) == 1,:);
    
    if ~isempty(rej_winrej)
        rej_epoch_id = floor(1+rej_winrej(:,1)/EEG.pnts); % gets all red epochs

        % --- paint rej epochs 
        plot_matrix(:,rej_epoch_id) = 20; % populates them with a color

        nb_rejs = size(rej_epoch_id,1);
        rej_parts = rej_winrej(:,6:end);
        
        if ~isempty(rej_epoch_id)
            for i=1:nb_rejs
                if nb_rejs > 1
                    rej_parts2 = find(rej_parts(i,:));
                else
                    rej_parts2 = find(rej_parts);
                end
                % --- paint specific trial-epoch regions
                rej_parts2 = abs((rej_parts2 -1) - g.chans); % flips the array
                %% Paints matrix
                plot_matrix(rej_parts2,rej_epoch_id(i)) = 1; % paints the matrix!
            end
        end

    end
    %% paints green trials
    % --- check for green trials
    int_winrej = winrej(winrej(:,4) == 1,:);
    
    if ~isempty(int_winrej)
        int_epoch_id = floor(1+int_winrej(:,1)/EEG.pnts); % gets all red epochs

        % --- paint int epochs 
        plot_matrix(:,int_epoch_id) = 10; % populates them with a color

        nb_ints = size(int_epoch_id,1);
        int_parts = int_winrej(:,6:end);
        
        if ~isempty(int_epoch_id)
            for i=1:nb_ints
                if nb_ints > 1
                    int_parts2 = find(int_parts(i,:));
                else
                    int_parts2 = find(int_parts);
                end
                int_parts2 = abs((int_parts2 - 1) - g.chans); % flips the array
                % --- paint specific trial-epoch regions
                %% Paints matrix
                plot_matrix(int_parts2,int_epoch_id(i)) = 1;
            end
        end

    end
end
%% Paints bad channels
if ~isfield(g.eloc_file, 'badchan')
    for ii=1:length(g.eloc_file)
        g.eloc_file(ii).badchan = 0;
    end
end
bad_chans_flip = find([g.eloc_file.badchan]); % gets bad channels/components

if ~isempty(bad_chans_flip)
%     if g.EEG.plotchannels
        bad_chans = [abs((bad_chans_flip - 1) - g.chans )]; % flips the array
%     else
%         %bad_chans = [abs(bad_chans - size(g.eloc_file,2))]; % flips the array
%     end
%     if ~isempty(bad_chans)
        %for i=bad_chans_flip
            plot_matrix(bad_chans,:) = 3; % Paints matrix
        %end
    %end
end

    %% plots image
    if First
        matrix_pic = imagesc(ax_pic,plot_matrix);
        set(matrix_pic,'tag','matrix')
        axis tight;
        xticks(ax_pic,EEG.trials);
        yticks(ax_pic,size(g.eloc_file,2));
        %% defining colors and axis
        % 1st,     2nd,   3rd,   4th,   5th
        % darkblue, black, yellow, green, red
        % background, ticks, channels, greens, reds
        mymap = [.5 .5 .8; 0 0 0; 1 1 0; 0 1 0; 1 0 0]; % color map of matrix
        colormap(mymap) % applies new colors
        clim('manual'); % makes color limits manual,
        clim(ax_pic,[-10,20]); % fixes color patterns so that alwasy plots the same colors

        % makes axis tight to bounderies, filling full space
        %lim = clim %for debugging

        %title = get(findobj(gcf,'tag','headmap'),'String');
        set(findobj(gcf,'tag','headmap'),'String','Data Matrix');
    else
        set(findobj(gcf,'tag','headmap'),'String','Data Matrix');
        matrix_pic = findobj('tag','matrix');
        set(matrix_pic,'CData',plot_matrix);
        %repeat coloring and axes to avoid issues.
%         mymap = [.5 .5 .8; 0 0 0; 1 1 0; 0 1 0; 1 0 0]; % color map of matrix
%         xticks(ax_pic,EEG.trials);
%         yticks(ax_pic,size(g.eloc_file,2));
%         colormap(mymap) % applies new colors
%         clim('manual'); % makes color limits manual,
%         clim(ax_pic,[-10,20]); % fixes color patterns so that alwasy plots the same colors
    end


% %% prepare figure turned into a function!
% 
% function [ax0, ax1, figh] = prepare_figure(g,data)
% icadefs;
% [DEFAULT_PLOT_COLOR,DEFAULT_FIG_COLOR,BUTTON_COLOR,DEFAULT_AXIS_COLOR,DEFAULT_GRID_SPACING, DEFAULT_AXES_POSITION, DEFAULT_GRID_STYLE, SPACING_EYE,ORIGINAL_POSITION] = get_defaults(g);
%   figh = figure('UserData', g,... % store the settings here
%       'Color',DEFAULT_FIG_COLOR, 'name', g.title,...
%       'MenuBar','none','tag', g.tag ,'Position',g.position, ...
%       'numbertitle', 'off', 'visible', 'off', 'Units', 'Normalized',...
%       'interruptible', 'off', 'busyaction', 'cancel');
%   if strcmp(g.fullscreen,'on')
%       figh.WindowState = 'maximized';
%       %set(figh,'OuterPosition',[0 0 1 1]);
%   end
%   pos = get(figh,'position'); % plot relative to current axes
%   q = [pos(1) pos(2) 0 0];
%   s = [pos(3) pos(4) pos(3) pos(4)]./100;
%   clf;
%   
%   % Plot title if provided
%   if ~isempty(g.plottitle)
%       h = findobj('tag', 'eegplottitle'); 
%       if ~isempty(h)
%           set(h, 'string',g.plottitle);
%       else
%           h = textsc(g.plottitle, 'title'); 
%           set(h, 'tag', 'eegplottitle');
%       end
%   end
%       
%   % Background axis
%   % --------------- 
%   ax0 = axes('tag','backeeg','parent',figh,...
%       'Position',DEFAULT_AXES_POSITION,...
%       'Box','off','xgrid','off', 'xaxislocation', 'top', 'Units', 'Normalized'); 
% 
%   % Drawing axis
%   % --------------- 
%   YLabels = num2str((1:g.chans)');  % Use numbers as default
%   YLabels = flipud(char(YLabels,' '));
%   ax1 = axes('Position',DEFAULT_AXES_POSITION,...
%       'userdata', data, ...% store the data here
%       'tag','eegaxis','parent',figh,...%(when in g, slow down display)
%       'Box','on','xgrid', g.xgrid,'ygrid', g.ygrid,...
%       'gridlinestyle',DEFAULT_GRID_STYLE,...
%       'Xlim',[0 g.winlength*g.srate],...
%       'xtick',[0:g.srate*DEFAULT_GRID_SPACING:g.winlength*g.srate],...
%       'Ylim',[0 (g.chans+1)*g.spacing],...
%       'YTick',[0:g.spacing:g.chans*g.spacing],...
%       'YTickLabel', YLabels,...
%       'XTickLabel',num2str((0:DEFAULT_GRID_SPACING:g.winlength)'),...
%       'TickLength',[.005 .005],...
%       'Color','none',...
%       'XColor',DEFAULT_AXIS_COLOR,...
%       'YColor',DEFAULT_AXIS_COLOR,...
%       'FontSize',8);
%   
%   if ischar(g.eloc_file) || isstruct(g.eloc_file)  % Read in electrode names
%       if isstruct(g.eloc_file) && length(g.eloc_file) > size(data,1)
%           g.eloc_file(end) = []; % common reference channel location
%       end
%       eegplot_w3('setelect', g.eloc_file, ax1);
%   end
%   
% %   %% Retrieving bad chans and comps! #Ugo #Savecommand #mybadcomp #mybadchan
% %   if isstruct(EEG)
% %       if ~isfield(g.eloc_file, 'badchan')
% %           for ii=1:length(g.eloc_file)
% %               g.eloc_file(ii).badchan = 0;
% %           end
% %       end
% %   end
% 

function reprint_main_axis(g,figh)
  clf;
  data = g.data;

  [DEFAULT_PLOT_COLOR,DEFAULT_FIG_COLOR,BUTTON_COLOR,DEFAULT_AXIS_COLOR,DEFAULT_GRID_SPACING, DEFAULT_AXES_POSITION, DEFAULT_GRID_STYLE, SPACING_EYE,ORIGINAL_POSITION] = get_defaults(g);
   ax0 = axes('tag','backeeg','parent',figh,...
      'Position',DEFAULT_AXES_POSITION,...
      'Box','off','xgrid','off', 'xaxislocation', 'top', 'Units', 'Normalized');
  YLabels = num2str((1:g.chans)');  % Use numbers as default
  YLabels = flipud(char(YLabels,' '));
  ax1 = axes('Position',DEFAULT_AXES_POSITION,...
      'userdata', data, ...% store the data here
      'tag','eegaxis','parent',figh,...%(when in g, slow down display)
      'Box','on','xgrid', g.xgrid,'ygrid', g.ygrid,...
      'gridlinestyle',DEFAULT_GRID_STYLE,...
      'Xlim',[0 g.winlength*g.srate],...
      'xtick',[0:g.srate*DEFAULT_GRID_SPACING:g.winlength*g.srate],...
      'Ylim',[0 (g.chans+1)*g.spacing],...
      'YTick',[0:g.spacing:g.chans*g.spacing],...
      'YTickLabel', YLabels,...
      'XTickLabel',num2str((0:DEFAULT_GRID_SPACING:g.winlength)'),...
      'TickLength',[.005 .005],...
      'Color','none',...
      'XColor',DEFAULT_AXIS_COLOR,...
      'YColor',DEFAULT_AXIS_COLOR,...
      'FontSize',8);


function [DEFAULT_PLOT_COLOR,DEFAULT_FIG_COLOR,BUTTON_COLOR,DEFAULT_AXIS_COLOR,DEFAULT_GRID_SPACING, DEFAULT_AXES_POSITION, DEFAULT_GRID_STYLE, SPACING_EYE,ORIGINAL_POSITION] = get_defaults(g)

DEFAULT_PLOT_COLOR = { [0 0 1], [0.7 0.7 0.7]};         % EEG line color
try
    icadefs;
	DEFAULT_FIG_COLOR = BACKCOLOR;
	BUTTON_COLOR = GUIBUTTONCOLOR;
catch
	DEFAULT_FIG_COLOR = [1 1 1];
	BUTTON_COLOR =[0.8 0.8 0.8];
end
DEFAULT_AXIS_COLOR = 'k';         % X-axis, Y-axis Color, text Color
DEFAULT_GRID_SPACING = 1;         % Grid lines every n seconds
DEFAULT_GRID_STYLE = '-';         % Grid line style
%YAXIS_NEG = 'off';                % 'off' = positive up 
%DEFAULT_NOUI_PLOT_COLOR = 'k';    % EEG line color for noui option
                                  %   0 - 1st color in AxesColorOrder
SPACING_EYE = 'on';               % g.spacingI on/off
%SPACING_UNITS_STRING = '';        % '\muV' for microvolt optional units for g.spacingI Ex. uV
%MAXEVENTSTRING = 10;
%DEFAULT_AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
                                  % dimensions of main EEG axes
ORIGINAL_POSITION = [50 50 800 500];
                   
MAXEVENTSTRING = g.maxeventstring;
DEFAULT_AXES_POSITION = [0.05 0.03 0.865 1-(MAXEVENTSTRING-4)/100]; %[0.095 0.35 0.842 0.75-(MAXEVENTSTRING-5)/100];

function g = make_eloc_file(g)

% this function remakes the g based on the current EEG,
% specifically, eloc_file, events, frames, chans, data,

EEG = g.EEG;
elecrange = [1:EEG.nbchan];

if ~isempty( EEG.icasphere )
    comprange = [1:size(EEG.icaweights,1)];
end

if ~isempty(EEG.chanlocs)
    g.eloc_file_ch = EEG.chanlocs(elecrange);
end

if ~isempty(EEG.icasphere)
    try
        gcompreject=EEG.reject.gcompreject;
    catch
        gcompreject=zeros(1,size(EEG.icaweights,1));
    end
    tmpcompstruct=struct('badchan',num2cell(gcompreject));
    for index = 1:length(comprange)
        tmpcompstruct(index).labels = int2str(comprange(index));
    end
    g.eloc_file_pc = tmpcompstruct;
    
end

if EEG.plotchannels == 1
    g.chans = EEG.nbchan;
    g.eloc_file = g.eloc_file_ch;
    g.data = EEG.data;
else
    g.chans = size(EEG.icaweights,1);
    g.eloc_file = g.eloc_file_pc;
    g.data = EEG.icaact;
end

data = g.data;

g.normed = 0;
% 
if g.trialstag > 0
    g.trialstag = EEG.pnts;
end

%if g.limits
%g.limits = [1000*EEG.xmin 1000*EEG.xmin];

g.dispchans  = size(data,1);

if ~isempty(g.events)
    if ~isfield(g.events, 'type') || ~isfield(g.events, 'latency'), g.events = []; end;
end

%[~,g.frames, tmpnb] = size(data);
g.frames = size(EEG.data(:,:),2);

% if g.spacing == 0
%     g=optim_scale(data,g);
% end

g.events = EEG.event;

if ~isempty(g.events)
    if ischar(g.events(1).type)
        [g.eventtypes, ~, indexcolor] = unique_bc({g.events.type}); % indexcolor countinas the event type
    else [g.eventtypes, ~, indexcolor] = unique_bc([ g.events.type ]);
    end
    %indexcolor=length(indexcolor)-indexcolor+1;
    g.eventcolors     = { 'r', [0 0.8 0], 'b', 'm', [1 0.5 0],  [0.5 0 0.5], [0.6 0.3 0] };
    g.eventstyle      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'};
    g.eventwidths     = [ 2.5 1 ];
    g.eventtypecolors = g.eventcolors(mod([1:length(g.eventtypes)]-1 ,length(g.eventcolors))+1);
    g.eventcolors     = g.eventcolors(mod(indexcolor-1               ,length(g.eventcolors))+1);
    g.eventtypestyle  = g.eventstyle (mod([1:length(g.eventtypes)]-1 ,length(g.eventstyle))+1);
    g.eventstyle      = g.eventstyle (mod(indexcolor-1               ,length(g.eventstyle))+1);

    % for width, only boundary events have width 2 (for the line)
    % -----------------------------------------------------------
    indexwidth = ones(1,length(g.eventtypes))*2;
    if iscell(g.eventtypes)
        index=find(ismember(g.eventtypes,{'boundary'}));
        if ~isempty(index)
            indexwidth(index) = 1;
            g.eventtypestyle{index} = '-';
            g.eventtypecolors{index} = 'c';
            g.eventstyle(find(indexcolor==index))={'-'};
            g.eventcolors(find(indexcolor==index))={'c'};
        end
    end
    g.eventtypewidths = g.eventwidths (mod(indexwidth([1:length(g.eventtypes)])-1 ,length(g.eventwidths))+1);
    g.eventwidths     = g.eventwidths (mod(indexwidth(indexcolor)-1               ,length(g.eventwidths))+1);

    % latency and duration of events
    % ------------------------------
    g.eventlatencies  = [ g.events.latency ]+1;
    if isfield(g.events, 'duration')
        durations = { g.events.duration };
        durations(cellfun(@isempty, durations)) = { NaN };
        g.eventlatencyend   = g.eventlatencies + [durations{:}]+1;
    else g.eventlatencyend   = [];
    end
    g.plotevent       = 'on';
end
if isempty(g.events)
    g.plotevent      = 'off';
end


function g = THINKING(g,stop)

%figh = gcf;

fig = findobj('tag','eegplot_w3');

if nargin < 1
    try g = get(fig,'UserData'); catch, return; end
end

g.thinking = stop;

figh = findobj(gcf,'tag','eegplot_w3');

ax0 = findobj(figh,'tag','backeeg');

ax1 = findobj(figh,'tag','eegaxis');

u10 = findobj(figh,'Tag','Etime');
u9 = findobj(figh,'Tag','Evalue');
u11 = findobj(figh,'Tag','Eelec');

%u(10),u(11),u(9) THIS IS THE ORDER
% this is their tags
% u(9) = Eelec 
% u(10) = Etime
% u(11) = Evalue

if stop == 1
  try figh.WindowButtonMotionFcn = []; catch; end
  try figh.WindowKeyPressFcn = []; catch; end
  try figh.WindowScrollWheelFcn = []; catch; end
  try figh.HitTest = 'off'; catch; end
else
  try figh.HitTest = 'on'; catch; end
  try figh.WindowScrollWheelFcn = {@mouse_scroll_wheel,figh,ax0,ax1,u10,u9,u11}; catch; end
  try figh.WindowButtonMotionFcn = {@mouse_motion,figh,ax0,ax1,u10,u9,u11}; catch; end
  try figh.WindowKeyPressFcn = {@eegplot_readkey,figh,ax0,ax1,u10,u9,u11}; catch; end
end

set(ax0,'UserData',g);

function g = TYPING(g,stop)

%figh = gcf;

if nargin < 1
    g = get(gcf,'UserData');
end

%g.typing = stop;

figh = findobj(gcf,'tag','eegplot_w3');

ax0 = findobj(figh,'tag','backeeg');

ax1 = findobj(figh,'tag','eegaxis');

u10 = findobj(figh,'Tag','Etime');
u9 = findobj(figh,'Tag','Evalue');
u11 = findobj(figh,'Tag','Eelec');

%u(10),u(11),u(9) THIS IS THE ORDER
% this is their tags
% u(9) = Eelec 
% u(10) = Etime
% u(11) = Evalue

if stop == 1
  figh.WindowKeyPressFcn = [];
%   set(ax1, 'windowbuttonmotionfcn', {[]});
%   set(ax1, 'WindowKeyPressFcn',     {[]});
else
  %set(ax1, 'WindowScrollWheelFcn',  {@mouse_scroll_wheel,figh,ax0,ax1,B,C,A});
  try figh.WindowKeyPressFcn = {@eegplot_readkey,figh,ax0,ax1,u10,u9,u11}; catch; end
  %set(ax1, 'WindowKeyPressFcn',     {@eegplot_readkey,figh,ax0,ax1,B,C,A});
end

set(ax1,...
    'YTick', [0:g.spacing:g.chans*g.spacing],...
    'Ylim',  [g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] ); % 'YLim',[0 (g.chans+1)*g.spacing]

% update scaling eye (I) if it exists
% -----------------------------------
eyeaxes = findobj('tag','eyeaxes','parent',fig);
if ~isempty(eyeaxes)
    eyetext = findobj('type','text','parent',eyeaxes,'tag','thescalenum');
    set(eyetext,'string',num2str(g.spacing,4))
end

%set(gcf, 'UserData', g);


