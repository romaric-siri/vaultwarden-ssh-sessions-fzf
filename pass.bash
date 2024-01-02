#!/bin/bash

# Factorized command to get the Bitwarden items JSON
json_data=$(bw list items --folderid FOLDER_UID | jq)

# Extract the list of usernames and Bitwarden names from the JSON
usernames_and_names=$(echo "$json_data" | jq -r '.[] | "\(.login.username) (\(.name))"')

# Pipe the list of usernames and Bitwarden names to fzf and retrieve the selected entry
selected_entry=$(echo "$usernames_and_names" | fzf)

# Extract the selected username and Bitwarden name
selected_username=$(echo "$selected_entry" | awk '{print $1}')

# Find the corresponding password for the selected username
password=$(echo "$json_data" | jq -r --arg username "$selected_username" '.[] | select(.login.username == $username) | .login.password')

# Check if the password is not empty
if [ -n "$password" ]; then
  echo "Connecting to SSH..."
  # Extract necessary information (username, host) from the selected username
  username=$(echo "$selected_username" | cut -d "@" -f 1)
  host=$(echo "$selected_username" | cut -d "@" -f 2)

  # Echo the sshpass command with Bitwarden name
  sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$host"

  # Uncomment the line below to actually execute the sshpass command
  # sshpass -p "$password" ssh "$username@$host"
else
  echo "Error: Password not found for the selected username."
fi

# Display the Bitwarden name
echo "Bitwarden Name: $selected_bw_name"
