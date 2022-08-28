#!/bin/zsh
timedatectl set-ntp true
echo ", 512M" > temp.txt
echo ", 1G" >> temp.txt
echo ", ," >> temp.txt
sfdisk /deb/sdb --force << temp.txt
rm temp.txt
mkfs.ext4 /dev/sdb3
mkswap /dev/sdb2
mkfs.fat -F 32 /dev/sdb1
mount /dev/sdb3 /mnt
mount --mkdir /dev/sdb1 /mnt/boot
swapon /dev/sdb2
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
