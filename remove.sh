#!/bin/bash

LOG_FILE="/Library/Addigy/logs/bz_removal.log"

writeToLog(){
	local LOG_DIRNAME
	LOG_DIRNAME=$(/usr/bin/dirname "${LOG_FILE}")
	if [[ ! -d "${LOG_DIRNAME}" ]]; then
		/bin/mkdir -p "${LOG_DIRNAME}"
		/usr/bin/touch "${LOG_FILE}"
		/usr/bin/printf "%s Log and log parent directory created.\n" \
			"$(/bin/date "+%Y/%m/%d %H:%M:%S")" \
			| tee -a "${LOG_FILE}"
		fi
		if [[ ! -e "${LOG_FILE}" ]]; then
			/usr/bin/touch "$LOG_FILE"
			/usr/bin/printf "%s Log created.\n" "$(/bin/date "+%Y/%m/%d %H:%M:%S")" \
				| tee -a "${LOG_FILE}"
		fi
		LOGGED_MESSAGE="$*"
		/usr/bin/printf "%s $LOGGED_MESSAGE\n" "$(/bin/date "+%Y/%m/%d %H:%M:%S")" \
			| tee -a "$LOG_FILE"
}

clean_applications_backblaze() {
    local BZ_APP
		BZ_APP='/Applications/Backblaze.app'
    if [ -d "$BZ_APP" ]
    then
        /bin/rm -Rf "$BZ_APP"
    fi
}

clean_library_backblaze() {
    local BZ_PKGS BZ_APPS
		BZ_PKGS='/Library/Backblaze.bzpkg'
		BZ_APPS='/Library/Backblaze'
    if [ -d "$BZ_APPS" ]
    then
        /bin/rm -Rf "$BZ_APPS"
    fi
    if [ -d "$BZ_PKGS" ]
    then
        /bin/rm -Rf "$BZ_PKGS"
    fi
}

clean_misc() {
    local BZ_EXTBX
		BZ_EXTBX="/Library/Application Support/ExtBX"
    if [ -d "$BZ_EXTBX" ]
    then
        /bin/rm -Rf "$BZ_EXTBX"
    fi
}

clean_system_preferences_backblaze() {
    local BZ_PREF_PANE
		BZ_PREF_PANE='/Library/PreferencePanes/BackblazeBackup.prefPane'
    if [ -d "$BZ_PREF_PANE" ]
    then
        /bin/rm -Rf "$BZ_PREF_PANE"
    fi
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
	local BZ_VICTORYFILE
	BZ_VICTORYFILE="/Library/Backblaze/bzdata/bzreports/bzstat_endfirstbackupmillis.txt"
	if [ ! -f $BZ_VICTORYFILE ]; then
		/usr/bin/pmset -c sleep 11 > /dev/null
	fi
}

shutdown_bzbmenu() {
	local OUTPUT
	OUTPUT=`ps -cA | grep bzbmenu`
	if [ -n "$OUTPUT" ]
	then
		/usr/bin/killall -9 bzbmenu
	fi
}

shutdown_bzserv() {
	local OUTPUT BZ_PLIST
	OUTPUT=`ps -cA | grep bzserv`
	BZ_PLIST='/Library/LaunchDaemons/com.backblaze.bzserv.plist'
	if [ -n "$OUTPUT" ]; then
		test -f $BZ_PLIST && /bin/launchctl unload $BZ_PLIST
		test -f $BZ_PLIST && /bin/rm $BZ_PLIST
	elif [ -f $BZ_PLIST ]; then
		/bin/rm $BZ_PLIST
	fi
}

unload_bzbmenu() {
	for dir in /Users/*; do
		USER_NAME=${dir:7}
		if [ $USER_NAME == 'Guest' ] || [ $USER_NAME == 'Shared' ]; then
			continue
		fi
		BZ_MENU_PLIST="$dir/Library/LaunchAgents/com.backblaze.bzbmenu.plist"
		if [ -f "$BZ_MENU_PLIST" ]; then
			sudo -u "$USER_NAME" launchctl unload "$BZ_MENU_PLIST"
			/bin/rm "$BZ_MENU_PLIST"
		fi
	done
}

removeBackblaze
