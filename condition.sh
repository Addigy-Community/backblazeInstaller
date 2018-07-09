#!/bin/bash
if [ -e "/Library/Backblaze.bzpkg/bztransmit" ]; then
  /usr/bin/printf "Backblaze already installed. Skipping.\n"
  exit 1
else
  /usr/bin/printf "Backblaze not installed. Attempting to install now...\n"
  exit 0
fi
