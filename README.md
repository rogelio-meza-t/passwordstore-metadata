# passwordstore-metadata
Insert metadata into passwordstore with ease

## Usage
```
Usage:

    pass metadata pass-name [ OPTIONS ]

Options:

    --username=[ username ]
        Username used for login.

    --email=[ email ]
        Email registered in your account. Usually it's used for recovery
        password and notification porpuses.

    --multifactor=[ method ]
        One or more MFA methods you have set in your account. If you have two
        or more, list it as a comma separated value. Some examples of MFA
        are OTP and authenticator (authy, google authenticator, ...)

    --oauth2=[ provider ]
        Alternate or main oauth2 provider you use to login the site. If you have
        more than two, use a comma separated list.

    --url=[ url ]
        The site URL

    --updated=[ updated ]
        The date you have updated your password. Set the date as ISO 8601

    --cycle=[ cycle ]
        Indicates the period you want to change your password. Use d,w,m or y
        in order to indicate when you are referencing days, weeks, months or
        years respectively.
```
