Ver = 1.4;
disp('Hello! Starting script to install Neurolode')
for i=1:100
    cd ..
end
disp('Finding EEGlab. This will take several minutes......')
dirs = regexp(genpath(pwd),['[^;]*'],'match');
dirs = dirs';
TF0 = contains(dirs,'popfunc','IgnoreCase',true);
[row,col] = find(TF0);
NewDir0 = dirs(row);
disp('Finding Latest Neurolode.......')
TF1 = contains(dirs,'Neurolode','IgnoreCase',true);
[row,col] = find(TF1);
NewDir = dirs(row);
ToDelete = NewDir{1,1};
cd(NewDir{1,1});
PluginScripts = dir('*.m');
cd ..
disp('Installing Neurolode.......')
for i=1:size(NewDir0,1)
    str = NewDir0{i,1};     
    k = strfind(str,'\');
    CopyTo0 = strcat(str(1:k(1,end-1)),'plugins\');
    CopyTo1 = (strcat(CopyTo0, 'Neurolode',num2str(Ver),'\'));
    mkdir(CopyTo1);
    for ii=1:size(PluginScripts,1)
        movefile(strcat(PluginScripts(ii).folder,'\',PluginScripts(ii).name),CopyTo1)
    end
end
disp('Cleaning up.......')
rmdir(ToDelete)
str1 = strcat('Finished! Thank you for installing Neurolode', num2str(Ver));
disp(str1)

