# Backblaze Installer

This set of scripts will install Backblaze on a workstation. This script is helpful if you want to automate the deployment of the latest version of Backblaze to a fleet.

## Things to Consider
1. This installer assumes that you're using Backblaze groups, and that you're creating individual accounts within that group by whitelisting email domains.
2. This installer allows Backblaze to generate a unique password. To recover, the user will need to reset her or his password.
3. Cirrus Partners, LLC and I (Benjamin Morales) are in no way responsible for any negative affect using this installer may have on your business, the businesses you support, people you support, your dog, etc. This is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. The source of the installer is open to your review, and YOU ARE RESPONSIBLE for your own actions and use of these scripts. If you notice a problem, feel free to talk to me on the MacAdmin's Slack Channel (@bmorales), or make a pull request.
4. The removal script is an adaptation of an old removal script from Backblaze.
5. The installer will attempt to register to Backblaze the user with the lowest UID > 500 that is not in the IGNORED_USERS array.

## How to Install

#### Prepare "variables" file
1. IGNORED_USERS: this is an array of macOS users who should not be used for licensing the Backblaze account. Put each username in single quotes, separating multiple users with new lines.
2. Uncomment the correct email username pattern (EMAIL_USERNAME). Remove the `#` before the line that matches your organization's email username pattern. This will pull the name as entered into macOS, so if your user's email address doesn't match the username on the Mac, your going to get frustrated. It will still allow you to register, but it's going to be a mess for your for your end user if they try to recover files on their own. Get on top of that!
3. SEPARATING_CHAR: If you have a `.` or `-` or something silly like that in your organization's email addresses, you can enter that here. Leaving it at `''` will keep it from adding a character.
4. EMAIL_DOMAIN: For example, `@gocirrus.com` or `gocirrus.com`. It doesn't matter whether you add the `@`
5. BZ_GROUP_ID: Find at backblaze.com. In your admin account, **Group Management** > **Send Invites** > **Advanced Instructions**. The group ID is the four digit code in the *Mac* section, where it talks about executing a command in a terminal window.
6. BZ_GROUP_TOKEN: The group token can be found next to the group ID; it's the longer string of random numbers.

#### Load to Addigy
1. Alter the names of `backblazer.sh` and `variables` so that they're uniquely identifiable within Addigy. Maybe `identifier-variables`, for example.
2. Adjust the `source` command in `backblazer.sh` to match the new name of the variables file.
3. Go to create a piece of custom software (see https://addigy.freshdesk.com/support/solutions/articles/8000042895-creating-custom-software)
4. Upload "\*-backblazer.sh" and "\*-variables" as separate files.
5. Copy the contents of install.sh to the "Installation" box.
6. Copy the contents of condition.sh to the "Conditions Script" box.
7. Copy the contents of remove.sh to the "Remove Script" box.
