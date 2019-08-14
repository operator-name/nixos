{ config, pkgs, ... }:

{
  boot.initrd.luks.devices.crypted = {
    device = "/dev/disk/by-uuid/UUID";
    allowDiscards = true; #https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
    preLVM = true;
  };
}
