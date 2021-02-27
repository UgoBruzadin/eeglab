% eegplugin_fastcorrmap.m
%    Provides a faster alternative to remove components correlated with
%    templates.
%    Still in beta.
%    Create templates with pop_createcorrtemplates
%    Run corrmap in parallel or in sequence
%    Lost of improvements still to come.

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
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% (C) 2020 Ugo Bruzadin Nunes  
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vers = eegplugin_fastcorrmap(fig, trystrs, catchstrs)
vers='fastcorrmap0.1';
% Menu
plotmenu = findobj(fig, 'tag', 'tools');
supermenu = uimenu( plotmenu, 'label', 'FastCorrmap','userdata', 'startup:on;study:on');

commcreate = [trystrs.check_data 'pop_createcorrtemplates(EEG); ' catchstrs.add_to_hist ] ;
commcorr = [ trystrs.check_data 'pop_fastcorrmap_v1a(); ' catchstrs.add_to_hist ] ;
commparcorr = [trystrs.check_data 'pop_fastcorrmap_par_v1a(); ' catchstrs.add_to_hist ] ;
commopt = [trystrs.check_data 'pop_corrmapoptions(EEG); ' catchstrs.add_to_hist ] ;

uimenu( supermenu, 'label', 'Create new templates from loaded file', 'Separator','off', ...
       'userdata', 'startup:on;study:off', 'Callback', commcreate);

uimenu( supermenu, 'label', 'Run fastCORRMAP', 'Separator','off', ...
       'userdata', 'startup:on;study:off', 'Callback', commcorr);

   uimenu( supermenu, 'label', 'Run fastCORRMAP in Parallel', 'Separator','off', ...
       'userdata', 'startup:on;study:off', 'Callback', commparcorr);
   
%    uimenu( supermenu, 'label', 'Edit fastCORRMAP options', 'Separator','off', ...
%        'userdata', 'startup:on;study:off', 'Callback', commopt);

   