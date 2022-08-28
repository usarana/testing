#!/bin/bash
read -p "Enter hostname: " ht
read -p "Enter disk: " dsk
read -p "Enter root password: " pass
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
) | fdisk ${dsk}
mkfs.ext4 ${dsk}3
mkswap ${dsk}2
mkfs.fat -F 32 ${dsk}1
mount ${dsk}3 /mnt
mount --mkdir ${dsk}1 /mnt/boot
swapon ${dsk}2
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
(
ln -sf /usr/share/zoneinfo/Europe/Sofia /etc/localtime
hwclock --systohc
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$ht" > /etc/hostname
mkinitcpio -P
echo "$pass" | passwd
grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
exit
) | arch-chroot /mnt
umount -R /mnt
