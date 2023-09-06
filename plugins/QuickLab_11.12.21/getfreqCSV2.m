% MAKE CSV with FREQUENCIES

AllFiles = dir('*.set')';

[ AllFiles ] = GetAllDirFiles(pwd, 'set');

origin = pwd;
mkdir('CSVs');
cd('CSVs');
csvs = pwd;
cd(origin);

failed = '';
parfor i=1:length(AllFiles) 

    %try 
    EEG = pop_loadset( AllFiles(i).name,AllFiles(i).folder);
    
    [EEG,~] = quick_reref(EEG,'AVG');
    [eegspecdB,freqs,~,~,~] = pop_spectopo(EEG, 1, [EEG.xmin*1000  EEG.xmax*1000], 'EEG' , 'freqrange',[2 55],'winsize',512,'electrodes','off','plot' ,'off');

    spectra = array2table(eegspecdB,'VariableNames',string(freqs));

    cd(csvs);
    writetable(spectra,strcat(AllFiles(i).name(1:9),'.csv'));
    cd(origin);

    %catch
        %failed = cat(failed,AllFiles(i).name);
    %end
end