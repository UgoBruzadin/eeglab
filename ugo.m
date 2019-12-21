classdef ugo
    methods(Static)
       
        function txt(content)
            number = '6183034686@vtext.com';
            email = 'ugobnunes@hotmail.com';
            who = {number, email};
            mail = 'ugoslab@gmail.com'; %Your GMail email address
            setpref('Internet','SMTP_Server','smtp.gmail.com');
            setpref('Internet','E_mail',mail); %sending email = mail
            setpref('Internet','SMTP_Username',mail); %username = mail
            setpref('Internet','SMTP_Password','1cabininthewoods2'); %password
            props = java.lang.System.getProperties;
            props.setProperty('mail.smtp.auth','true');
            props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
            props.setProperty('mail.smtp.socketFactory.port','465');
            
            % Send the email.  Note that the first input is the address you are sending the email to
            sendmail(who,'Automatic Matlab Report',content);
            fprintf('text successfully sent to %s and %s\n', email, number);
        end
        
        function clean()
            clc;         % clear command window
            clear all
            evalin('base','clear all');  % clear base workspace as well
            close all;   % close all figures
        end
        
        function baseFolder()
            
            
        end
    end
end