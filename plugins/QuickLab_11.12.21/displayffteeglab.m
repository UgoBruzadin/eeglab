

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


function rectangle = plotfft(EEG,files,findex)

if exist('EEG','var')
    if isstruct(EEG)
        if ~isempty(EEG)
            rectangle = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized','Tag', 'rec', 'Position', [.3 .15 .45 .67]);
            jpgfiles = dir('*jpg');
            pic = jpgfiles(strcat(files(findex).name(1:20),'*.jpg')).name;
            [picrgb,map] = imread(pic);
            set(rectangle,'Units','pixels')
            resizePos = get(rectangle,'Position');
            set(rectangle,'Units','Normalized');
            set(rectangle,'cdata',picrgb);
        end
    end
end