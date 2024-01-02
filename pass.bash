#!/bin/bash

json_data=$(bw list items --folderid SSH_FOLDER_ID | jq)

# Extract the list of usernames from the JSON
usernames=$(echo "$json_data" | jq -r '.[].login.username')

# Pipe the list of usernames to fzf and retrieve the selected username
selected_username=$(echo "$usernames" | fzf)

# Find the corresponding password for the selected username
password=$(echo "$json_data" | jq -r --arg username "$selected_username" '.[] | select(.login.username == $username) | .login.password')

# Check if the password is not empty
if [ -n "$password" ]; then
  echo "Connecting to SSH..."
  # Extract necessary information (username, host) from the selected username
  username=$(echo "$selected_username" | cut -d "@" -f 1)
  host=$(echo "$selected_username" | cut -d "@" -f 2)

  # Echo the sshpass command
  sshpass -p "$password" ssh "$username@$host"

  # Uncomment the line below to actually execute the sshpass command
  # sshpass -p "$password" ssh "$username@$host"
else
  echo "Error: Password not found for the selected username."
fi
