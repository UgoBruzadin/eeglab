function plotDifference(ALLEEG)

EEGpost = ALLEEG(end).data;
EEGpre = ALLEEG(end-1).data;
EEGdiff = EEGpost - EEGpre;

eegplot_w( EEGdiff, 'srate', ALLEEG(1).srate, 'title', [ 'DIFFERENCE PRE MINUS POST'], ...
			  'limits', [ALLEEG(1).xmin ALLEEG(1).xmax]*1000 )% , 'command', command, eegplotoptions{:}, varargin{:});

end


