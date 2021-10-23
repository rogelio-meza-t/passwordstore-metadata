# passwordstore-metadata
Insert metadata into [pass](https://www.passwordstore.org/) with ease

## Usage
```
SYNOPSIS:

    pass metadata COMMAND ENTRY [ ARGS ]...


COMANDS:

    audit
        Check the ENTRY or the tree directory for outdated passwords and
        accounts without MFA set.
    save
        Insert new ENTRY using OPTIONS. See below for available options.
    
ARGS:

    audit
        --no-recursive
            Run checks for files only if ENTRY is a directory.
 
    save
        --username=[ username ]
            Username used for login.

        --email=[ email ]
            Email registered in your account. Usually it's used for recovery
            password and notification purposes.

        --multifactor=[ method ]
            One or more MFA methods you have set in your account. If you have two
            or more, list it as a comma separated value. Some examples of MFA
            are OTP and authenticator (authy, google authenticator, ...)

        --oauth2=[ provider ]
            Alternate or main oauth2 provider you use to login the into site. If you
            have more than two, use a comma separated list.

        --url=[ url ]
            The site URL

        --updated=[ updated ]
            The last date you have updated your password. Set the date as ISO 8601.
            E.g 2019-05-01 (it means May 1, 2019). This format is required and it
            will be validated.

        --cycle=[ cycle ]
            Indicates the period you want to change your password. Use d,w,m or y
            in order to indicate days, weeks, months or years respectively. E.g 3m
            (it means you want to change your password every 3 months).


```
