
function ugo

    function textme(mailname, header, content)
        
        switch mailname
            case {'Ugo', 'ugo'}
                mail2 = '6183034686@vtext.com'
            case {'Ugo2', 'ugo2'}
                mail2 = 'ugobnunes@hotmail.com'
            case {'Norka' , 'norka'}
                mail2 = 'norkar@siu.edu'
            case {'Gunn' , 'gunn' , 'Matt' , 'matt'}
                mail2 = '2176527701@vtext.com'
            case {'DG' , 'Gilbert', 'gilbert'}
                mail2 = 'dgilbert@siu.edu'
            otherwise
                mail2 = mailname;
        end
        mail = 'ugoslab@gmail.com'; %Your GMail email address
        %mail2 = 'ugob@siu.edu';
        setpref('Internet','SMTP_Server','smtp.gmail.com');
        setpref('Internet','E_mail',mail); %sending email = mail
        setpref('Internet','SMTP_Username',mail); %username = mail
        setpref('Internet','SMTP_Password','1cabininthewoods2'); %password
        props = java.lang.System.getProperties;
        props.setProperty('mail.smtp.auth','true');
        props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
        props.setProperty('mail.smtp.socketFactory.port','465');
        % Send the email.  Note that the first input is the address you are sending the email to
        sendmail(mail2,header)%,content);
        fprintf('text successfully sent to %s\n', mail2);
    end
end