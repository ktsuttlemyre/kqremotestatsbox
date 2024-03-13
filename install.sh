#!/bin/bash

prompt() {
  message="$1"
  while true; do
    if ! [ -z "$2" ]; then
      yn="$2"
    else
      read -p "$message " yn
    fi
      case $yn in
          [Yy][Ee][Ss]* )
            return ;;
          [Nn][Oo]* )
            return 1 ;;
          [Cc][Aa][Nn][Cc][Ee][Ll]* )
            return 2 ;;
          [Ee][Xx][Ii][Tt]* )
            echo "user exit"
            exit 0 ;;
          * )
          echo "Please answer yes,no,cancel or exit."
          if ! [ -z "$2" ]; then
            echo "Invalid response. Program exiting now"
            exit 1
          fi
          if ! [ -z "$3" ]; then
            yn="$3"
            2="$3"
          fi
          ;;  
      esac
  done
}

echo "Installing. Some of the commands will need sudo access. Please grant sudo use."
#do a sudo command to get the password out of the way
sudo echo "Thank you for granting sudo privileges" || exit 1

[ -f 'pi.config' ] && source pi.config

#Install
sudo apt update
if prompt "Upgrade the system?" $do_upgrade;then 
  sudo apt upgrade
fi
sudo apt install rclone fail2ban -y && sudo apt autoremove

if prompt "Replace fail2ban configs?" $replace_fail2ban_configs; then
  sudo cp -r ./fail2ban /etc/fail2ban
fi
sudo systemctl restart fail2ban

if prompt "Add rclone configs?" $replace_rclone_configs; then
  env envsubst < ./templates/rclone.conf.tpl > /$HOME/.config/rclone/rclone.conf
fi

#todo suggest changing default password?
#https://www.cyberciti.biz/faq/where-are-the-passwords-of-the-users-located-in-linux/
# https://linuxconfig.org/how-to-hash-passwords-on-linux
#line="$(sudo grep $USER /etc/shadow)"
#pswd="$(openssl passwd -6 --salt 'salt' 'password')"
#if sudo grep "$pswd" /etc/shadow; then
#  echo "you should change your default password"
#fi

if rclone config; then
  echo "Thanks for installing"
  if ! prompt "Do you wish to remain connected to the remote?"; then
    exit 0
  fi
else
  echo "There was an error while installing";
  exit 1
fi
