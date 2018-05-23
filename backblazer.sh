#!/bin/bash
source ./variables

EMAIL_DOMAIN="$(/usr/bin/printf "$EMAIL_DOMAIN" | sed 's/@//')"
BZ_PASSWORD="$(/usr/bin/uuidgen)"
LOG_FILE="/Library/Addigy/logs/bz_install.log"
BACKBLAZER_DIR="/Library/Backblazer"

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

getBzUsername(){
	local REAL_NAME FIRST_NAME LAST_NAME
	REAL_NAME="$(/usr/bin/dscl . -read "/Users/$1" RealName | /usr/bin/grep -vE '^RealName:$' | /usr/bin/sed 's/^ //' | /usr/bin/tr '[:upper:]' '[:lower:]')"
	FIRST_NAME="$(/usr/bin/printf "$REAL_NAME" | sed -E 's/ .*$//')"
	LAST_NAME="$(/usr/bin/printf "$REAL_NAME" | sed 's/^.* //')"
	if [[ "$EMAIL_USERNAME" == "FULLNAME" ]]; then
		EMAIL_USERNAME="${FIRST_NAME}${SEPARATING_CHAR}${LAST_NAME}"
	elif [[ "$EMAIL_USERNAME" == "FIRST-INITIAL_LAST-NAME" ]]; then
		EMAIL_USERNAME="${FIRST_NAME:0:1}${SEPARATING_CHAR}${LAST_NAME}"
	elif [[ "$EMAIL_USERNAME" == "FIRST-NAME_LAST-INITIAL" ]]; then
		EMAIL_USERNAME="${FIRST_NAME}${SEPARATING_CHAR}${LAST_NAME:0:1}"
	elif [[ "$EMAIL_USERNAME" == "FIRST-NAME" ]]; then
		EMAIL_USERNAME="${FIRST_NAME}"
	elif [[ "$EMAIL_USERNAME" == "LAST-NAME" ]]; then
		EMAIL_USERNAME="${LAST_NAME}"
	else
		writeToLog "EMAIL_USERNAME not set. Exiting"
		exit 1
	fi
	/usr/bin/printf "$EMAIL_USERNAME@$EMAIL_DOMAIN"
}

# Iterate through users, checking that the user is not in the ignored user list.
# The first user with a UID > 500 and not on the ignored user list will be used
# for licensing Backblaze.
for ITERATED_USER in $(dscl . list /Users UniqueID | awk '$2 >= 500 {print $1}'); do
	let IGNORE_LIST_HIT=0
	for IGNORED_USER in "${IGNORED_USERS[@]}"; do
		if [[ "$ITERATED_USER" == "$IGNORED_USER" ]]; then
			writeToLog "$ITERATED_USER is on ignore list."
			let IGNORE_LIST_HIT++
			break
		fi
	done
	if [[ ! $IGNORE_LIST_HIT -gt 0 ]]; then
		BZ_LOGIN="$(getBzUsername $ITERATED_USER)"
		break
	fi
done

# If no viable user was found, exit without installing Backblaze.
if [[ "$BZ_LOGIN" == '' ]]; then
	writeToLog "No viable user account found. Exiting."
	exit 1
fi

# Check if Backblazer was triggered for the purpose of updating the client.
if [ -f "/Library/Backblaze/bztransmit" ] || [ -f "/Library/Backblaze.bzpkg/bztransmit" ]; then
	writeToLog "Backblaze already installed. Checking if update is required."
	if [[ -f "${BACKBLAZER_DIR}/updateRequired" ]]; then
		writeToLog "Update required. Overwriting login and password variables."
		BZ_LOGIN="$(/bin/cat "$BACKBLAZER_DIR/BZ_1")"
		BZ_PASSWORD="$(/bin/cat "$BACKBLAZER_DIR/BZ_2")"
	else
		writeToLog "Update not required. Exiting."
		exit 1
	fi
fi

# Create a secure temporary directory for the Bz Installer
TMP_DIR="$(/usr/bin/mktemp -d "/tmp/$(/usr/bin/basename "$0").XXXXXX")"
if [ $? -eq "0" ] && [ -e "$TMP_DIR" ]; then
	writeToLog "$TMP_DIR created successfully."
else
	writeToLog "$TMP_DIR not created. Exiting."
	exit 1
fi

# Download the Bz Installer from Backblaze's website.
writeToLog "Downloading latest Backblaze installer to ${TMP_DIR}."
/usr/bin/curl -o "${TMP_DIR}/install_backblaze.dmg" 'https://secure.backblaze.com/mac/install_backblaze.dmg' &> /dev/null

# Attach image using nobrowse to prevent it from showing on the desktop.
writeToLog "Attaching ${TMP_DIR}/install_backblaze.dmg."
/usr/bin/hdiutil attach -nobrowse "${TMP_DIR}/install_backblaze.dmg" &> /dev/null

# Run the silent installer, passing the necessesary credentials as the arguments.
writeToLog "Installing Backblaze."
"/Volumes/Backblaze Installer/Backblaze Installer.app/Contents/MacOS/bzinstall_mate" -nogui -createaccount $BZ_LOGIN $BZ_PASSWORD $BZ_GROUP_ID $BZ_GROUP_TOKEN 2> /dev/null

writeToLog "Sleeping while Bz configures itself."
/bin/sleep 15

if [ -f "/Library/Backblaze/bztransmit" ] || [ -f "/Library/Backblaze.bzpkg/bztransmit" ]; then
	writeToLog "Backblaze is running."
else
	writeToLog "Backblaze is not running. Installation was not successful. Sending ticket."
	/usr/bin/curl -X POST https://$(/Library/Addigy/go-agent agent realm).addigy.com/submit_ticket/ -H 'content-type: application/json' -d "{\"agentid\": \"$(/Library/Addigy/go-agent agent agentid)\", \"orgid\":\"$(/Library/Addigy/go-agent agent orgid)\", \"name\":\"${BZ_LOGIN}\", \"description\":\"Failed to install Backblaze.\"}" &> /dev/null
fi

# Unmount and delete DMG.
writeToLog "Unmounting image."
/usr/sbin/diskutil unmount "/Volumes/Backblaze Installer" &> /dev/null
writeToLog "Removing install_backblaze.dmg"
/bin/rm -Rf "${TMP_DIR}"

# Preserving login and password variables for future updates.
if [[ ! -e "$BACKBLAZER_DIR" ]]; then
	/bin/mkdir "$BACKBLAZER_DIR"
fi
/bin/chmod 700 "$BACKBLAZER_DIR" # Ensure non-admin users cannot access the dir.
/usr/bin/printf "$BZ_LOGIN" > "$BACKBLAZER_DIR/BZ_1"
/usr/bin/printf "$BZ_PASSWORD" > "$BACKBLAZER_DIR/BZ_2"

# Clear any updateRequired indicator
if [[ -f "$BACKBLAZER_DIR/updateRequired" ]]; then
	writeToLog "Removing $BACKBLAZER_DIR/updateRequired"
	/bin/rm "$BACKBLAZER_DIR/updateRequired"
fi

exit 0
