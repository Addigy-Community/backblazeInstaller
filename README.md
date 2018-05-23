# Backblaze Installer

This set of scripts will install Backblaze on a workstation and ensure that it stays up-to-date with the latest version from Backblaze. This script is helpful if you want to automate the deployment of the latest version of Backblaze to a fleet, but you loose some control over the environment, as it upgrades as though you had auto-update turned on.

## Things to Consider
1. This installer assumes that you're using Backblaze groups, and that you're creating individual accounts within that group by whitelisting email domains.
2. This installer generates a random password for the user's Backblaze account. This password is stored on the hard drive in plain text, though it's hidden from people without Admin rights. If a user needs to recover some files, they can do a password reset at https://secure.backblaze.com/forgot_password.htm. Otherwise, an admin can find the password at `/Library/Backblazer/BZ_2`. It's just a UUID. If they change their password, that `BZ_2` file will need to be updated to match; otherwise, upgrades will fail in the future.
3. Cirrus Partners, LLC and I (Benjamin Morales) are in no way responsible for any negative affect using this installer may have on your business, the businesses you support, people you support, your dog, etc. This is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. The source of the installer is open to your review, and YOU ARE RESPONSIBLE for your own actions and use of these scripts. If you notice a problem, feel free to talk to me on the MacAdmin's Slack Channel (@bwmorales), or make a pull request.
4. The removal script is an adaptation of an old removal script from Backblaze.

## How to Install

#### Prepare "variables" file
1. IGNORED_USERS: this is an array of macOS users who should not be used for licensing the Backblaze account. Put each username in single quotes, separating multiple users with new lines.
2. Uncomment the correct email username pattern (EMAIL_USERNAME). Remove the `#` before the line that matches your organization's email username pattern. This will pull the name as entered into macOS, so if your user's email address doesn't match the username on the Mac, your going to get frustrated. It will still allow you to register, but it's going to be a mess for your for your end user if they try to recover files on their own. Get on top of that!
3. SEPARATING_CHAR: If you have a `.` or `-` or something silly like that in your organization's email addresses, you can enter that here. Leaving it at `''` will keep it from adding a character.
4. EMAIL_DOMAIN: For example, `@gocirrus.com` or `gocirrus.com`. It doesn't matter whether you add the `@`
5. BZ_GROUP_ID: Find at backblaze.com. In your admin account, **Group Management** > **Send Invites** > **Advanced Instructions**. The group ID is the four digit code in the *Mac* section, where it talks about executing a command in a terminal window.
6. BZ_GROUP_TOKEN: The group token can be found next to the group ID; it's the longer string of random numbers.

#### Load to Addigy
1. Go to create a piece of custom software (see https://addigy.freshdesk.com/support/solutions/articles/8000042895-creating-custom-software)
2. Upload "backblazer.sh" and "variables" as separate files.
4. Copy the contents of install.sh to the "Installation" box.
5. Copy the contents of condition.sh to the "Conditions Script" box.
6. Copy the contents of remove.sh to the "Remove Script" box.
