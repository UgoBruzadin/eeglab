function EEG = quick_dipfit(EEG,comps)

if nargin < 2
    comps = []; 
end

%EEG = pop_par_dipfit_settings(EEG);
% EEG = pop_par_dipfit_settings( EEG, 'hdmfile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\standard_mri.mat','chanfile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213] ,'chansel',[1:size(EEG.icawinv,1)] );
% EEG = pop_par_multifit(EEG, [1:size(EEG.icawinv,2)] ,'threshold',100,'plotopt',{'normlen' 'on'});
% acronym  = 'DF'; 
EEG = pop_par_dipfit_settings( EEG, 'hdmfile','C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\standard_mri.mat','chanfile','C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213] ,'chansel',[1:EEG.nbchan] );
EEG = pop_par_multifit2(EEG, comps ,'threshold',100,'plotopt',{'normlen','on'});

end