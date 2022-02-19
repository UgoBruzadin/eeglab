% [EEG, com] = eeglab2sloreta( EEG,ListSort,BadChanGUI,GUIOnOff)
%                  - This formats data for use in sLORETA.
%
% Usage:
%   >>  OUTEEG = pop_eeglab2sloreta( EEG,ListSort,BadChanGUI)
% 
%
% Inputs:
%   EEG         - Input dataset.
%   ListSort    - The chacters in the filename to sort into folders.
%   BadChanGUI  - Channels that should be removed from dataset.
%    
% Outputs:
%   OUTEEG     - Output dataset.
%
% Author: Matthew Phillip Gunn 
%
% See also: 
%   pop_select, pop_export, eeglab 

% Copyright (C) 2021  Matthew Gunn, Southern Illinois University Carbondale, neurolode@gmail
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

function [EEG, com] = pop_eeglab2sloreta(EEG)
                         
com = '';
if nargin < 1   
    help pop_eeglab2sloreta;
    return;
end
    %%%%%%%%%%%
    NumberOfFieldsAndFieldSpace = [.75 1 1];
    Title = { { 'style' 'text' 'string' 'Export To sLORETA' 'fontweight' 'bold' } ...
        {} ...
        {  'style' 'text' 'string' '' } ...
        {  'style' 'text' 'string' '' }};
   
    Mo1  = { { 'style' 'text' 'string' 'What Characters to sort on,' } ...
        { 'style' 'edit' 'string',''} ...
        { 'style' 'text' 'string' 'Ex. "8:10" Will sort into folders with characters 8 to 10' } };
       
    Mo2  = { { 'style' 'text' 'string' 'Do you need to remove channels' } ...
        { 'style' 'checkbox' 'string',''} ...
        { 'style' 'text' 'string' 'If Check will pop-up menu for you to select channels' } };
    
    allGeom = { 1 NumberOfFieldsAndFieldSpace };
    Title = [ Title(:)' Mo1(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    Title = [ Title(:)' Mo2(:)'];
    allGeom{end+1} = NumberOfFieldsAndFieldSpace;
    
    res = inputgui(allGeom, Title);
    if isempty(res)
        return
    end
        TempN1RemoveChannels = cell2mat(res(1,2));
    % Formating GUI input for channels for matlab - End
    %%%%%%%%%
    
    if TempN1RemoveChannels == 1
        fig.f = figure('Name','Asym_Check_','units','pixels','position',[650,650,650,650],'toolbar','none','menu','none');
        tabgp = uitabgroup(fig.f,'Position',[0 0 1 1]);    tab0a = uitab(tabgp,'Title','Channels Numbers');    tab1 = uitab(tabgp,'Title','Channels labels');
        for lak=1:2
            if lak==1            tab0 = tab0a;        elseif lak==2            tab0 = tab1;        end
            MaxColumns = ceil(EEG.nbchan/7); % NumberofColumns = 4
            for Ci = 1 : EEG.nbchan
                MaxColumns = ceil(EEG.nbchan/7);
                if Ci <= MaxColumns
                    Adjectment1yaxis = 600 - (20*Ci);
                    if lak==1                    ChanNum = strcat('Chan',32,num2str(Ci));                     fig.c1(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[10,Adjectment1yaxis,100,15],'string',ChanNum);
                    elseif lak==2                    ChanNum = EEG.chanlocs(Ci).labels;                    fig.c2(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[10,Adjectment1yaxis,100,15],'string',ChanNum);
                    end
                end
                if Ci > MaxColumns && Ci <= MaxColumns*2
                    Adjectment1yaxis = 600 - (20*(Ci-MaxColumns));
                    if lak==1                    ChanNum = strcat('Chan',32,num2str(Ci));                    fig.c1(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[100,Adjectment1yaxis,100,15],'string',ChanNum);
                    elseif lak==2                    ChanNum = EEG.chanlocs(Ci).labels;                    fig.c2(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[100,Adjectment1yaxis,100,15],'string',ChanNum);
                    end
                end
                if Ci > MaxColumns*2 && Ci <= MaxColumns*3
                    Adjectment1yaxis = 600 - (20*(Ci-MaxColumns*2));
                    if lak==1                    ChanNum = strcat('Chan',32,num2str(Ci));                    fig.c1(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[190,Adjectment1yaxis,100,15],'string',ChanNum);
                    elseif lak==2                    ChanNum = EEG.chanlocs(Ci).labels;                    fig.c2(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[190,Adjectment1yaxis,100,15],'string',ChanNum);
                    end
                end
                if Ci > MaxColumns*3 && Ci <= MaxColumns*4
                    Adjectment1yaxis = 600 - (20*(Ci-MaxColumns*3));
                    if lak==1                    ChanNum = strcat('Chan',32,num2str(Ci));                    fig.c1(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[280,Adjectment1yaxis,100,15],'string',ChanNum);
                    elseif lak==2                    ChanNum = EEG.chanlocs(Ci).labels;                    fig.c2(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[280,Adjectment1yaxis,100,15],'string',ChanNum);
                    end
                end
                if Ci > MaxColumns*4 && Ci <= MaxColumns*5
                    Adjectment1yaxis = 600 - (20*(Ci-MaxColumns*4));
                    if lak==1                    ChanNum = strcat('Chan',32,num2str(Ci));                    fig.c1(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[370,Adjectment1yaxis,100,15],'string',ChanNum);
                    elseif lak==2                    ChanNum = EEG.chanlocs(Ci).labels;                    fig.c2(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[370,Adjectment1yaxis,100,15],'string',ChanNum);
                    end
                end
                if Ci > MaxColumns*5 && Ci <= MaxColumns*6
                    Adjectment1yaxis = 600 - (20*(Ci-MaxColumns*5));
                    if lak==1                    ChanNum = strcat('Chan',32,num2str(Ci));                    fig.c1(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[460,Adjectment1yaxis,100,15],'string',ChanNum);
                    elseif lak==2                    ChanNum = EEG.chanlocs(Ci).labels;                    fig.c2(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[460,Adjectment1yaxis,100,15],'string',ChanNum);
                    end
                end
                if Ci > MaxColumns*6 && Ci <= MaxColumns*7
                    Adjectment1yaxis = 600 - (20*(Ci-MaxColumns*6));
                    if lak==1                    ChanNum = strcat('Chan',32,num2str(Ci));                    fig.c1(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[550,Adjectment1yaxis,100,15],'string',ChanNum);
                    elseif lak==2                    ChanNum = EEG.chanlocs(Ci).labels;                    fig.c2(Ci) = uicontrol(tab0,'style','checkbox','units','pixels','position',[550,Adjectment1yaxis,100,15],'string',ChanNum);
                    end
                end
            end
            if lak==1
                fig.p1 = uicontrol(tab0,'style','pushbutton','units','pixels','position',[40,5,200,20],'string','Confirm and Close');            set(fig.p1, 'callback', @(src, event)BadChan_p1_call(src, event, fig));
            elseif lak==2
                fig.p2 = uicontrol(tab0,'style','pushbutton','units','pixels','position',[40,5,200,20],'string','Confirm and Close');            set(fig.p2, 'callback', @(src, event)BadChan_p2_call(src, event, fig))
            end
        end
        sgtitle('Channels to Remove ');
        movegui('center')
        
        uiwait(fig.f)
        BadChanGUI = evalin('base','BadChanGUI');
    end
    if ~exist('BadChanGUI')
        BadChanGUI = 0;     
    end
        
    [EEG] = eeglab2sloreta( EEG,res(1,1),BadChanGUI);
 
    regions = [res(1,1) BadChanGUI];
    com = sprintf('EEG = eeglab2sloreta(EEG,%s);', vararg2str(regions));



% Pushbutton callback For Chan
function OutputChan = BadChan_p1_call(~, ~, fig)
vals = get(fig.c1,'Value');
OutputChan = find([vals{:}]);
assignin('base','BadChanGUI',OutputChan)
close(gcf)

% Pushbutton callback For Chan
function OutputChan = BadChan_p2_call(~, ~, fig)
vals = get(fig.c2,'Value');
OutputChan = find([vals{:}]);
assignin('base','BadChanGUI',OutputChan)
close(gcf)

