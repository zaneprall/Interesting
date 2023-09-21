#!/bin/bash
# a file that loops through any authorized keys file it can reach, and attempts to ssh into them. 

# Loop through each user's home directory
for dir in /home/*; do
  # Check if .ssh/authorized_keys file exists
  if [[ -f "$dir/.ssh/authorized_keys" ]]; then
    # Extract hostnames from the authorized_keys file
    awk '{print $3}' "$dir/.ssh/authorized_keys" | while read -r hostname; do
      if [[ ! -z "$hostname" ]]; then
        # Attempt to SSH into each hostname
        ssh -o BatchMode=yes -o ConnectTimeout=5 "$hostname" exit &>/dev/null
        if [[ $? -eq 0 ]]; then
          echo "Successfully connected to $hostname"
        else
          echo "Failed to connect to $hostname"
        fi
      fi
    done
  fi
done
