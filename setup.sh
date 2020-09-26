#!/usr/bin/env bash

###############################################################################
# Debug

set -x

###############################################################################
# Input variables

DISK="/dev/nvme0n1"

###############################################################################
# Initial Partitions

# Create GPT partition table
DISK_UUID="7ac71ca1-ac1d-4321-fa7e-d155a7151fed"
# --clear by itself may fail on a damanged disk so --zap-all is required
sgdisk --zap-all --clear "--disk-guid=${DISK_UUID}" "${DISK}" 

BOOT_UUID="b007ab1e-b007-4321-b007-b007ab1eb105"
BOOT_NAME="boot"
BOOT_SIZE="+1G"
# Linux boot partition (code ef00)
sgdisk --new 1:0:"${BOOT_SIZE}" --typecode=1:ef00 "--change-name=1:${BOOT_NAME}" "--partition-guid=1:${BOOT_UUID}" "$DISK"

LUKS_UUID="5ca1ab1e-c01a-4321-ba11-c011ec71b1e5"
LUKS_NAME="luks"
# Fill rest with LUKS parition (code 8309)
sgdisk --new 2:0:0 --typecode=2:8309 "--change-name=2:${LUKS_NAME}" "--partition-guid=2:${LUKS_UUID}" "$DISK"

printf "\n###############################################################################\n"
sgdisk --print "$DISK"
printf "###############################################################################"
sgdisk --info=1 "$DISK"
printf "###############################################################################"
sgdisk --info=2 "$DISK"
printf "\n###############################################################################\n"

###############################################################################
# Create FAT32 boot partition

BOOT="${DISK}p1"
BOOT_VOLUME_ID="-i b007ab1e"
BOOT_NAME="boot"
mkfs.fat -n "${boot}" "${BOOT_VOLUME_ID}" "${BOOT}"

###############################################################################
# Setup LUKS (dm-crypt)

LUKS="${DISK}p2"
LUKS_UUID="0b57ac1e-ba55-4807-be11-c011ec7ab1e5"
cryptsetup luksFormat "--uuid=${LUKS_UUID}" "${LUKS}"

###############################################################################
# Setup LVM

LUKS_NAME="luks"
LVM_VG_NAME="vg"
LVM_UUID="places-that-home-swap-both-rest-opened"

# Unlock LUKS 
cryptsetup luksOpen "${LUKS}" "${LUKS_NAME}" 
# cryptsetup luksClose "${LUKS_NAME}"

# Create LVM PV and VG
pvcreate --norestorefile "--uuid=${LVM_UUID}" "/dev/mapper/${LUKS_NAME}"
vgcreate "${LVM_VG_NAME}" "/dev/mapper/${LUKS_NAME}"
# vgchange --activate n "${LVM_VG_NAME}"

# Swap logical volume
SWAP_UUID="c0deba5e-da7a-4807-a51c-d1917a11571c"
SWAP_NAME="swap"
SWAP_SIZE="32G"
lvcreate --size "${SWAP_SIZE}" --name "${SWAP_NAME}" "${LVM_VG_NAME}"
         
# Root logical volume
ROOT_UUID="0ff1c1a1-be57-4807-a150-d155a715f1ed"
ROOT_NAME="root"
lvcreate --extents 100%FREE --name "${ROOT_NAME}" "${LVM_VG_NAME}"

# Create partitions
mkswap --label "${SWAP_NAME}" "--uuid=${SWAP_UUID}" "/dev/${LVM_VG_NAME}/${SWAP_NAME}"
mkfs.btrfs --label "${ROOT_NAME}" "--uuid=${ROOT_UUID}" "/dev/${LVM_VG_NAME}/${ROOT_NAME}"

printf "\n###############################################################################\n"
lsblk --output +LABEL,UUID,PTUUID,PARTLABEL,PARTUUID "$DISK"
printf "\n###############################################################################\n"

###############################################################################
# Setup BTRFS

mount -t btrfs "/dev/${LVM_VG_NAME}/${ROOT_NAME}" /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/log
btrfs subvolume snapshot -r /mnt/root /mnt/root0
umount /mnt

mount -o subvol=root,compress=zstd,noatime "/dev/${LVM_VG_NAME}/${ROOT_NAME}" /mnt
# umount /mnt

mkdir /mnt/home
mkdir /mnt/nix
mkdir /mnt/persist
mkdir --parents /mnt/var/log
mkdir /mnt/boot

mount -o subvol=home,compress=zstd,noatime "/dev/${LVM_VG_NAME}/${ROOT_NAME}" /mnt/home
mount -o subvol=nix,compress=zstd,noatime "/dev/${LVM_VG_NAME}/${ROOT_NAME}" /mnt/nix
mount -o subvol=persist,compress=zstd,noatime "/dev/${LVM_VG_NAME}/${ROOT_NAME}" /mnt/persist
mount -o subvol=log,compress=zstd,noatime "/dev/${LVM_VG_NAME}/${ROOT_NAME}" /mnt/var/log
# umount /mnt/home
# umount /mnt/nixos
# umount /mnt/persist
# umount /mnt/var/log

mount "$BOOT" /mnt/boot
# umount /mnt/boot

swapon "/dev/${LVM_VG_NAME}/${SWAP_NAME}"
# swapoff "/dev/${LVM_VG_NAME}/${SWAP_NAME}"

# --no-filesystems
nixos-generate-config --root /mnt
chown --recursive 7919 /mnt/etc/nixos

# cp {hardware-,}configuration.nix /mnt/etc/nixos # TODO: move everything, including git
# nixos-install --no-root-passwd

# function cleanup {
# this function should unmount everything
# }
