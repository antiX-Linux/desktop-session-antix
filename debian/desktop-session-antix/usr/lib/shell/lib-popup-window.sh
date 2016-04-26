# This prevents gtk2 themes from interfering with Pango colors
export GTK2_RC_FILES=/usr/share/themes/Default/gtk-2.0-key/gtkrc

ANTIX_IMAGE="/usr/local/lib/antiX/antiX-logo.png"

MIN_WIDTH=80

if [ "$Static_antiX_Libs" ]; then
    YAD_STD_OPTS="--center --on-top"
else
    YAD_STD_OPTS="--width=200 --text-align=center  --center --on-top --image=$ANTIX_IMAGE"
    YAD_STD_OPTS="--width=800 --text-align=center  --center --on-top --justify=center"
fi

YAD_YES_NO_OPTS="
    --button=gtk-yes:0
    --button=gtk-no:1"

YAD_ERROR_OPTS="
    --image=gtk-dialog-error
    --buttons-layout=center
    --button=gtk-ok:0"

YAD_INFO_OPTS="
    --buttons-layout=center
    --button=gtk-ok:0"

std_yad() { yad $YAD_STD_OPTS "$@" ;}

popup_okay() {
    std_yad $YAD_INFO_OPTS --text "$(center_text "$@")"
}

popup_error() {
    std_yad $YAD_ERROR_OPTS --text "$(center_text "$@")"
    
}

popup_yes_no() {
    :
}

center_text() {
    local width=$MIN_WIDTH line len width pad_l pad_r
    for line; do
        len=${#line}
        if [ $len -ge $width ]; then
            echo "$line\n"
        else
            diff=$((width - len))
            pad_l=$((diff / 2))
            pad_r=$((diff - pad_l))
            printf "%${pad_l}s%s%${pad_r}s\n" "" "$line" ""
        fi
    done
}
