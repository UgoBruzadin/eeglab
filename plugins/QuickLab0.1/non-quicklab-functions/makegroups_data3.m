


%[ allfiles ] = GetAllDirFiles(pwd, '');
%allfiles(ismember({allfiles.name},{'.','..'})) = [];

%T = readtable('E:/N5DLListINFO.xls');

allids = table2array(N5DLListINFO(:,1));
allids2 = str2double(table2array(DatsmeanRTandACC3(:,1)));
allids3 = table2array(N5DemographicsandLegend(:,1));
allids4 = table2array(SummaryROIsSN(:,1));
allids5 = table2array(SummaryROIsDMN(:,1));
allids6 = table2array(SummaryROIsCEN(:,1));

matfiles = dir('*.mat');

ROIS = [5,7,9,11,13,23,24,25,31,32,44,45,46];

%for i=1:size(allids2,1) % FIX THIS BEFORE RERUNNING!!!!!!!!
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

for i=1:size(allids2,1)

    ID = [];
    try ID = find(allids==allids2(i)); catch; end
    if ~isempty(ID)
        DatsmeanRTandACC3(i,8) = N5DLListINFO(ID,4);
    end

    try ID = find(allids3==allids2(i)); catch; end
    if ~isempty(ID)
        DatsmeanRTandACC3(i,9:25) = N5DemographicsandLegend(ID,2:18);
    end

    %% get IDs and Session in one ID
    newIDS_sess = [];
    for j=1:size(DatsmeanRTandACC3,1)
        newIDS_sess(j,1) = strcat(string(table2array(DatsmeanRTandACC3(j,1))),string(table2array(DatsmeanRTandACC3(j,2))));
    end

    for k=1:size(matfiles,1)

        newID = [];
        load(matfiles(k).name);

        for j=1:size(SummaryROIsSN,1)
            newIDS_ROI_SN(j,1) = strcat(string(table2array(FinalTable(j,1))),string(table2array(FinalTable(j,2))));
        end
    end
end


save('DatsmeanRTandACC3andDemo.mat','DatsmeanRTandACC3'); %saves the table in .mat format
writetable(DatsmeanRTandACC3,'DatsmeanRTandACC3andDemo.xls');



%     %% get ID and Session in one ID for SN ROI
%     newIDS_ROI_SN = [];
%     for j=1:size(SummaryROIsSN,1)
%         newIDS_ROI_SN(j,1) = strcat(string(table2array(SummaryROIsSN(j,1))),string(table2array(SummaryROIsSN(j,2))));
%     end
% 
%     %% collect Information in table
%     try ID = find(newIDS_ROI_SN==newIDS_sess(i)); catch; end
%     if ~isempty(ID)
%         DatsmeanRTandACC3(i,26:32) = SummaryROIsSN(ID,3:9);
%     end
% 
%     %% get ID and Session in one ID for SN ROI
%     newIDS_ROI_CEN = [];
%     for j=1:size(SummaryROIsCEN,1)
%         newIDS_ROI_CEN(j,1) = strcat(string(table2array(SummaryROIsCEN(j,1))),string(table2array(SummaryROIsCEN(j,2))));
%     end
% 
%     %% collect Information in table
%     try ID = find(newIDS_ROI_CEN==newIDS_sess(i)); catch; end
%     if ~isempty(ID)
%         DatsmeanRTandACC3(i,33:39) = SummaryROIsCEN(ID,3:9);
%     end
% 
%         %% get ID and Session in one ID for SN ROI
%     newIDS_ROI_DMN = [];
%     for j=1:size(SummaryROIsDMN,1)
%         newIDS_ROI_DMN(j,1) = strcat(string(table2array(SummaryROIsDMN(j,1))),string(table2array(SummaryROIsDMN(j,2))));
%     end
% 
%     %% collect Information in table
%     try ID = find(newIDS_ROI_DMN==newIDS_sess(i)); catch; end
%     if ~isempty(ID)
%         DatsmeanRTandACC3(i,40:46) = SummaryROIsDMN(ID,3:9);
%     end