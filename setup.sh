#!/usr/bin/env bash

function main() {
  # stop on error, TODO: change to errortrap and cleanup functions
  set -e
  # Print commands as they are executed, change to -v or manual if this gets more complicated (loops)
  set -x 

  # if [ -z "$1" ] then
  #   sgdisk --print "$DISK"
  #   lsblk --output name,size,partuuid "$DISK"
  # fi 
  DISK="/dev/nvme0n1"
  #nvme only
  BOOT="${DISK}p1"
  LUKS="${DISK}p2"

  partition "$DISK"

  sgdisk --print "$DISK"
  sgdisk --info=1 "$DISK"
  sgdisk --info=2 "$DISK"

  mkfs-boot "$BOOT"
  mkfs-luks-lvm "$LUKS"

  UUID="$(blkid -s UUID -o value "$LUKS")"

  lsblk --output +LABEL,UUID,PTUUID,PARTLABEL,PARTUUID "$DISK"

  mount-install "$BOOT"

  lsblk --output +LABEL,UUID,PTUUID,PARTLABEL,PARTUUID "$DISK"
}

function cleanup() {
  set +e
  umount /mnt/boot
  umount /mnt
  swapoff /dev/nixos-vg/swap
  vgchange --activate n nixos-vg
  cryptsetup luksClose nixos-luks
  set -e
}

function partition() {
  local DISK="$1"

  # Create new GPT parition, --clear by itself may fail on a damanged disk
  sgdisk --zap-all --clear --disk-guid=7ac71ca1-ac1d-4321-fa7e-d155a7151fed "$DISK" 
  # Boot parition
  sgdisk --new 1:0:1G --typecode=1:ef00 --change-name=1:"boot" --partition-guid=1:b007ab1e-b007-4321-b007-b007ab1eb105 "$DISK"
  # LUKS parition as code 8309
  sgdisk --new 2:0:0  --typecode=2:8309 --change-name=2:"luks" --partition-guid=2:5ca1ab1e-c01a-4321-ba11-c011ec71b1e5 "$DISK"
}

function mkfs-boot() {
  local BOOT="$1"
  mkfs.fat -n boot -i b007ab1e "$BOOT"
}

function mkfs-luks-lvm() {
  local LUKS="$1"
  
  cryptsetup luksFormat --uuid=0b57ac1e-ba55-4807-be11-c011ec7ab1e5 "$LUKS"
  cryptsetup luksOpen "$LUKS" nixos-luks
  
  pvcreate --norestorefile --uuid places-that-home-swap-both-rest-opened /dev/mapper/nixos-luks
  vgcreate nixos-vg /dev/mapper/nixos-luks
  lvcreate --size 32G --name swap nixos-vg
  lvcreate --extents 100%FREE --name root nixos-vg

  mkfs.ext4 -L nixos -U 0ff1c1a1-be57-4807-a150-d155a715f1ed /dev/nixos-vg/root
  mkswap --label swap --uuid c0deba5e-da7a-4807-a51c-d1917a11571c /dev/nixos-vg/swap
}

function mount-install() {
  local BOOT="$1"
  # assumes luksOpen and vg called nixos-vg

  swapon /dev/nixos-vg/swap
  mount /dev/nixos-vg/root /mnt
  mkdir --parents /mnt/boot
  mount "$BOOT" /mnt/boot
  
  git clone https://github.com/operator-name/nixos.git /mnt/etc/nixos
  chown --recursive 7919 /mnt/etc/nixos

  nixos-generate-config --no-filesystems --root /mnt
  
  nixos-install --no-root-passwd
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi