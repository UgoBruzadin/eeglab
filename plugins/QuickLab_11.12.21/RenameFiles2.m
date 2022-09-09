%--- script made by Ugo Nunes
% on 08/05/2021
% generates FFTs but also save FFTs to the file

fileINPUT = pwd;
%cd ..
fileOUTPUT = pwd;
%cd(fileINPUT);

files = dir('*DotLoc*.jpg');

%eeglab;
for i=1:length(files) 
    %EEG = pop_loadset( files(i).name, fileINPUT);
    foldersname = files(i).folder;
    filename = files(i).name;
    dotlocnum = filename(14);
    nfilter = [];
    try nfilter = filename(34:35); catch, end
    BE = strfind(filename,'BE');
    EP = strfind(filename,'EP');
    Tr = strfind(filename,'Tr');
    Ep = strfind(filename,'Ep');
    SM = strfind(filename,'SM');
    ICA = strfind(filename,'ICA');
    BSS = strfind(filename,'BSS');
    Cm = strfind(filename,'Cm');
    Cp = strfind(filename,'Cp');
    Ch = strfind(filename,'Ch');
    In = strfind(filename,'In');
    Rj = strfind(filename,'Rj');
    Hm = strfind(filename,'Hm');
    New = strfind(filename,'New');

    if ~isempty(nfilter)
        newfilename = [strcat(foldersname,'\',filename(1:6),'DL',dotlocnum,'_HA255N',nfilter,'T',filename(EP+2:end))];
    else
        newfilename = [strcat(foldersname,'\',filename(1:6),'DL',dotlocnum,'_HA255N')];
    end
    
    filename = strcat(foldersname, files(i).name);
    movefile(files(i).name, newfilename);
    %system("rename" +  filename + newfilename ); % didn't work
    %EEG = pop_saveset(EEG, 'filename', [strcat(fullname(1:6),'dl',dotlocnum,'HA255N',nfilter,'T',fullname(BE+2:end))], 'filepath',  fileOUTPUT ); %save set

end