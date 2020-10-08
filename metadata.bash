#!/usr/bin/env bash
shopt -s dotglob

ENTRY="$2"
PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"

YELLOW='\033[1;33m'
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color


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
    if [[ $TOTAL_WARNINGS -gt 0 ]]; then
        echo -e ${CYAN}$1${NC} ${YELLOW} $TOTAL_WARNINGS warnings${NC};
        if [[ HAS_MFA -gt 0 ]]; then
            echo -e "    MFA is not set";
        fi
        if [[ IS_OUTDATED -gt 0 ]]; then
            echo -e "    The password is outdated";
        fi
    else
        echo -e ${CYAN}$1${NC} ${GREEN} '\u2713' ${NC};
    fi
}

function do_audit(){
    if [[ -d "$PREFIX/$1" ]]; then
        for file in "$PREFIX/$1"/*; do
            no_prefix=${file#$PREFIX/}
            no_extension=${no_prefix%.gpg}
            do_audit "${no_extension}"
        done
    elif [[ -f "$PREFIX/$1.gpg" ]]; then
        run_checks "$1"
    else
        echo "$1 is not valid"
        exit 1
    fi
}

function check_date(){
    if [[ $UPDATED =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$UPDATED" >/dev/null; then
        UPDATED=$'\n'"updated: ${UPDATED}"
        else echo "Date for --updated is not valid"; exit 1
    fi
}

function check_cycle(){
    if [[ ! "${CYCLE: -1}" =~ [d,w,m]{1} ]]; then
        echo "Quantifier for --cycle is not valid"; exit 1
    fi
}
function get_password(){
    read -s -p "Type Password: " PASSWORD ; echo
    read -s -p "Retype Password: " PASSWORD_CONFIRM ; echo

    if [[ "${PASSWORD}" != "${PASSWORD_CONFIRM}" ]]; then
        echo "Passwords doesn't match"
        exit 1
    fi
}

function insert_metadata(){
    template="${PASSWORD}${PUSERNAME}${EMAIL}${URL}${OAUTH2}${MFA}${UPDATED}${CYCLE}"
    echo -e "${template}" | pass insert -m "${ENTRY}"
}

function save(){
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
        esac
    done
    
    check_date
    check_cycle
    get_password
    insert_metadata
}

function audit(){
    do_audit "$ENTRY"
}

case "$1" in
    save)shift;save "$@" ;;
    audit)shift;audit ;;
esac
