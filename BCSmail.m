clc
clear

BCStable = readtable('BCStable2.xlsx');

title = 'Scheduled reminder for BCS prosem presentation (Czarbot1.1)';

attachment = {'C:\MATLAB\GitHub\eeglab-eeglab2019\BCStable2.xlsx'};

BCS_emails = 'Hylin, Michael J <mhylin@siu.edu>; Jamnik, Matthew R <matthew.jamnik@siu.edu>; Jacobs, Eric A <eajacobs@siu.edu>; Gunn, Matthew P <mathewgunn1@siu.edu>; Holden, Ryan <rholden@siu.edu>; Junker, Matthew S <matthew.junker@siu.edu>; Travis-Judd, Hannah L <h.travis0731@siu.edu>; Caminiti, Emily <emily.caminiti@siu.edu>; Habib, Reza <rhabib@siu.edu>; Schmidt, Kathleen E <kathleen.schmidt@siu.edu>; Sanislo, Nicholas J <nicholas.sanislo@siu.edu>; Olechowski, Alicia A <aolechowski@siu.edu>; Smith, Aidan C <asmith14@siu.edu>; Dilalla, Lisabeth A <ldilalla@siu.edu>; Rose, Gregory M <grose@siu.edu>; Wei, Xuan <xuan.wei@siu.edu>; Tio, Yee Pin <yeepintio@siu.edu>; Shonka, Sophia <sophia.shonka@siu.edu>; Lee, Yueh-Ting <leey@siu.edu>; Marshall, Riley L <riley.l.marshall@siu.edu>; Kail Seymour <kailseymourbcba@gmail.com>;';
        
for i=1:length(BCStable.email)
    if BCStable.order(i) ~= 0
        body = 'Dear ' + string(BCStable.name(i)) + newline + newline + ...
            'This is a scheduled email to remind you that you are scheduled to present in the BCS pro-sem.' + ...
            newline + newline + 'You are scheduled to present on ' + string(datetime(BCStable.date{i})) + ' (military time).' +...    
            newline + newline + 'Please email the following list ASAP the title and description of your presentation and attached files if any' +...
            newline + newline + 'Best wishes,' +...
            newline + 'Czarbot v1.1' + newline + 'P.s. Attached the email list with names, emails, order or presentation and dates.' + ...
            newline + BCS_emails;
        %sendOutlookMailv2(BCStable.email(i),'','',title,body,attachment,string(datetime(BCStable.date{i})))
        sendOutlookMailv2(BCStable.email(i),'','',title,body,attachment,string(datetime(BCStable.date{i}) - 2));
        fprintf('email sent to %s scheduled to be sent at %s', BCStable.email{i}, string(datetime(BCStable.date{i}) - 2));
    end
end