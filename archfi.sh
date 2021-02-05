#! /bin/bash
read -p "Hi What Is Your Name Sir : " PNAME
echo "Hi $PNAME"
lsblk
read -p "Choose The Disk You Want To Install Arch To (eg. /dev/sda) " IDISK
echo "You Have Chosen $IDISK"
echo "Welcome To The Installer $PNAME" 
echo "Click CTRL + c to exit the script. This May result in an unusable setup"
echo "Now The Installer is going to ask you about few basic things."
read -p "What is the timezone you want to use eg. Asia/Kolkata for IST : " TIMEZONEUSER
read -p "What Hostname Do You Want To use : " HOSTNAMEOFNEWINSTALL
read -p "What Is Your ROOT PASSWORD. Note: Passwords entered during the install will be visible :) : " ROOTPASSWD
read -p "what is The Username Of The User : " USERSNAME
read -p "What is the password of the normal user : " USERSPASSWDLOL
read -p "What Linux Kernel Do You Want to use (options are linux linux-zen linux-lts)" KERNEL
read -p "What bootloader do you want to use (options are grub and systemd-boot BTW you cant use systemd-boot with legacy bios)" BOOTLOADER
echo "DE, WM related stuff will be asked after the install finishes along with aur helper related stuff"
echo "Thank You For Giving The Required Information $PNAME." 
FILE="/sys/firmware/efi/efivars"
if [ -e "$FILE" ]
then
  echo "You are Using EFI"
umount -a
  cat <<EFI | fdisk $IDISK
  g
  n


  +512M
  n


  +30G
  n



  w
  EFI
  partprobe
  part_1=("${$IDISK}1")
  part_2=("${IDISK}2")
  part_3=("${IDISK}3")
  mkfs.fat -F 32 $part_1
  mkfs.ext4 part_2
  mkfs.ext4 part_3


  

  else
  echo lo
fi