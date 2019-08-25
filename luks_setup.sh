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

# I think this can be one command
sgdisk --zap-all --clear "$DISK" # --clear by itself may fail on a damanged disk
sgdisk --new 1:0:1G "$DISK"
sgdisk --typecode 1:ef00 "$DISK"
sgdisk --new 2:0:0 "$DISK"
sgdisk --typecode 2:8309 "$DISK" #8309 for Linux LUKS CA7D7CCB-63ED-4C53-861C-1742536059CC
#sgdisk --change-name=partnum:name
# --disk-guid=guid
# --partition-guid=partnum:guid

# b007ab1e-boot-4321-boot-b00757rapped
# pa7ch1ng-f0n7-4eff-b10b-dena7ur1z1ng

sgdisk --print "$DISK"
lsblk "$DISK"

#nvme only
BOOT="${DISK}p1"
LUKS="${DISK}p2"

# as per uuid spec (https://en.wikipedia.org/wiki/Universally_unique_identifier)
# grep -vE "g|-|(, [1-9]$)" hexwords.txt
# grep -v "-" hexwords.txt | grep -E "^.{8}," | less
# grep -v "-" hexwords.txt | grep -E "^.{4}," | less
# grep -v "-" hexwords.txt | grep -E "^4.{3}," | less
# grep -v "-" hexwords.txt | grep -E "^[8-b].{3}," | less
# grep -v "-" hexwords.txt | grep -E "^.{12}," | less

# 0b57ac1e-ba55-4807-be11-c011ec7ab1e5
# 0ff1c1a1-be57-4807-a150-d155a715f1ed
# c0deba5e-da7a-4807-a51c-d1917a11571c

cryptsetup luksFormat "$LUKS" # --uuid= (UUID in the standard UUID format, e.g. 12345678-1234-1234-1234-123456789abc)
cryptsetup luksOpen "$LUKS" nixos-enc
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

UUID="$(blkid -s UUID -o value "$LUKS")"
sed "s/UUID/$UUID/g" luks_template.nix > luks.nix

copy

nixos-install --no-root-passwd
