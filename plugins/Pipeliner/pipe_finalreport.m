function [finalReport] = pipe_finalreport(folderNameDate)
    reports = dir('*.mat');
    finalReport = [];
    %try and load all files at once then cat all of them? 
    for i=1:(length(reports)-1)
        if i == 1
            tempReport = readtable(reports(i).name);
        else
            tempReport = finalReport;
        end
        nextReport = readtable(reports(i+1).name);
        if length(reports) > 1
            finalReport = cat(1,tempReport,nextReport);
        else
            finalReport = tempReport;
        end
    end
    writetable(finalReport,strcat(upper(folderNameDate),'.xlsx'));
end