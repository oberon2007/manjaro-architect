# !/usr/bin/bash

# usage
# test.sh -a -desktop="i3"


version='dev test'
LIBDIR='./lib'
DATADIR='./data'
ARCHI=$(uname -m)

# console and tests params
declare -Ag PARAMS=(
    ['advanced']=0
    ['desktop']=''
    ['efi']=0
    ['lusk']=0
)


####################################################

# auto load translate
#TODO: rename *.trans by code.trans (2 portuguese?)
#      add long titre in first ligne for use in list langs
function set_lang() {
    source "${DATADIR}/translations/english.trans"
    echo "$LANG"
    declare f="${DATADIR}/translations/${LANG:0:5}.trans"
    if [ -f "$f" ]; then
        source "$f" # po_BR ?
    else
        declare f lg="${LANG:0:2}"
        for f in ${DATADIR}/translations/${lg}*.trans; do
            source "$f"
            break
        done
    fi
    echo -e "$_PlsWaitBody"
}


# read console args , set in PARAMS global var
get_params() {
    getopts
    while getopts ad: option; do
        case $option in
            a) PARAMS[advanced]=1 ;;
            d) PARAMS[desktop]="${OPTARG}" ;;
        esac
    done
    #declare -r PARAMS # now read only
}

####################################################

# function to remove the menus third column
format_menutool() {
    declare -a options=("$@") i=0 j=0
    for i in "${!options[@]}"; do
        ((j=i+1))
        ((j % 3==0)) && continue
        echo "${options[$i]}"
    done
}

DIALOG() {
    # add : --keep-tite to aif version
    dialog --keep-tite --backtitle "$VERSION - $SYSTEM ($ARCHI)" --column-separator "|" --title "$@"
}


####################################################

main_menu_online()
{
    local id options menus choice
    cmd=(DIALOG "Select a option" --menu "test: -d i3 -a " 0 0 16)
    options=(
       1 "Option 1" mount_partitions  # number 3 is the function
       2 "Install desktop" install_desktop
       3 "Option 3 | >" sub_menu_extra
       4 "Option for advanced user" function_extra
    )

    # somes test
    # can delete item 2 from parameters/hardware/...
    # can replace item 3 ...
    if [[ "${PARAMS[desktop]}" == 'i3' ]]; then
        options[4]='install i3'
        options[5]='install_desktop_i3' # change call
    fi
    if [[ "${PARAMS[advanced]}" == '0' ]]; then
        unset options[11]   # delete a line
        unset options[10]
        unset options[9]
    fi    
    # end tests

    if ((${#options[@]}==0)); then
        #menu empty
        # run a working function
        :
    fi

    # a function to remove  the third column
    mapfile -t menus <<< "$(format_menutool "${options[@]}" )"
    declare -p menus

#    while true; do

        # run dialog options
        choice=$("${cmd[@]}" "${menus[@]}" 2>&1 >/dev/tty)
        choice="${choice:-0}"

        case "$choice" in
            0) return 0 ;;                  # btn cancel
            *)  echo "$choice"              #debug
                id=$(( (choice*3)-1 ))
                cmd="${options[$id]}"       # find attach working function to array with  3 column
                echo "${options[*]}"        # debug
                ($cmd) || return $?         # run working(or submenu) function
        esac

#    done
}


set_lang            # auto load translates
get_params "$@"     # read params

main_menu_online