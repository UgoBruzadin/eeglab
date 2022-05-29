

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


function rec = plotfft(EEG,files,jpgindex)


%jpgfiles = dir('*jpg');
% if isempty(findex)
%     findex = find(strcmp({files.name}, strcat(EEG.filename)));
% end
W_MAIN = findobj('Tag','EEGLAB');

axisPie = uipanel(W_MAIN, 'Position',[.9 .05 .05 .25],'Tag','PieChart',Visible='on',BackgroundColor=W_MAIN.Color,BorderType='none');

% % Create a new axis on the panel
pieAxis = axes(axisPie, 'Tag','pie_chart','Position', [0 0 1 1],Visible='on');


CountDownDotLoc(pieAxis);

if exist('EEG','var')
    if isstruct(EEG)
        if ~isempty(EEG)
            if ~isempty(findobj('Tag','rec'))
                clear rec
            end
            rec = [];
            jpgfiles = dir('*FFT*jpg');
            jpgindex = find(strcmp({jpgfiles.name}, strcat(EEG.filename(1:end-4),'FFT.jpg')));
            figfiles = dir('*FFT*fig');
            figindex = find(strcmp({figfiles.name}, strcat(EEG.filename(1:end-4),'FFT.fig')));
            if ~isempty(jpgindex)
                
                axisFFT = uipanel(W_MAIN, 'Position',[.5 .15 .35 .67],'Tag','Picture',Visible='on',BackgroundColor=W_MAIN.Color,BorderType='none');
                fftAxis = axes(axisFFT, 'Tag','fft_chart','Position', [0 0 1 1],Visible='on');
                pic = jpgfiles(jpgindex).name;
                rec = imshow(pic,'Parent',fftAxis,'InitialMagnification','fit');
            elseif ~isempty(figindex)
% 
%                  pic = figfiles(figindex).name;
%                  
%                  rec = openfig(pic,'new', 'invisible');
%                  set(rec,'Tag','rec')
%                  hAxes = get(rec, 'CurrentAxes');
%                  hCopy = copyobj(hAxes, handles.rec);
%                  set(hCopy, 'Position', [.5 .15 .35 .67])





% %                 rec = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized','Tag', 'rec', 'Position', [.5 .15 .35 .67]);
%                 %fig = uifigure(gcf);
%                 [picrgb,map] = imread(pic);
%                 %uiimage(fig,"ImageSource",pic);
%                 
%                 %imshow(rec,pic2,'Parent',W_MAIN)
%                 set(rec,'Units','pixels')
%                 resizePos = get(rec,'Position');
%                 [picrgb2,map] = imresize(picrgb, [resizePos(4) resizePos(3)]);
%                 set(rec,'Units','normalized');
%                 set(rec,'cdata',picrgb2);
            end
            %fig = uifigure(gcf);
            %uiimage(fig,"ImageSource",pic);
            
%             resizePos = get(rec,'Position');
%                  [picrgb2,map] = imresize(picrgb, [resizePos(4) resizePos(3)]);
%                  set(rec,'Units','normalized');
%                  set(rec,'cdata',picrgb2);
            %rec = uipanel(W_MAIN, 'Position', [.5 .15 .35 .67],'Tag','rec')

            %try
%                 [total,done] = CountDownDotLoc()
%                 pieC = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized','Tag', 'pie', 'Position', [.9 .05 .05 .05]);
%                 set(pieC,'Units','pixels')
%                 resizePos = get(pieC,'Position');
%                 pieData = pie([total-done,done]);
%                 set(pieC,'cdata',pieData);
            %end

        end
    end
end
% get(findobj('Tag','frame1'))
% axes(findobj('Tag','frame1'))
% plot([1 2 3])
