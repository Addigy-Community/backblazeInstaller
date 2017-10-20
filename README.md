# Backblaze Installer

This set of scripts will install Backblaze on a workstation and ensure that it stays up-to-date with the latest version from Backblaze.

## CAUTION!!
This script has a few things that may be considered unacceptable in high-security environments: 

First, it stores a script that contains the password to the machine's Backblaze account in plain text on the hard drive. Addigy transmits of HTTPS, so thats good, but make sure you dont use this script on machines that don't have FV2 (but, why the hell wouldn't you have FV2 when Addigy makes it so easy?!)

Second, this script will automatically install the latest version of Backblaze from their website. If anyone were to hijack 'https://secure.backblaze.com/mac/install_backblaze.dmg', you'd be royally screwed. A work around would be to set up a different source for install_backblaze.dmg, and place a trusted version in that location. If anyone in the community wants to be responsible for that, I'd be happy to assist.

## How to Install
1. Change the variables in install.sh and remove.sh to reflect the proper addigyWorkingDir and backblazer names. You'll likely have a different package for each of your clients, since you wouldn't want to load passwords that cut accross multiple clients. I mean, unless you like being unemployed.
2. Upload the backblazer.sh file to Addigy.
