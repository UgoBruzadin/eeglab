function runapipeline(EEG)

pipeline = inputgui('geometry', { [1 1] [1 1] [1 1] }, ...
    'uilist', { ...
    { 'style' 'pushbutton' 'string' 'Select Files'} { 'Style', 'edit', 'string', 'Current file' 'tag' 'files'}...
    { 'style' 'checkbox' 'string' 'Highpass Filter' } { 'Style', 'edit', 'string', '55' 'tag' 'highpass'}...
    { 'style' 'checkbox' 'string' 'Lowpass Filter' } { 'Style', 'edit', 'string', '2' 'tag' 'lowpass'}});% ...
    %{ 'style' 'checkbox' 'string' 'Notch Filter' } ...
    %{ 'style' 'checkbox' 'string' 'Epoch' }  }) ;

    a = [1 1];
   % , ''Select One or More Files'',''MultiSelect'', ''on'')
% THIS WORKS, LEFT IT TO COPY FROM IT
% res = inputgui( 'geometry', { [1 1] }, ...
%          'geomvert', [3], 'uilist', { ...
%          { 'style', 'text', 'string', [ 'Make a choice' 10 10 10 ] }, ...
%          { 'style', 'listbox', 'string', 'Choice 1|Choice 2|Choice 3' } } );       
%        



       
% res = inputgui( 'geometry', { [1 1] }, ...
%          'geomvert', [3], 'uilist', { ...
%          { 'style', 'text', 'string', [ 'Make a choice' 10 10 10 ] }, ...
%          { 'style', 'checkbox', 'string', 'Filter' } } );
     
%this is the simple code where we chose which functions we want run on the
%files of this folder

% Filter = {'filter',2, 55}; %works
% Nfilter = {'nfilter',59,61}; %works
% nfilterAMPS = {'nfilterAMPS'}; %works
% PCA45 = {'ica',45}; %works just fine!
% ICLREJ = {'iclrej', 1};
% BSS = {'bss'};
% HM = {'HM100'};
% EP2448 = {'epoch','DIN',0.400, 2.448}; %works
% EP4096 = {'epoch','DIN',-1.000, 3.096};
% ICA = {'ica'};
% dipfit = {'dipfit'};
% PCA50 = {'ica',50};
% F2 = {'epoch','DIN',0.600, 2.648}; %works
% F3 = {'epoch',{'DIN',0.800, 2.848}}; %works
% H = {'epochRejection',3, 3}; %works
% I = {'loreta'}; %needs to be created
% refav = {'ref', 'av'}; %needs to be retested
% I2 = {'ref', 'cz'}; %needs to be retested
% I3 = {'ref', 'le'}; %needs to be retested
% J = {'interpolate'}; %needs to be retested
% K = {'baseline',[0 .400]}; %needs to be retested
% FFT = {'fft'};
% iclabelheart = {'heart'};
% 
% [file,path] = uigetfile('*.set',...
%    'Select One or More Files', ...
%    'MultiSelect', 'on');



%maybe: BSS, 
%example; Batch1 = {E2,F}; Batch2 = {E3,F,G};

% batch1 = {EP4096};
% %batch2 = {Nfilter,Filter};
% autopipeliner_v1a.batches({batch1},path);
%Fork1 = {D1,F,E2};
%path = pwd;
%testIC = {'ica',10};
%testloop = {'icloop','all',5};
%batchtest = {testIC,testloop};
%path1 = 'H:\Matlab_Batch_v7.0a-129Chan-H5_DL\Testing\secondtry\';
%try
    %ICLREJ = {'iclrej', 1};    
    %ICA = {'ica'}    
    %batch3 = {ICA,ICLREJ}
    
    %autopipeliner.batches({batch2},path);
    
    %[path2, counter] = autopipeliner.pipeIn({testIC,testloop},path);
    %autopipeliner.batches({D,batchtest},path);
    %autopipeliner.forks({batchtest},{batchtest},path);
    %pipeliner.batches({D1,loop20,ep400,eprej33,loop10},path);
    %autopipeliner.forks({D1,loop20},{{ep400,eprej33,loop10},{ep600,eprej33,loop10}},path);
    %examples pipeliner.batches({Batch1,Batch2,Fork1,Fork2},path);
    %pipeliner.batches({Fork1,Fork2},path2);
    %pipeliner.txt('batches done');
%catch e %e is an MException struct
%    fprintf(1,'The identifier was:\n%s',e.identifier);
%	fprintf(1,'There was an error! The message was:\n%s',e.message);
    %msgText = getReport(e)
 %   pipeliner.txt('error'); 
    %fprintf(e.stack);
%end

%pipeliner.batches({Batch3},path);
