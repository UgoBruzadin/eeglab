% Script made in 07/22/2021
% by Ugo Nunes
% gets current folder, anterior folder, and makes Error folder.

function [fileINPUT, fileOUTPUT, fileOUTPUTError] = fetchFolders(folder)

cd(folder);

fileINPUT = pwd;
cd ..
fileOUTPUT = pwd;

mkdir('Error');
cd('./Error');
fileOUTPUTError = pwd;

cd (fileINPUT);