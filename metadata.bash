#!/usr/bin/env bash

function has_multifactor(){
    MFA=$(pass "$1" | grep MFA | cut -d' ' -f2 )
    if [[ -z "$MFA" ]]; then
        echo -e "\tMFA if not set";
    fi
}

ENTRY="$1"
for i in "$@"
do
    case $i in
        --username=*) PUSERNAME=$'\n'"username: ${i#*=}" ; shift ;;
        --email=*) EMAIL=$'\n'"email: ${i#*=}" ; shift ;;
        --url=*) URL=$'\n'"URL: ${i#*=}" ; shift ;;
        --oauth2=*) OAUTH2=$'\n'"OAuth2: ${i#*=}" ; shift ;;
        --multifactor=*) MFA=$'\n'"MFA: ${i#*=}" ; shift ;;
        --updated=*) UPDATED="${i#*=}" ; shift ;;
        --cycle=*) CYCLE=$'\n'"cycle: ${i#*=}" ; shift ;;
        --audit=*) AUDIT="${i#*=}" ; shift ;;
    esac
done


if [[ $AUDIT ]]; then
    echo "Warnings:";
    has_multifactor "$ENTRY"
    exit 1
fi

if [[ $UPDATED =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$UPDATED" >/dev/null; then
    UPDATED=$'\n'"updated: ${UPDATED}"
    else echo "Date for --updated is not valid"; exit 1
fi

if [[ ! "${CYCLE: -1}" =~ [d,w,m]{1} ]]; then
    echo "Quantifier for --cycle is not valid"; exit 1
fi

read -s -p "Type Password: " PASSWORD ; echo
read -s -p "Retype Password: " PASSWORD_CONFIRM ; echo

if [[ "${PASSWORD}" != "${PASSWORD_CONFIRM}" ]]; then
    echo "Passwords doesn't match"
    exit 1
fi

read -d '' template <<_EOF_
${PASSWORD}${PUSERNAME}${EMAIL}${URL}${OAUTH2}${MFA}${UPDATED}${CYCLE}
_EOF_

echo "${template}" | pass insert -m "${ENTRY}"
