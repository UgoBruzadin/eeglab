

% myImage = imread('1101E1DotLoc-1___HM_Av_2HP55LP_NF4460_BE60_CzEP60FFT.jpg');
% set(handles.axes7,'Units','pixels');
% resizePos = get(handles.axes7,'Position');
% myImage= imresize(myImage, [resizePos(3) resizePos(3)]);
% axes(handles.axes7);
% imshow(myImage);
% set(handles.axes7,'Units','normalized');
% 
% function pushbutton1_Callback(hObject, eventdata, handles)
%  % hObject    handle to pushbutton1 (see GCBO)
%  % eventdata  reserved - to be defined in a future version of MATLAB
%  % handles    structure with handles and user data (see GUIDATA)
%  I = imread('1101E1DotLoc-1___HM_Av_2HP55LP_NF4460_BE60_CzEP60FFT.jpg');
%  %J = imread('1101E1DotLoc-1___HM_Av_2HP55LP_NF4460_BE60_CzEP60FFT.jpg');
%  axes(handles.axes1);
%  imshow(I);
%  %axes(handles.axes2);
%  %imshow(J);


function rec = plotfft(EEG,files,findex)


%jpgfiles = dir('*jpg');
% if isempty(findex)
%     findex = find(strcmp({files.name}, strcat(EEG.filename)));
% end

if exist('EEG','var')
    if isstruct(EEG)
        if ~isempty(EEG)
            if ~isempty(findobj('Tag','rec'))
                clear rec
            end
            rec = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized','Tag', 'rec', 'Position', [.5 .15 .35 .67]);
            
            jpgfiles = dir('*FFT*jpg');
            findex = find(strcmp({jpgfiles.name}, strcat(EEG.filename(1:end-4),'FFT.jpg')));
            if ~isempty(findex)
                pic = jpgfiles(findex).name;
                [picrgb,map] = imread(pic);
                set(rec,'Units','pixels')
                resizePos = get(rec,'Position');
                [picrgb2,map] = imresize(picrgb, [resizePos(4) resizePos(3)]);
                set(rec,'Units','normalized');
                set(rec,'cdata',picrgb2);
            end
        end
    end
end
% get(findobj('Tag','frame1'))
% axes(findobj('Tag','frame1'))
% plot([1 2 3])
