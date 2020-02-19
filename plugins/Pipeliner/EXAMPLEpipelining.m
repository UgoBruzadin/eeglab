clear all
clc
%this is the simple code where we chose which functions we want run on the
%files of this folder
A = {'headmodel'}; %needs to be tested and adapted
B = {'filter',[2, 55]}; %works
C = {'notchfilter'}; %works
D = {'ica',45}; %works just fine!
E = {'icloop','all', 10};
F1 = {'epoch',{'DIN',0.400, 2.448}}; %works
F2 = {'epoch',{'DIN',0.600, 2.648}}; %works
F3 = {'epoch',{'DIN',0.800, 2.848}}; %works
H = {'epochRejection',3, 3}; %works
I = {'loreta'}; %needs to be created
I1 = {'reref', 'av'}; %needs to be retested
I2 = {'reref', 'cz'}; %needs to be retested
I3 = {'reref', 'le'}; %needs to be retested
J = {'interpolate'}; %needs to be retested
K = {'baseline',[0 .400]}; %needs to be retested

%maybe: BSS, 
%example; Batch1 = {E2,F}; Batch2 = {E3,F,G};

%Fork1 = {D1,F,E2};
path = pwd;
testIC = {'ica',10};
testloop = {'icloop','all',5};
batchtest = {testIC,testloop};
%try
    [path2, counter]= autopipeliner.pipeIn({testIC,testloop},path);
    
    autopipeliner.batches({D,batchtest},path);
    autopipeliner.forks({batchtest},{batchtest},path);
    %pipeliner.batches({D1,loop20,ep400,eprej33,loop10},path);
    %autopipeliner.forks({D1,loop20},{{ep400,eprej33,loop10},{ep600,eprej33,loop10}},path);
    %examples pipeliner.batches({Batch1,Batch2,Fork1,Fork2},path);
    %pipeliner.batches({Fork1,Fork2},path2);
    pipeliner.txt('batches done');
%catch e %e is an MException struct
%    fprintf(1,'The identifier was:\n%s',e.identifier);
%	fprintf(1,'There was an error! The message was:\n%s',e.message);
    %msgText = getReport(e)
 %   pipeliner.txt('error'); 
    %fprintf(e.stack);
%end

%pipeliner.batches({Batch3},path);
