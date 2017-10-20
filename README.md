# Backblaze Installer

This set of scripts will install Backblaze on a workstation and ensure that it stays up-to-date with the latest version from Backblaze. This script is helpful if you want to automate the deployment of the latest version of Backblaze to a fleet, but you loose some control over the environment, as it upgrades as though you had auto-update turned on.

## CAUTION!!
This script has a few things that may be considered unacceptable in high-security environments: 

First, it stores a script that contains the password to the machine's Backblaze account in plain text on the hard drive. Addigy transmits over HTTPS, so thats good, but make sure you don't use this script on machines that don't have FV2 (but, why the hell wouldn't you have FV2 when Addigy makes it so easy?!). If this is an unnacceptable risk for you, please, uncomment the line ```/usr/bin/printf "Self-destructing.\n"; /bin/rm -- "$0"``` in backblazer.sh; this will cause the script to self-destruct, but you'll also lose the abillity for the script to remove Backblaze.

Second, this script will automatically install the latest version of Backblaze from their website. If anyone were to hijack 'https://secure.backblaze.com/mac/install_backblaze.dmg', you'd be royally screwed. A work around would be to set up a different source for install_backblaze.dmg, and place a trusted version in that location. If anyone in the community wants to be responsible for that, I'd be happy to assist. Realistically, keeping autoupdate poses the same risk.

## How to Install
### Prepare the Variables
#### backblazer.sh
1. Change ```orgName``` to match your company name. This will create a directory in the library that will be used as the download location for the Backblaze Installer DMG.
2. Change ```login``` to match the email address associated with Backblaze account to which you'd like to backup the computer.
3. Change ```password``` to match the password associated with the ```login``` account.

#### install.sh and remove.sh
1. Change ```addigyWorkingDir``` to match the name of your custom software in Addigy. For example, if I created this as a custom software item in Addigy called "Cirrus Backblaze", and if it labeled it version "1.0.0", I'd change string of ```addigyWorkingDir``` from ```'CHANGE_ME (X.X.X)'``` to ```'Cirrus Backblaze (1.0.0)'```.
2. Change ```backblazer``` to match the name of your backblazer.sh file. You'll want to change this to something unique for each client. For example, if it's for Cirrus Partners, I would change it from ```'backblazer.sh'``` to ```'cp-backblazer.sh'```, and I would make sure that the actual backblazer.sh file matches that variable *exactly*.

### Load to Addigy
1. Go to create a piece of custom software (see https://addigy.freshdesk.com/support/solutions/articles/8000042895-creating-custom-software)
2. The Software Identifier and Version correspond to ```addigyWorkingDir```.
3. Upload your copy of the backblazer.sh script, changing the name as discussed in "Prepare the Variables."
4. Copy the contents of install.sh to the "Installation" box.
5. Copy the contents of condition.sh to the "Conditions Script" box.
6. Copy the contents of remove.sh to the "Remove Script" box.
