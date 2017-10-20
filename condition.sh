#!/bin/bash
newestBzVersion=$(curl "https://secure.backblaze.com/api/clientversion.xml" | grep "mac_version" | awk '{ print $1 }' | cut -d '"' -f2)
installedBzVersion=$(/usr/bin/defaults read "/Applications/Backblaze.app/Contents/Info.plist" CFBundleShortVersionString)
addigyPackage='CP - BackBlaze Install (1.0.1)/cp-backblazer.sh'

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

if [ -e "/Library/Backblaze.bzpkg/bztransmit" ]; then
    /usr/bin/printf "Backblaze already installed. Checking if update required.\n"
    vercomp ${newestBzVersion} ${installedBzVersion}
    COMP=$? # 0 means the same, 1 means TARGET is newer, 2 means INSTALLED is newer
    /usr/bin/printf "COMPARISON: %s" "${COMP}"

    if [ "${COMP}" -eq 1 ]
    then
        /usr/bin/printf "Installed version is older than %s.\n" "${newestBzVersion}"
        /usr/bin/printf "Attempting to install.\n"
        exit 0
    else
        /usr/bin/printf "Installed version is the same or newer than the %s. No installation attempt wil be made.\n" "${newestBzVersion}"
        exit 1
    fi
else
    echo "Backblaze not installed. Attempting to install now..."
    exit 0
fi
