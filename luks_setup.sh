#!/usr/bin/env bash

function cleanup() {
  set +e
  umount /mnt/boot
  umount /mnt
  swapoff /dev/nixos-vg/swap
  vgchange -a n nixos-vg
  cryptsetup luksClose nixos-enc
  set -e
}

function copy() {
  cp ./configuration.nix /mnt/etc/nixos/
  cp ./luks.nix /mnt/etc/nixos/
  cp ./locale.nix /mnt/etc/nixos/
  cp ./users.nix /mnt/etc/nixos/
}

set -e # stop on error, TODO: change to errortrap and cleanup 
set -x # echo on, change to -v or function if this gets more complicated

lsblk

read -p "DISK: " -e DISK

# https://uefi.org/sites/default/files/resources/UEFI_Spec_2_8_final.pdf
# Chapter 5
sgdisk --zap "$DISK"
sgdisk --clear "$DISK"
sgdisk --new 1:0:1G "$DISK"
sgdisk --typecode 1:ef00 "$DISK"
sgdisk --new 2:0:0 "$DISK"
sgdisk --typecode 2:8309 "$DISK" #8309 for Linux LUKS CA7D7CCB-63ED-4C53-861C-1742536059CC
#sgdisk --change-name=partnum:name

sgdisk --print "$DISK"
lsblk "$DISK"

#nvme only
BOOT="${DISK}p1"
LVM="${DISK}p2"


cryptsetup luksFormat "$LVM" # --uuid= (UUID in the standard UUID format, e.g. 12345678-1234-1234-1234-123456789abc)
cryptsetup luksOpen "$LVM" nixos-enc
pvcreate /dev/mapper/nixos-enc
vgcreate nixos-vg /dev/mapper/nixos-enc
lvcreate -L 16G -n swap nixos-vg
lvcreate -l 100%FREE -n root nixos-vg

mkfs.vfat -n boot "$BOOT" # -i b007ab1e (VOLUME-ID is a 32-bit hexadecimal number, e.g. 2e24ec82))
mkfs.ext4 -L nixos /dev/nixos-vg/root # -U (UUID in the standard UUID format, e.g. 12345678-1234-1234-1234-123456789abc)
mkswap -L swap /dev/nixos-vg/swap # -U (UUID in the standard UUID format, e.g. 12345678-1234-1234-1234-123456789abc)
swapon /dev/nixos-vg/swap

mount /dev/nixos-vg/root /mnt
mkdir -p /mnt/boot
mount "$BOOT" /mnt/boot
nixos-generate-config --root /mnt

UUID="$(blkid -s UUID -o value "$LVM")"
sed "s/UUID/$UUID/g" luks_template.nix > luks.nix

copy

nixos-install --no-root-passwd
