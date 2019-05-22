#!/bin/bash
ENTRY="$1"

echo -n Password:
read -s PASSWORD
echo

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
