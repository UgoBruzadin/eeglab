clc
clear
file1 = dir('*.set');
%You Need this to move up one folder level to save /Start
fileINPUT = pwd;
cd ..
fileOUTPUT = pwd;
%You Need this to move up one folder level to save /End

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

for i=1:length(file1)
    
    EEG = pop_loadset(file1(i).name, fileINPUT,  'all','all','all','all','auto');
    try
        EEG = pop_dipfit_settings( EEG, 'hdmfile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\standard_mri.mat','chanfile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213] ,'chansel',[1:size(EEG.icawinv,1)] );
        EEG = pop_multifit(EEG, [1:size(EEG.icawinv,1)] ,'threshold',100,'plotopt',{'normlen' 'on'});
    catch
        fprintf('failed dipfit because had no ICA, running ICA');
        EEG = pop_runica(EEG,'extended', 1);
        EEG = pop_dipfit_settings( EEG, 'hdmfile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\standard_mri.mat','chanfile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213] ,'chansel',[1:size(EEG.icawinv,1)] );
        EEG = pop_multifit(EEG, [1:size(EEG.icawinv,1)] ,'threshold',100,'plotopt',{'normlen' 'on'});
    end
    EEG = pop_saveset( EEG, [file1(i).name(1:end-4),'_Dip.set'],fileOUTPUT);
    EEG = pop_delset(EEG,1);
end