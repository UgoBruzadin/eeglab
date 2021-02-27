clc
clear all
% end
files = dir('*.set');


parfor i=files:length(files)
   EEG = pop_loadset(file1(i).name, fileINPUT,  'all','all','all','all','auto');
   
   difEvents = cat(1,{EEG.event.type});
   uniqueEvents = unique(a);
   finalEvents = '';
   
   for k=1:length(uniqueEvents)
       strcat(finalEvents,uniqueEvents(k),'_');
   end
   
   temporaryTable = {[file1(i).name],length(EEG.event),finalEvents,initialTotalPoints,EEG.pnts, nameOfFirstEvent, timeOfFirstEventBins, nameOfLastEvent, timeOfLastEventBins, totalFatTrimmedBeg, totalFatTrimmedEnd};
   writecell(temporaryTable,strcat(file1(i).name(1:end-4),'EVENTS.xls'));
   EEG = pop_delset(EEG, 1);
end