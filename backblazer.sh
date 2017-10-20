#!/bin/bash

# The Backblaze email associated with your account
orgName='YOUR_COMPANY'
login='BACKBLAZE_EMAIL'
password='BACKBLAZE_PASSWORD'

clean_applications_backblaze() {
    local bz_app='/Applications/Backblaze.app'
    if [ -d $bz_app ]
    then
        remove $bz_app
    fi
}

clean_library_backblaze() {
    local bz_pkgs='/Library/Backblaze.bzpkg'
    local bz_apps='/Library/Backblaze'
    if [ -d $bz_apps ]
    then
        remove $bz_apps
    fi
    if [ -d $bz_pkgs ]
    then
        remove $bz_pkgs
    fi
}

clean_misc() {
    local bz_extbx="/Library/Application Support/ExtBX"
    if [ -d "$bz_extbx" ]
    then
        remove "$bz_extbx"
    fi
}

clean_system_preferences_backblaze() {
    local bz_pref_pane='/Library/PreferencePanes/BackblazeBackup.prefPane'
    if [ -d $bz_pref_pane ]
    then
        remove $bz_pref_pane
    fi
}

createOrgLibrary() {
    /bin/mkdir -p "/Library/${orgName}"
    /usr/sbin/chown -R root:wheel "/Library/${orgName}"
    /bin/chmod -R 755 "/Library/${orgName}"
}

installBackblaze() {
    if (! -d "/Library/${orgName}"); then
        /usr/bin/printf "Library directory ${orgName} does not exist. Creating now.\n"
        createOrgLibrary
    fi
    /usr/bin/printf "Downloading Backblaze installer to /Library/${orgName}.\n"
    /usr/bin/curl -o "/Library/${orgName}/install_backblaze.dmg" 'https://secure.backblaze.com/mac/install_backblaze.dmg'
    /usr/bin/printf "Download complete. Attaching image.\n"
    /usr/bin/hdiutil attach -nobrowse "/Library/${orgName}/install_backblaze.dmg"
    "/Volumes/Backblaze Installer/Backblaze Installer.app/Contents/MacOS/bzinstall_mate" -nogui bzdiy -signin "${login}" "${password}"
    /usr/bin/printf "BZERROR:1001 means the install was successful. Thanks for being clear about that, Backblaze.\n"
    /usr/bin/printf "Unmounting image.\n"
    /usr/sbin/diskutil unmount "/Volumes/Backblaze Installer"
    /usr/bin/printf "Removing install_backblaze.dmg\n"
    /bin/rm "/Library/${orgName}/install_backblaze.dmg"
    # /usr/bin/printf "Self-destructing.\n"; /bin/rm -- "$0"
    exit 0
}

removeBackblaze() {
    shutdown_bzbmenu
    shutdown_bzserv
    clean_library_backblaze
    clean_system_preferences_backblaze
    clean_applications_backblaze
    clean_misc
    unload_bzbmenu
    exit 0
}

restore_ac_powersetting_to_normal() {
    bz_victoryfile="/Library/Backblaze/bzdata/bzreports/bzstat_endfirstbackupmillis.txt"
    if [ ! -f $bz_victoryfile ]
    then
        pmset -c sleep 11 &amp;> /dev/null
    fi
}

shutdown_bzbmenu() {
    local output=`ps -cA | grep bzbmenu`
    if [ -n "$output" ]
    then
        killall -9 bzbmenu
    fi
}

shutdown_bzserv() {
    local output=`ps -cA | grep bzserv`
    local bz_plist='/Library/LaunchDaemons/com.backblaze.bzserv.plist'
    if [ -n "$output" ]
    then
        test -f $bz_plist && launchctl unload $bz_plist
        test -f $bz_plist && remove $bz_plist
    else
        if [ -f $bz_plist ]
        then
            remove $bz_plist
        fi
    fi
}

unload_bzbmenu() {
    for dir in /Users/*
    do
        userName=${dir:7}
        if [ $userName == 'Guest' ] || [ $userName == 'Shared' ]
        then
            continue
        fi
        bzbmenuPlist="$dir/Library/LaunchAgents/com.backblaze.bzbmenu.plist"
        if [ -f "$bzbmenuPlist" ]
        then
            sudo -u "$userName" launchctl unload "$bzbmenuPlist"
            remove "$bzbmenuPlist"
        fi
    done
}

while test $# -gt 0; do
    case "$1" in
        -i|--install)
            /usr/bin/printf "Chose to install.\n"
            installBackblaze
            shift
            ;;
        -r|--remove)
            shift
            /usr/bin/printf "Chose to remove.\n"
            removeBackblaze
            shift
            ;;
    esac
done
