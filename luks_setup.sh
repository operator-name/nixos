#!/usr/bin/env bash

function main() {
  set -e # stop on error, TODO: change to errortrap and cleanup 
  set -x # echo on, change to -v or function if this gets more complicated

  # if [ -z "$1" ] then
  #   sgdisk --print "$DISK"
  #   lsblk --output name,size,partuuid "$DISK"
  # fi 
  DISK="/dev/nvme0n1"
  #nvme only
  BOOT="${DISK}p1"
  LUKS="${DISK}p2"

  partition "$DISK"
  mkfs-boot "$BOOT"
  mkfs-luks-lvm "$LUKS"

  UUID="$(blkid -s UUID -o value "$LUKS")"

  mount-install "$UUID"
}

function cleanup() {
  set +e
  umount /mnt/boot
  umount /mnt
  swapoff /dev/nixos-vg/swap
  vgchange -a n nixos-vg
  cryptsetup luksClose nixos-luks
  set -e
}

function partition() {
  local DISK="$1"

  # Create new GPT parition, --clear by itself may fail on a damanged disk
  sgdisk --zap-all --clear --disk-guid=7ac71ca1-ac1d-4f0r-fa7e-d155a7151fed "$DISK" 
  # Boot parition
  sgdisk --new 1:0:1G --typecode 1:ef00 --change-name=1:"boot" --partition-guid=1:b007ab1e-boot-4321-boot-b00757rapped "$DISK"
  # LUKS parition as code 8309 (CA7D7CCB-63ED-4C53-861C-1742536059CC)
  sgdisk --new 2:0:0 --typecode 2:8309 --change-name=2:"luks" --partition-guid=2:pa7ch1ng-f0n7-4eff-b10b-dena7ur1z1ng "$DISK"
}

function mkfs-boot() {
  local BOOT="$1"
  mkfs.vfat -n boot -i b007ab1e "$BOOT"
}

function mkfs-luks-lvm() {
  local LUKS="$1"
  
  cryptsetup luksFormat --uuid=0b57ac1e-ba55-4807-be11-c011ec7ab1e5 "$LUKS"
  cryptsetup luksOpen "$LUKS" nixos-luks
  
  pvcreate /dev/mapper/nixos-luks
  vgcreate nixos-vg /dev/mapper/nixos-luks
  lvcreate -L 32G -n swap nixos-vg
  lvcreate -l 100%FREE -n root nixos-vg

  mkfs.ext4 -L nixos -U 0ff1c1a1-be57-4807-a150-d155a715f1ed /dev/nixos-vg/root
  mkswap -L swap -U c0deba5e-da7a-4807-a51c-d1917a11571c /dev/nixos-vg/swap
}

function mount-install() {
  local UUID="$1"
  # assumes luksOpen and vg called nixos-vg

  swapon /dev/nixos-vg/swap
  mount /dev/nixos-vg/root /mnt
  mkdir -p /mnt/boot
  mount "$BOOT" /mnt/boot
  nixos-generate-config --root /mnt
  
  sed "s/UUID/$UUID/g" luks_template.nix > luks.nix

  cp ./audio.nix /mnt/etc/nixos/
  cp -rf ./configuration.nix /mnt/etc/nixos/
  cp ./locale.nix /mnt/etc/nixos/
  cp ./luks.nix /mnt/etc/nixos/
  cp ./users.nix /mnt/etc/nixos/

  nixos-install --no-root-passwd
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi