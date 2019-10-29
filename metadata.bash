#!/usr/bin/env bash
read -s -p "Type Password: " PASSWORD ; echo
read -s -p "Retype Password: " PASSWORD_CONFIRM ; echo

if [[ "${PASSWORD}" != "${PASSWORD_CONFIRM}" ]]; then
    echo "Passwords doesn't match"
    exit 1
fi


ENTRY="$1"
for i in "$@"
do
    case $i in
        --username=*) USERNAME="username: ${i#*=}" ; shift ;;
        --email=*) EMAIL="email: ${i#*=}" ; shift ;;
        --url=*) URL="URL: ${i#*=}" ; shift ;;
        --oauth2=*) OAUTH2="OAuth2: ${i#*=}" ; shift ;;
        --multifactor=*) MFA="MFA: ${i#*=}" ; shift ;;
        --updated=*) UPDATED="updated: ${i#*=}" ; shift ;;
        --cycle=*) CYCLE="cycle: ${i#*=}" ; shift ;;
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

echo "${template}" | pass insert -m "${ENTRY}"
