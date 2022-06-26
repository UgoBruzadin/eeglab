function rec = plotfft(EEG,files,jpgindex)


%jpgfiles = dir('*jpg');
% if isempty(findex)
%     findex = find(strcmp({files.name}, strcat(EEG.filename)));
% end
W_MAIN = findobj('Tag','EEGLAB');

axisPie = uipanel(W_MAIN, 'Position',[.9 .05 .09 .30],'Tag','PieChart',Visible='on',BackgroundColor=W_MAIN.Color,BorderType='none');

% % Create a new axis on the panel
pieAxis = axes(axisPie, 'Tag','pie_chart','Position', [0 0 1 1],Visible='on');
%axis fill
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

            end


        end
    end
end

