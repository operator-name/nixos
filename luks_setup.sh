#!/usr/bin/env bash

set -e # stop on error, TODO: change to errortrap and cleanup 
set -x # echo on, change to -v or function if this gets more complicated

lsblk

read -p "DISK: " -e DISK

sgdisk --zap "$DISK"
sgdisk --clear "$DISK"
sgdisk --new 1:0:1G "$DISK"
sgdisk --typecode 1:ef00 "$DISK"
sgdisk --new 2:0:0 "$DISK"
sgdisk --typecode 2:8e00 "$DISK"

sgdisk --print "$DISK"
lsblk "$DISK"

#nvme only
BOOT="${DISK}p1"
LVM="${DISK}p2"


cryptsetup luksFormat "$LVM" # --uuid (The UUID must be provided in the standard UUID format, e.g. 12345678-1234-1234-1234-123456789abc)
cryptsetup luksOpen "$LVM" nixos-enc
pvcreate /dev/mapper/nixos-enc
vgcreate nixos-vg /dev/mapper/nixos-enc
lvcreate -L 16G -n swap nixos-vg
lvcreate -l 100%FREE -n root nixos-vg

mkfs.vfat -n boot "$BOOT"
mkfs.ext4 -L nixos /dev/nixos-vg/root
mkswap -L swap /dev/nixos-vg/swap
swapon /dev/nixos-vg/swap

mount /dev/nixos-vg/root /mnt
mkdir -p /mnt/boot
mount "$BOOT" /mnt/boot
nixos-generate-config --root /mnt

UUID="$(blkid -s UUID -o value "$LVM")"
sed "s/UUID/$UUID/g" luks_template.nix > luks.nix

cp ./configuration.nix /mnt/etc/nixos/
cp ./luks.nix /mnt/etc/nixos/

function cleanup() {
  set +e
  umount /mnt/boot
  umount /mnt
  swapoff /dev/nixos-vg/swap
  vgchange -a n nixos-vg
  cryptsetup luksClose nixos-enc
  set -e
}
