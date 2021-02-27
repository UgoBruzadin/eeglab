function [finalReport] = pipe_finalreport(folderNameDate)
    reports = dir('*.txt');
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
    writematrix(finalReport,strcat(upper(folderNameDate),'.txt'));
end