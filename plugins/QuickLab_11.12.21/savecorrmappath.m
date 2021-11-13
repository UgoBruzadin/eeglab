%--- this function was written by Ugo Bruzadin Nunes
%--- in June 23th 2021
%--- 

function corrmappath = savecorrmappath()

%--- save current path
currentfolder = pwd;
%--- changes to plugin folder
folder = geteeglabpath()
if isempty(folder)
    return;
end
cd(folder);
cd('plugins')
dir('QuickLab*');
%cd('C:/GitHub/eeglab/plugins/QuickLab'); %NEEDS FIXING
pluginfolder = pwd;
%--- creates empty string variable corrmappath
corrmappath = '';
%--- checks to see if corrmap exists
if isfile('corrmappath.txt')
    corrmappath = readtext('corrmappath.txt');
    if iscell(corrmappath)
        corrmappath = corrmappath{:};
    end
end

corrmappath = uigetdir(corrmappath);

cd(pluginfolder);

writematrix(corrmappath,'corrmappath.txt');

end