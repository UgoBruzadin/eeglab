

function betterFFT(EEGA,EEGB)

if nargin < 2
    EEGB = EEGA;
end

COI_List = [1:EEGA.nbchan];
% if AverageChannelsCheck == 1
%     Ao = EEG.data(COI_List,:,:);
%     EEGout = mean(Ao, 1);
%     [eegspecdB,freqs,compeegspecdB,resvar,specstd] = spectopo(EEGout,EEG.pnts,EEG.srate, 'plot', 'off', 'verbose', 'off');
% else
[eegspecdA,freqs,compeegspecdA,resvar,specstd] = spectopo(EEGA.data,EEGA.pnts,EEGA.srate, 'plot', 'off', 'verbose', 'off');
[eegspecdB,freqs,compeegspecdB,resvar,specstd] = spectopo(EEGB.data,EEGB.pnts,EEGB.srate, 'plot', 'off', 'verbose', 'off');
% end
A(:,:,:) = eegspecdA;

A1 = mean(A,3);

B(:,:,:) = eegspecdB;
B1 = mean(B,3);
%C1 = abs(B1) - abs(A1);

UserFreq = [2 40];
[tmp, maxfreqidx] = min(abs(UserFreq(1,2)-freqs)); % adjust max frequency
[tmp, minfreqidx] = min(abs(UserFreq(1,1)-freqs)); % adjust min frequency
reallimits(1) = min(min(A1(:,minfreqidx:maxfreqidx)));
reallimits(2) = max(max(A1(:,minfreqidx:maxfreqidx)));
dBrange = reallimits(2)-reallimits(1);   % expand range a bit beyond data g.limits
reallimits(1) = reallimits(1)-dBrange/7;
reallimits(2) = reallimits(2)+dBrange/7;
Nodiff = 0;
if sum(reallimits) == 0
    reallimits(1) = -1;
    reallimits(2) = 1;
    Nodiff = 1;
end

figure;
mainfig = gca;
axis off;
allcolors = { [0 0.7500 0.7500]
    [1 0 0]
    [0 0.5000 0]
    [0 0 1]
    [0.2500 0.2500 0.2500]
    [0.7500 0.7500 0]
    [0.7500 0 0.7500] }; % colors from real plots                };
for index = 1:size(A1,1) % scan channels
    tmpcol  = allcolors{mod(index, length(allcolors))+1};
    command = [ 'disp(''Channel ' int2str(index) ''')' ];
    pl(index)=plot(freqs(1:(EEGA.srate/2)),A1(index,1:(EEGA.srate/2))', ...
        'color', tmpcol, 'ButtonDownFcn', command); hold on;
end
% eegplot_w( A1, 'srate', EEGA(1).srate, 'title', [ 'DIFFERENCE PRE MINUS POST'], ...
% 			  'limits', [EEGA(1).xmin EEGA(1).xmax]*1000 )% , 'command', command, eegplotoptions{:}, varargin{:});

set(pl,'LineWidth',2);
set(gca,'TickLength',[0.02 0.02]);
xl=xlabel('Frequency (Hz)');
axis([freqs(minfreqidx) freqs(maxfreqidx) reallimits(1) reallimits(2)]);
set(xl,'fontsize',12);
yl=ylabel('Log Power Spectral Density 10*log_{10}(\muV^{2}/Hz)');%yl=ylabel('Power 10*log_{10}(\muV^{2}/Hz)');
set(yl,'fontsize',12);
set(gca,'fontsize',12)
sgtitle(strcat('FFT Subtraction: C = B - A; Shaded = alpha < 0.05 '))

end