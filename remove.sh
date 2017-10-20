# Be sure to carefully match the below variables to your particular Addigy instance.

addigyWorkingDir='CHANGE_ME (X.X.X)'
backblazer='backblazer.sh'

/bin/bash "/Library/Addigy/ansible/packages/${addigyWorkingDir}/${backblazer}" -r
