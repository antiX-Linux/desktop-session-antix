#!/bin/bash

# NOTE: IFS=, for almost the entire program

VERSION=00.06
VERSION_DATE="Sun Apr 21 18:49:24 MDT 2013"

. /usr/local/lib/desktop-session/lib-desktop-session.sh
. /usr/local/lib/desktop-session/desktop-session-file-locations.sh

tmp_compare=/tmp/xsession-modified-date

ME=${0##*/}

usage() {
    cat <<Usage
Usage: $ME [options] default-desktop|[slim.conf]

Update slim manually or through an apt hook using
.desktop files found in the directory: $xs_dir.
Include <icon>-<wm> versions as applicable.

Options:
  -h  --help          show this help
  -l  --list          list available desktops on one line
  -L  --long          list available desktops, one per line
  -p  --prefix=       Set prefix for finding xsessions dir and slim.conf
  -s  --slim          update slim.conf 
  -d=  --check-diff=  Set / Check differance between installed desktops
                      --check-diff set
                      --check-diff check

Default SLiM conf file: $slim_conf

Return success if the slim.conf file was updated without error.  
In all other cases return failure.
Usage
}

#------------------------------------------------------------------------------
# Function: main
#
# Process commmand line args and then do what needs to be done.
#------------------------------------------------------------------------------
main() {

    local arg slim_mode help_mode list_mode long_mode prefix quick_exit diff_mode option_set

    while [ $# -gt 0 -a -z "${1##-*}" ]; do
        arg="${1#-}"; shift

        case "$arg" in
            -help|h) help_mode=true ; quick_exit=true ; option_set=true ;;
            -list|l) list_mode=true ; quick_exit=true ; option_set=true ;;
            -long|L) long_mode=true ; quick_exit=true ; option_set=true ;; 
            -check-diff=*|d=*) diff_option="${arg#*=}"; diff_mode=true ; option_set=true ;;
            -slim|s) slim_mode=true ; option_set=true ;;
            -prefix|p) [ $# -lt 1 ] && error "Expected prefix after -$arg"
                     prefix="$1"     ; shift          ; option_set=true ;;
            -prefix=*|p=*) prefix="${arg#*=}"         ; option_set=true ;;
            *) error "Unknown argument: -$arg"  ;;
        esac
    done

    local orig_ifs=$IFS
    local IFS=,
    
    if [ ! "$option_set" ]; then
        usage;
    fi
    
    if [ "$prefix" ]; then
        xs_dir=$prefix$xs_dir
        slim_conf=$prefix$slim_conf
    fi
    if [ "$quick_exit" ]; then
        [ -n "$diff_mode" -o $# -gt 0 ] && error "Extra/conflicting command line parameters --check-diff (-d)"
        [ -n "$slim_mode" -o $# -gt 0 ] && error "Extra/conflicting command line parameters --slim (-s)"

        [ "$help_mode" ] && usage
        [ "$help_mode" ] && usage
        [ "$list_mode" ] && full_desktop_list
        [ "$long_mode" ] && full_desktop_list | sed 's/,/\n/g'

        exit 1
    fi

    [ $# -gt 1 ] && error "Extra command line parameters: $@"
    
    if [ "$diff_mode" ]; then 
        [ -n "$slim_mode" -o $# -gt 0 ] && error "Extra/conflicting command line parameters --slim (-s)"
        check_diff "$@"
    fi

    if [ "$slim_mode" ]; then
        [ -n "$diff_mode" -o $# -gt 0 ] && error "Extra/conflicting command line parameters --check-diff (-d)"
        edit_slim "$@"
    fi
    
    exit 0
}

#------------------------------------------------------------------------------
# Function: check_diff set/check
#
# Check the differance between installed desktops pre apt and post apt.
# This is done by checking desktops dir modified date before and after apt.
#------------------------------------------------------------------------------
check_diff() {
    case $diff_option in 
    set)
        stat -c %Y $xs_dir > $tmp_compare;
    ;;
    check)
        current_date=$(stat -c %Y $xs_dir)
        past_date=$(cat $tmp_compare)
        if [ "$current_date" != "$past_date" ]; then
            echo "Updating Slim";
            edit_slim;
        else 
            exit 0
        fi
    ;;
    *)
        echo "Not an option";
    ;;
    esac
}

#------------------------------------------------------------------------------
# Function: edit_slim [slim-config-file]
#
# Edit the "sessions" line in the slim-config-file to include all (and only)
# the installed windows managers and valid <icon>- versions.
#------------------------------------------------------------------------------
edit_slim() {
    local slim=${1:-$slim_conf}
    #[ $UID -eq 0 ] || error "Only root can update slim.conf"
    
    [ -e $slim ] || error "SLiM conf file does not exist: $slim"
    [ -w $slim ] || error "Cannot write to $slim"

    local list=$(full_desktop_list)
    sed -r -i "s=^(sessions ).*=\1$list=" $slim
    
    #Update alternative menus
    $desktop_session_update_wm_menus
}

#------------------------------------------------------------------------------
# Function: get_wm <desktop>
#
# Print the <wm> part of <icon>-<wm>.  Only strip off leading <icon>- if <icon>
# is a recognized icon manager.
#------------------------------------------------------------------------------
get_wm() {
    [ "$1" ] || return
    for icon in $icon_managers; do
        [ -z "${1##$icon-*}" ] || continue
        echo "${1#$icon-}"
        return
    done
        
    echo "$1"
}

#------------------------------------------------------------------------------
# Function: get_icon <desktop>
#
# Print the <icon> part of <icon>-<wm> where <icon> must be the code for an
# icon managers in the icon_managers list.
#------------------------------------------------------------------------------
get_icon() {
    for icon in $icon_managers; do
        [ -z "${1##$icon-*}" ] || continue
        echo $icon
        return
    done
}


#------------------------------------------------------------------------------
# Function: print_entry <desktop-code> <command> <entry> <error-handling>
#
# Print one "case" statement clause.
#------------------------------------------------------------------------------
print_entry() {
    local code="$1" cmd="$2" entry="${3:-$1}" err="$4"
    local icon=$(get_icon "$code")

    if [ "$icon" ]; then
        eval local icon_mg=\$${icon}_MANAGER
        eval icon_mg=\"$icon_mg\"
        icon_mg="$(echo -e "\n        $icon_mg")"
    fi

    [ "$err" ] && icon_mg="$err$icon_mg"

    cat <<Entry
    $entry)$icon_mg
        exec $cmd
        ;;
Entry
}

#------------------------------------------------------------------------------
# Function: desktop_list
#
# A comma delimited version of valid_desktops()
#------------------------------------------------------------------------------
desktop_list() {
    local list
    while read wm; do
        list=$list,$wm
    done <<Read
$(valid_desktops)
Read
    echo "${list#,}"
}

#------------------------------------------------------------------------------
# Function: full_desktop_list
#
# A comma delimited list of all valid desktops with <icon>- prefixes as needed.
# This list can be significantly longer than the valid_desktops() list.
#------------------------------------------------------------------------------
full_desktop_list() {
    local list
    while read wm; do        
        for icon in $icon_managers; do
            eval local valid=\$${icon}_enabled
            case ",$valid," in
                *,$wm,*) list="$list,$icon-$wm" ;;
            esac
        done
        list="$list,$wm"
    done <<Read
$(valid_desktops)
Read
    echo "${list#,}"
}

#------------------------------------------------------------------------------
# Function: valid_desktops
#
# Create a list of desktop names converted to lowercase from *.desktop files
# in /usr/share/xssessions.  We cache the result in the VALID_DESKTOP variable
# so we only query the filesystem once.
#------------------------------------------------------------------------------
valid_desktops() {
    [ "$VALID_DESKTOPS" ] \
        ||  VALID_DESKTOPS=$(grep -h ^Name= $xs_dir/* | cut -d= -f2 | tr "[A-Z]" "[a-z]" \
            | sed -r -e 's/ (desktop|session)$//' -e 's=[^A-Za-z0-9/+-]+=_=g' | sort -u)
    echo "$VALID_DESKTOPS"
}

#------------------------------------------------------------------------------
# Function: desktop_cmd <desktop-code>
#
# fill DESKTOP_CMD variable with the program to run to launch the window manager
# associated with the <desktop-code> = <icon>-<wm> where the leading <icon>- is
# optional.  Always exits if there is an error so you can be sure DESKTOP_CMD
# contains the correct code to run.
#------------------------------------------------------------------------------
desktop_cmd() {
    DESKTOP_CMD=
    local wm=$(get_wm "$1")
    local wm_regex=$(echo "$wm" | sed 's=_=[^A-Za-z0-9/+-]\\+=g')

    local file=$(grep -i -l ^Name=$wm_regex$ $xs_dir/* | head -n 1)
    [ -z "$file" ] && file=$(grep -i -l "^Name=$wm_regex desktop$" $xs_dir/* | head -n 1)
    [ -z "$file" ] && file=$(grep -i -l "^Name=$wm_regex session$" $xs_dir/* | head -n 1)

    [ "$file" ] || error "No file found in $xs_dir with \"Name=$wm\""
    #[ "$(echo "$file" | wc -w)" = "1" ] || error "Two or more $xs_dir files contain \"Name=$wm\""
   
    local cmd=$(grep ^Exec= "$file" | cut -d= -f2)
    [ "$cmd" ] || error "Could not find \"Exec=\" in file $file"
    DESKTOP_CMD=$cmd
}

#------------------------------------------------------------------------------
# Function: error <error-message>
#
# Print error-messge on stderr and then exit with failed return status.
#------------------------------------------------------------------------------
error() {
    echo "$ME Error: $@" >&2
    exit 2
}


main "$@"

