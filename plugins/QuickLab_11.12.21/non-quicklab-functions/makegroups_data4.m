


%[ allfiles ] = GetAllDirFiles(pwd, '');
%allfiles(ismember({allfiles.name},{'.','..'})) = [];

%T = readtable('E:/N5DLListINFO.xls');

allids = table2array(N5DLListINFO(:,1));
%allids2 = str2double(table2array(DatsmeanRTandACC3(:,1)));
allids3 = table2array(N5DemographicsandLegend(:,1));
allids4 = table2array(SummaryROIsSN(:,1));
allids5 = table2array(SummaryROIsDMN(:,1));
allids6 = table2array(SummaryROIsCEN(:,1));

matfiles = dir('*.mat');

%ROIS [5,7,9,11,13,23,24,25,31,32,44,45,46

%for i=1:size(allids2,1) % FIX THIS BEFORE RERUNNING!!!!!!!!
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Final_data = DatsmeanRTandACC3(:,1:82);
for i=1:size(allids2,1)

    ID = [];
    try ID = find(allids==allids2(i)); catch; end
    if ~isempty(ID)
        Final_data(i,8) = N5DLListINFO(ID,4);
    end

    try ID = find(allids3==allids2(i)); catch; end
    if ~isempty(ID)
        Final_data(i,9:25) = N5DemographicsandLegend(ID,2:18);
    end

    %% get IDs and Session in one ID
    newIDS_sess = [];
    for j=1:size(Final_data,1)
        newIDS_sess(j,1) = strcat(string(table2array(Final_data(j,1))),string(table2array(Final_data(j,2))));
    end

%     %% get ID and Session in one ID for SN ROI
%     newIDS_ROI_SN = [];
%     for j=1:size(SummaryROIsSN,1)
%         newIDS_ROI_SN(j,1) = strcat(string(table2array(SummaryROIsSN(j,1))),string(table2array(SummaryROIsSN(j,2))));
%     end
% 
%     %% collect Information in table
%     try ID = find(newIDS_ROI_SN==newIDS_sess(i)); catch; end
%     if ~isempty(ID)
%         DatsmeanRTandACC3(i,end+1:end+7) = SummaryROIsSN(ID,3:9);
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
%         DatsmeanRTandACC3(i,end+1:end+7) = SummaryROIsCEN(ID,3:9);
%     end
% 
%     %% get ID and Session in one ID for SN ROI
%     newIDS_ROI_DMN = [];
%     for j=1:size(SummaryROIsDMN,1)
%         newIDS_ROI_DMN(j,1) = strcat(string(table2array(SummaryROIsDMN(j,1))),string(table2array(SummaryROIsDMN(j,2))));
%     end
% 
%     %% collect Information in table
%     try ID = find(newIDS_ROI_DMN==newIDS_sess(i)); catch; end
%     if ~isempty(ID)
%         DatsmeanRTandACC3(i,end+1:end+7) = SummaryROIsDMN(ID,3:9);
%     end

    for k = 1:size(matfiles,1)
        load(matfiles(k).name)
        %% get ID and Session in one ID for SN ROI
        newID = [];
        for j=1:544
            newID(j,1) = strcat(string(FinalTable(j,1)),string(FinalTable(j,2)));
        end

        %% collect Information in table
        try ID = find(newID==newIDS_sess(i)); catch; end
        if ~isempty(ID)
            if k == 1
                Final_data(i,25+(k):25+(3*k)) = FinalTable(ID,3:5);
            else
                Final_data(i,25+(((k-1)*3)+1):25+(((k-1)*3)+3)) = FinalTable(ID,3:5);
            end
        end

    end

    newname = {};
freq = {'theta','alpha','beta'};

for i=1:19
    for j=1:3
        newname{end+1} = strcat(string(freq(j)),string(A{i}));
    end
end

Final_data = renamevars(Final_data,26:82,[newname{:}]);

end

save('Final_DL_dataset_complete.mat','Final_data'); %saves the table in .mat format
writetable(Final_data,'Final_DL_dataset_complete.xls');