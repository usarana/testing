#!/bin/zsh
read "ht?Enter hostname "
read "dsk?Enter disk "
read "pass?Enter root password "
ip link
timedatectl set-ntp true
(
echo n
echo p
echo 1
echo 2048
echo +512M
echo n
echo p
echo 2
echo 1050624
echo +1G
echo n
echo p
echo 3
echo 3147776
echo \n
) | fdisk /dev/sda
mkfs.ext4 /dev/sda3
mkswap /dev/sda2
mkfs.fat -F 32 /dev/sda1
mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
(
ln -sf /usr/share/zoneinfo/Europe/Sofia /etc/localtime
hwclock --systohc
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "arch" > /etc/hostname
mkinitcpio -P
passwd
grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
exit
) | arch-chroot /mnt
umount -R /mnt
