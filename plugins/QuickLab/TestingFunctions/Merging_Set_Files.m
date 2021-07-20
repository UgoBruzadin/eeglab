clc
clear all
addpath('C:\Program Files\eeglab12_0_1_0b\');
[INEEG1 path1]=uigetfile('*.set','Select Parent files','Multiselect', 'ON'); %Selecting the Parent file
[INEEG2 path1]=uigetfile('*.set','Select File to be Appended files','Multiselect', 'ON'); %Selecting the file to append (Note: this requires at least 2 files. Simply 
if ischar(INEEG1)==1
    INEEG1={INEEG1};
end

for i=1:length(INEEG1)
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',{INEEG1{1, i} INEEG2{1,1}},'filepath', path1); % For appending the same one file to all files i.e. attaching ERP to N2-RIP Data
   %EEG = pop_loadset('filename',{INEEG1{1, i} INEEG2{1,i}},'filepath', path1);  %(For Matt R's Project)For appending the files across several session NOTE: they must be in order on input for
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    EEG = pop_mergeset( ALLEEG, [1:2], 0);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, [INEEG1{1,i}(1:end-4),'40ERP.set'],'M:\00_fMRI ALL DATA_00\RIP and ERP combined\TESTING_Merger\' ); % Change directory to the destination folder you want to write to
end