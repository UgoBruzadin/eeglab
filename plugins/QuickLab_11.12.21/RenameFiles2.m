%--- script made by Ugo Nunes
% on 08/05/2021
% generates FFTs but also save FFTs to the file

fileINPUT = pwd;
%cd ..
fileOUTPUT = pwd;
%cd(fileINPUT);

files = dir('*.set');

%eeglab;
for i=1:length(files) 
    %EEG = pop_loadset( files(i).name, fileINPUT);
    foldersname = files(i).folder;
    filename = files(i).name;
    dotlocnum = filename(14);
    nfilter = filename(34:35);
    BE = strfind(filename,'BE');
    EP = strfind(filename,'EP');

    
    newfilename = [strcat(foldersname,'\',filename(1:6),'DL',dotlocnum,'_HA255N',nfilter,'T',filename(EP+2:end))];

    Tr = strfind(newfilename,'Tr');
    Ep = strfind(newfilename,'Ep');
    SM = strfind(newfilename,'SM');
    ICA = strfind(newfilename,'ICA');
    BSS = strfind(newfilename,'BSS');
    Cm = strfind(newfilename,'Cm');
    Cp = strfind(newfilename,'Cp');
    Ch = strfind(newfilename,'Ch');
    In = strfind(newfilename,'In');
    Rj = strfind(newfilename,'Rj');
    Hm = strfind(newfilename,'Hm');
    New = strfind(newfilename,'New');
    
    filename = strcat(foldersname, files(i).name);
    movefile(files(i).name, newfilename);
    %system("rename" +  filename + newfilename ); % didn't work
    %EEG = pop_saveset(EEG, 'filename', [strcat(fullname(1:6),'dl',dotlocnum,'HA255N',nfilter,'T',fullname(BE+2:end))], 'filepath',  fileOUTPUT ); %save set

end