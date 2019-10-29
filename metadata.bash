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
        --username=*) USERNAME=$'\n'"username: ${i#*=}" ; shift ;;
        --email=*) EMAIL=$'\n'"email: ${i#*=}" ; shift ;;
        --url=*) URL=$'\n'"URL: ${i#*=}" ; shift ;;
        --oauth2=*) OAUTH2=$'\n'"OAuth2: ${i#*=}" ; shift ;;
        --multifactor=*) MFA=$'\n'"MFA: ${i#*=}" ; shift ;;
        --updated=*) UPDATED=$'\n'"updated: ${i#*=}" ; shift ;;
        --cycle=*) CYCLE=$'\n'"cycle: ${i#*=}" ; shift ;;
    esac
done

read -d '' template <<_EOF_
${PASSWORD}${USERNAME}${EMAIL}${URL}${OAUTH2}${MFA}${UPDATED}${CYCLE}
_EOF_

echo "${template}" | pass insert -m "${ENTRY}"
