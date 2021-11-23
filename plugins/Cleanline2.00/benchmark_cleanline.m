
% tic
% EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:128] ,'computepower',1,'linefreqs',60,'newversion',0,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',0,'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);
% toc

tic
EEG = pop_cleanline_par(EEG, 'bandwidth',2,'chanlist',[1:128] ,'computepower',1,'linefreqs',60,'newversion',0,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',0,'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);
toc