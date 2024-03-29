#!/usr/bin/env bash
shopt -s dotglob

ENTRY="$2"
PREFIX="${PASSWORD_STORE_DIR:-$HOME/.password-store}"

YELLOW='\033[1;33m'
CYAN='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

function draw_tree(){
    readarray -d / -t levels <<< "$1"
    if [[ ${#levels[*]} -gt 1 ]]; then
        unset levels[0]
        for ((i=1; i < ${#levels[@]}; i++)); do
            if [[ $i -eq 1 ]]; then
                echo -n '│   '
            else
                echo -n '    ';
            fi
        done

        if [[ -d "$PREFIX/$1" && ${#levels[@]} -gt 1 ]]; then
            echo -n '└── '
        elif [[ -f "$PREFIX/$1.gpg" ]]; then
            readarray -d / -t dir <<< "$1"
            unset 'dir[${#dir[@]}-1]'
            dir=$(printf "/%s" "${dir[@]}")
            last_file=$(find "$PREFIX$dir" -maxdepth 1 -type f | tail -1)
            if [[ "$last_file" = "$PREFIX/$1.gpg" ]]; then
                echo -n '└── '
            else
                echo -n '├── '
            fi
        else
            echo -n '├── '
        fi
    fi

    if [[ -d "$PREFIX/$1" ]]; then
        echo -en ${CYAN}${levels[-1]}${NC}
    else
        echo -n ${levels[-1]}
    fi

    if ! [ -z "$2" ]; then
        echo -en "$2"
    fi
    echo " "
}

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
        ((DAYS_OUTDATED=($today - $next_update) / 86400))
        ((IS_OUTDATED=IS_OUTDATED+1))
    fi
}

function sum_warnings(){
    ((TOTAL_WARNINGS=HAS_MFA+IS_OUTDATED))
}

function run_checks(){
    HAS_MFA=0
    IS_OUTDATED=0
    DAYS_OUTDATED=0
    TOTAL_WARNINGS=0

    has_multifactor "$1"
    outdated_password "$1"
    
    sum_warnings
    if [[ $TOTAL_WARNINGS -gt 0 ]]; then
        WARNINGS_STR="${YELLOW} $TOTAL_WARNINGS warnings${NC}"
        if [[ HAS_MFA -gt 0 ]]; then
            WARNINGS_STR="$WARNINGS_STR [MFA not set";
        fi
        if [[ IS_OUTDATED -gt 0 ]]; then
            WARNINGS_STR="$WARNINGS_STR, Password outdated ${DAYS_OUTDATED} days";
        fi
        WARNINGS_STR="$WARNINGS_STR]"
        draw_tree "$1" "$WARNINGS_STR"
    else
        echo -e ${CYAN}$1${NC} ${GREEN} '\u2713' ${NC};
    fi
}

function do_audit(){
    if [[ -d "$PREFIX/$1" ]]; then
        draw_tree "$1"

        if [[ -n "$2" ]]; then
            dir_entries="$PREFIX/$1/*.gpg"
        else
            dir_entries="$PREFIX/$1/*"
        fi

        for file in $dir_entries; do
            no_prefix=${file#$PREFIX/}
            no_extension=${no_prefix%.gpg}
            do_audit "${no_extension}" "$2"
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
    if [[ -n "$2" ]] && [[ "$2" != "--no-recursive" ]]; then
        echo "Option not valid"
        exit 1
    fi
    do_audit "$ENTRY" "$2"
}

case "$1" in
    save)shift;save "$@" ;;
    audit)shift;audit "$@";;
esac
