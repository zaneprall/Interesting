#!/bin/bash

# Loop through each user's home directory
for dir in /home/*; do
  # Check if .ssh/authorized_keys file exists
  if [[ -f "$dir/.ssh/authorized_keys" ]]; then
    # Extract hostnames from the authorized_keys file
    awk '{print $3}' "$dir/.ssh/authorized_keys" | while read -r hostname; do
      if [[ ! -z "$hostname" ]]; then
        # Open an SSH connection and leave it open
        ssh -o BatchMode=yes -o ConnectTimeout=5 -f -N "$hostname" &
        pid=$!
        echo "SSH connection to $hostname started with PID $pid"
      fi
    done
  fi
done
