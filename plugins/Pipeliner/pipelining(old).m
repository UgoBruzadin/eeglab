clear all
clc
%this is the simple code where we chose which functions we want run on the
%files of this folder
A = {'headmodel'}; %needs to be tested and adapted
B = {'filter',[2, 55]}; %works
C = {'notchfilter'}; %works
D1 = {'ica',45}; %works just fine!
%D2 = {'pca',floor(sqrt(EEG.pnts/20))};
D2 = {'ica',65}; %works just fine!
E1 = {'icloop',0.03, 30}; %doesnt work at all, changed how the 0.03 works
E2 = {'icloop','all', 20}; %number 20 is still not variable
F = {'epoch',{'DIN',0.400, 2.448}}; %works
H = {'loreta'}; %needs to be created
I1 = {'reref', 'av'};%needs to be tested
I2 = {'reref', 'cz'};%needs to be tested
I3 = {'reref', 'le'}; %needs to be tested
J = {'interpolate'}; %needs to be tested
K = {'baseline',[0 .400]};%needs to be tested

%maybe: BSS, 
Batch1 = {E2,F};
Batch2 = {D2,E2,F};
Fork1 = {D1,F,E2};
Fork2 = {D2,F,E2};
%Batch1 = {D1, E2, F};
%Batch2 = {D2, F, E2};
%Batch3 = {D1};
path = pwd;
%path2 = strcat(path,'/Batch_1');
%path3 = strcat(path,'/Batch_2');
try
    pipeliner.batches({Batch1},path);
    %pipeliner.batches({Batch1,Batch2,Fork1,Fork2},path);
    %pipeliner.batches({Fork1,Fork2},path2);
    %pipeliner.batches({Fork1,Fork2},path3);
catch e %e is an MException struct
	fprintf(1,'The identifier was:\n%s',e.identifier);
	fprintf(1,'There was an error! The message was:\n%s',e.message);
   % msgText = getReport(e)
    pipeliner.txt('error'); 
end
pipeliner.txt('batches done');
%pipeliner.batches({Batch3},path);
