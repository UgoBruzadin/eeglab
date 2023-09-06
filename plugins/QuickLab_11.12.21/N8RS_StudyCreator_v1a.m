clear 
clc
PATHIN = pwd;

[ setfiles ] = GetAllDirFiles(pwd,'.set');

mkdir(strcat(pwd, '/CreatedStudy'));
cd(strcat(pwd, '/CreatedStudy'));
PATHOUT = pwd;
cd(PATHIN);

cd(PATHOUT);

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
pop_editoptions( 'option_storedisk', 1);
commands = {}; 

for i = 1:length(setfiles)

    CurrentFile = fullfile(setfiles(i).folder, setfiles(i).name);

    E = strfind(setfiles(i).name,'E');
    %session = str2double(setfiles(i).name(E(1)+1));
    session = [setfiles(i).name(E(1):E(1)+1)];
    NicCondition = str2double(setfiles(i).name(strfind(setfiles(i).name,'_G')+2));
    switch NicCondition
        case 1
            group = 'BUP';
        case 2
            group = 'NRT';
        case 3
            group = 'PLA';
        case 4
            group = 'SMO';
    end
    commands = {commands{:} ...
        {'index' i 'load' CurrentFile 'session' session 'subject' setfiles(i).name(1:4) 'condition' 'DOTLOC' 'group' group}};
 
end

[STUDY, ALLEEG] = std_editset(STUDY, ALLEEG, 'name','N5DL','commands',commands,'updatedat','on');
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
[STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
[STUDY EEG] = pop_savestudy( STUDY, EEG, 'filename',char(strcat('N5DL', '_', string(datetime('now','Format',"yyyy-MM-dd-HH-mm-ss")), '.study')),'filepath',pwd,'resavedatasets','off');
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
eeglab redraw



