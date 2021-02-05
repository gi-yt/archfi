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
  headers=("${KERNEL}-headers") 
  mkfs.fat -F 32 $part_1
  mkfs.ext4 part_2
  mkfs.ext4 part_3
  mkdir /mnt
  mount part_2 /mnt
  mkdir /mnt/boot
  mount part_1 /mnt/boot
  mkdir /mnt/home
  mount part_3 /mnt/home
  pacstrap /mnt base base-devel $KERNEL linux-firmware $headers
  genfstab -U /mnt >> /mnt/etc/fstab
  cat <<CHROOT | arch-chroot /mnt
  ln -sf /usr/share/zoneinfo/$TIMEZONEUSER /etc/localtime
  timedatectl set-timezone $TIMEZONEUSER
  echo "en_UTF-8 UTF-8" > /etc/locale.gen
  locale-gen
  touch /etc/locale.conf
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  export LANG=en_US.UTF-8
  echo $HOSTNAMEOFNEWINSTALL > /etc/hostname
   echo '127.0.0.1  localhost' | tee -a /etc/hosts
   echo '::1        localhost' | tee -a /etc/hosts
   echo '127.0.1.1  $HOSTNAMEOFNEWINSTALL' | tee -a /etc/hosts
  cat <<PASS | passwd 
  $ROOTPASSWD
  $ROOTPASSWD
  PASS
  pacman -S grub efibootmgr os-prober networkmanager
  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot
  grub-mkconfig -o /boot/grub/grub.cfg
  useradd -m -g users -G wheel $USERNAME
  cat <<PASSUSER | passwd $USERNAME
  $USERPASSWDLOL
  $USERPASSWDLOL
  PASSUSER
  systemctl enable NetworkManager.service
  CHROOT
  else
  echo "You are Using Legacy BIOS"
  umount -a
  cat <<BIOS | fdisk $IDISK
  o
  n


  +30G
  n



  w
  EFI
  partprobe
  part_1=("${$IDISK}1")
  part_2=("${IDISK}2")
  headers=("${KERNEL}-headers") 
  mkfs.ext4 part_1
  mkfs.ext4 part_2
  mkdir /mnt
  mount part_1 /mnt
  mkdir /mnt/home
  mount part_2 /mnt/home
  pacstrap /mnt base base-devel $KERNEL linux-firmware $headers
  genfstab -U /mnt >> /mnt/etc/fstab
  cat <<CHROOT | arch-chroot /mnt
  ln -sf /usr/share/zoneinfo/$TIMEZONEUSER /etc/localtime
  timedatectl set-timezone $TIMEZONEUSER
  echo "en_UTF-8 UTF-8" > /etc/locale.gen
  locale-gen
  touch /etc/locale.conf
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  export LANG=en_US.UTF-8
  echo $HOSTNAMEOFNEWINSTALL > /etc/hostname
   echo '127.0.0.1  localhost' | tee -a /etc/hosts
   echo '::1        localhost' | tee -a /etc/hosts
   echo '127.0.1.1  $HOSTNAMEOFNEWINSTALL' | tee -a /etc/hosts
  cat <<PASS | passwd 
  $ROOTPASSWD
  $ROOTPASSWD
  PASS
  pacman -S grub efibootmgr os-prober networkmanager
  grub-install $IDISK
  grub-mkconfig -o /boot/grub/grub.cfg
  useradd -m -g users -G wheel $USERNAME
  cat <<PASSUSER | passwd $USERNAME
  $USERPASSWDLOL
  $USERPASSWDLOL
  PASSUSER
  systemctl enable NetworkManager.service
  CHROOT
fi
echo "Install Finished :) "