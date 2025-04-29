#!/bin/bash

log_file="$(pwd)/user_mgmt.log"


# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]
then
    echo "❌ Please run as root."
    exit 1
fi

# Prompt for username
read -rp "Enter new username: " username
# Validate username
if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]
then
    echo "❌ Invalid username. Must start with a letter or underscore, followed by lowercase letters, digits, underscores, or dashes."
    exit 1
fi

# Check if user already exists
if id "$username" &>/dev/null
then
    echo "❌ User '$username' already exists."
    exit 1
fi

# Prompt for password
read -rsp "Enter password: " password
echo
read -rsp "Confirm password: " password_confirm
echo

# Check if passwords match
if [ "$password" != "$password_confirm" ]
then
    echo "❌ Passwords do not match."
    exit 1
fi

# Create user with home directory and default shell
if useradd -m -s /bin/bash "$username"
then
    echo "$username:$password" | chpasswd
    echo "✅ User '$username' created successfully."
    log_message "User '$username' created."
else
    echo "❌ Failed to create user '$username'."
    log_message "Failed to create user '$username'."
    exit 1
fi
