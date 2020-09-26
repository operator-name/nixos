#!/usr/bin/env bash
# fs-diff.sh
# sudo mkdir /mnt
# sudo mount -o subvol=/ /dev/mapper/vg-root /mnt

set -euo pipefail

# maximum possible generation is 2^64 - 2, 
OLD_TRANSID=$(sudo btrfs subvolume find-new /mnt/root0 18446744073709551614)
OLD_TRANSID=${OLD_TRANSID#transid marker was }

sudo btrfs subvolume find-new "/mnt/root" "$OLD_TRANSID" |
sed '$d' |
cut -f17- -d' ' |
sort |
uniq |
while read path; do
  path="/$path"
  if [ -L "$path" ]; then
    : # The path is a symbolic link, so is probably handled by NixOS already
  elif [ -d "$path" ]; then
    : # The path is a directory, ignore
  else
    echo "$path"
  fi
done
