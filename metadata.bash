#!/bin/bash
read -s -p "Type Password: " PASSWORD ; echo
read -s -p "Retype Password: " PASSWORD_CONFIRM ; echo

if [ "${PASSWORD}" -ne "${PASSWORD_CONFIRM}"  ]; then
    echo "Passwords doesn't match"
    exit 1
fi


ENTRY="$1"
for i in "$@"
do
    case $i in
        --username=*) USERNAME="${i#*=}" ; shift ;;
        --email=*) EMAIL="${i#*=}" ; shift ;;
        --url=*) URL="${i#*=}" ; shift ;;
        --oauth2=*) OAUTH2="${i#*=}" ; shift ;;
        --multifactor=*) MFA="${i#*=}" ; shift ;;
        --updated=*) UPDATED="${i#*=}" ; shift ;;
        --cycle=*) CYCLE="${i#*=}" ; shift ;;
    esac
done

read -d '' template <<_EOF_
${PASSWORD}
username: ${USERNAME}
email: ${EMAIL}
URL: ${URL}
OAuth2: ${OAUTH2}
MFA: ${MFA}
updated: ${UPDATED}
cycle: ${CYCLE}
_EOF_

echo "${template}" | pass insert -m "$ENTRY"
