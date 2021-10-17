function plotDifference(EEGone,EEGtwo)

if nargin < 2
    EEGpost = EEGone(end).data;
    EEGpre = EEGone(end-1).data;
else
    EEGpost = EEGone.data;
    EEGpre = EEGtwo.data; 
end

EEGdiff = EEGpost - EEGpre;

eegplot_w( EEGdiff, 'srate', EEGone(1).srate, 'title', [ 'DIFFERENCE PRE MINUS POST'], ...
			  'limits', [EEGone(1).xmin EEGone(1).xmax]*1000 )% , 'command', command, eegplotoptions{:}, varargin{:});

end


