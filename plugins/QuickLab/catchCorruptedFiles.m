% --- code written by Ugo on 07-25-2021
% --- trys to load .set files, and makes a list of all corrupted files.

clc
clear

filePRE = pwd;

files = dir('*.set');
corruptedfiles = dir('');

eeglab

for i=1:files
   try
       EEG = pop_par_loadset(files(i).name, filePRE,  'all','all','all','all','auto');
   catch
       corruptedfiles = cat(1,corruptedfiles,files(i));
   end
end

save('FilesAndReferences.mat','FinalTable'); %saves the table in .mat format
writecell(FinalTable,'FilesAndReferences.xls');