#!/usr/bin/env bash
ENTRY="$1"
PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"


function has_multifactor(){
    MFA=$(pass "$1" | grep MFA | cut -d' ' -f2 )
    if [[ -z "$MFA" ]] || [[ "$MFA" == "none" ]]; then
        ((HAS_MFA=HAS_MFA+1))
    fi
}

function outdated_password(){
    cycle=$(pass "$1" | grep cycle | cut -d' ' -f2 )
    updated=$(pass "$1" | grep updated | cut -d' ' -f2 )
    identifier=${cycle: -1}
    quantity=${cycle:0:-1}
    
    if [[ "$identifier" == "m" ]]; then
        factor="month"
    elif [[ "$identifier" == "y" ]]; then
        factor="year"
    else
        # by default, factor is in days
        factor="day"
    fi
    next_update=$(date -d "$updated +$quantity $factor" '+%s')
    today=$(date '+%s')
    
    if [[ $today -ge $next_update ]]; then
        ((IS_OUTDATED=IS_OUTDATED+1))
    fi
}

function sum_warnings(){
    ((TOTAL_WARNINGS=HAS_MFA+IS_OUTDATED))
}

function run_checks(){
    HAS_MFA=0
    IS_OUTDATED=0
    TOTAL_WARNINGS=0

    has_multifactor "$1"
    outdated_password "$1"
    
    sum_warnings
    echo "Total warnings found: $TOTAL_WARNINGS";
    if [[ HAS_MFA -gt 0 ]]; then
        echo -e "\tMFA is not set";
    fi
    if [[ IS_OUTDATED -gt 0 ]]; then
        echo -e "\tThe password is outdated";
    fi
}


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
    if [[ -d "$PREFIX/$ENTRY" ]]; then
        echo "$PREFIX/$ENTRY is a directory"
    elif [[ -f "$PREFIX/$ENTRY.gpg" ]]; then
        run_checks "$ENTRY"
    else
        echo "$PREFIX/$ENTRY is not valid"
        exit 1
    fi
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
