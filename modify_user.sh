#!/bin/bash

# Handle Ctrl+C
trap "echo -e '\nScript interrupted by user. Exiting...'; exit 1" SIGINT

# Check for root permission
if [ "$EUID" -ne 0 ]; then
  whiptail --msgbox "Please run this script as root (use sudo)." 10 40
  exit 1
fi

# Main menu
option=$(whiptail --title "Modify User" --menu "Choose an operation:" 15 60 4 \
"1" "Change Password" \
"2" "Change Primary Group" \
"3" "Change Login Shell" 3>&1 1>&2 2>&3)

# Ask for username
username=$(whiptail --inputbox "Enter the username to modify:" 10 60 3>&1 1>&2 2>&3)

# Validate username
if ! id "$username" &>/dev/null; then
  whiptail --msgbox "User '$username' does not exist!" 10 40
  exit 1
fi

case $option in
  "1")  # Change Password
    whiptail --msgbox "You will now change the password in terminal." 10 50
    passwd "$username"
    echo "$(date): Password changed for $username" >> /var/log/user_mgmt.log
    ;;

  "2")  # Change Primary Group
    new_group=$(whiptail --inputbox "Enter the new primary group:" 10 60 3>&1 1>&2 2>&3)

    # Validate group
    if ! getent group "$new_group" > /dev/null; then
      whiptail --msgbox "Group '$new_group' does not exist!" 10 40
      exit 1
    fi

    usermod -g "$new_group" "$username"
    echo "$(date): Primary group for $username changed to $new_group" >> /var/log/user_mgmt.log
    ;;

  "3")  # Change Login Shell
    new_shell=$(whiptail --inputbox "Enter the new shell (e.g., /bin/bash):" 10 60 3>&1 1>&2 2>&3)

    # Validate shell
    if ! grep -qx "$new_shell" /etc/shells; then
      whiptail --msgbox "Shell '$new_shell' is invalid!" 10 40
      exit 1
    fi

    usermod -s "$new_shell" "$username"
    echo "$(date): Login shell for $username changed to $new_shell" >> /var/log/user_mgmt.log
    ;;
esac

whiptail --msgbox "Modification for '$username' completed." 10 40
