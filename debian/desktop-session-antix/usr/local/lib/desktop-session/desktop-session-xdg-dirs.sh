#!/bin/bash
#Desktop-session xdg build variables

. /usr/local/lib/desktop-session/lib-desktop-session.sh

function LOCATIONS {
LOCATION=$1
if [ ! -d "$LOCATION" ]; then
	say "Location does not exist; making"
	mkdir -p $LOCATION;
	chmod 0700 $LOCATION;
fi
}

#Make / Merge / Update xdg base directories

XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
export XDG_DATA_HOME
LOCATIONS "$HOME/.local/share"

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
export XDG_CONFIG_HOME
LOCATIONS "$HOME/.config"

XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}
export XDG_CACHE_HOME
LOCATIONS "$HOME/.cache"

XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-"$HOME/.run"}
export XDG_RUNTIME_DIR
LOCATIONS "$HOME/.run"

XDG_DATA_DIRS=${XDG_DATA_DIRS:-"/usr/local/share/:/usr/share/"}
export XDG_DATA_DIRS

XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-"/etc/xdg"}
export XDG_CONFIG_DIRS

#Make / merge / update xdg user directories
xdg-user-dirs-update

if [ -f ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs ]; then
	. ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs
    export XDG_DESKTOP_DIR XDG_DOWNLOAD_DIR XDG_TEMPLATES_DIR XDG_PUBLICSHARE_DIR XDG_DOCUMENTS_DIR XDG_MUSIC_DIR XDG_PICTURES_DIR XDG_VIDEOS_DIR
fi

#Xport the gtkrc files
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
