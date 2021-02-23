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
read -p "Do You Want NetworkManager (wifi, owned and developed by red hat), Connman(More Minimal) or dhcpcd(only wired)" NETWORKMANAGER
echo "DE, WM related stuff will be asked after the install finishes along with aur helper related stuff"
echo "Thank You For Giving The Required Information $PNAME." 
FILE="/sys/firmware/efi/efivars"
if [ -e "$FILE" ]
then
  echo "You are Using EFI"
  echo "Make Sure You Dont Have $IDISK mounted anywhere"
  parted -a optimal $IDISK --script mklabel gpt
            parted $IDISK --script mkpart primary 1MiB 513MiB
            parted $IDISK --script mkpart primary 513MiB 30000MiB
            parted $IDISK --script -- mkpart primary 30000MiB -1
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
  arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONEUSER /etc/localtime
  arch-chroot /mnt timedatectl set-timezone $TIMEZONEUSER
  arch-chroot /mnt echo "en_UTF-8 UTF-8" > /etc/locale.gen
  arch-chroot /mnt locale-gen
  arch-chroot /mnt touch /etc/locale.conf
  arch-chroot /mnt echo "LANG=en_US.UTF-8" > /etc/locale.conf
  arch-chroot /mnt export LANG=en_US.UTF-8
  arch-chroot /mnt echo $HOSTNAMEOFNEWINSTALL > /etc/hostname
  arch-chroot /mnt echo '127.0.0.1  localhost' | tee -a /etc/hosts
  arch-chroot /mnt echo '::1        localhost' | tee -a /etc/hosts
  arch-chroot /mnt echo '127.0.1.1  $HOSTNAMEOFNEWINSTALL' | tee -a /etc/hosts
  arch-chroot /mnt echo -e "$ROOTPASSWD\n$ROOTPASSWD" | passwd root
  arch-chroot /mnt pacman -S grub efibootmgr os-prober networkmanager
  arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
  arch-chroot /mnt useradd -m -g users -G wheel $USERNAME
  arch-chroot /mnt echo -e "$USERPASSWDLOL\n$USERPASSWDLOL" | passwd $USERNAME
  arch-chroot /mnt systemctl enable NetworkManager.service
  else
  echo "You are Using Legacy BIOS"
  parted $IDISK --script mklabel msdos
  parted $disk_chk --script mkpart primary ext4 1MiB 29123MiB
  parted $disk_chk --script -- mkpart primary 29123MiB -1
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
  arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONEUSER /etc/localtime
  arch-chroot /mnt timedatectl set-timezone $TIMEZONEUSER
  arch-chroot /mnt echo "en_UTF-8 UTF-8" > /etc/locale.gen
  arch-chroot /mnt locale-gen
  arch-chroot /mnt touch /etc/locale.conf
  arch-chroot /mnt echo "LANG=en_US.UTF-8" > /etc/locale.conf
  arch-chroot /mnt export LANG=en_US.UTF-8
  arch-chroot /mnt echo $HOSTNAMEOFNEWINSTALL > /etc/hostname
  arch-chroot /mnt echo '127.0.0.1  localhost' | tee -a /etc/hosts
  arch-chroot /mnt echo '::1        localhost' | tee -a /etc/hosts
  arch-chroot /mnt echo '127.0.1.1  $HOSTNAMEOFNEWINSTALL' | tee -a /etc/hosts
  arch-chroot /mnt echo -e "$ROOTPASSWD\n$ROOTPASSWD" | passwd root
  arch-chroot /mnt pacman -S grub os-prober networkmanager
  arch-chroot /mnt grub-install --target=i386-pc $IDISK
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
  arch-chroot /mnt useradd -m -g users -G wheel $USERNAME
  echo -e "$USERPASSWDLOL\n$USERPASSWDLOL" | passwd USERNAME
  systemctl enable NetworkManager.service
fi
echo "Install Finished :) "
exit 0
