{ config, pkgs, ... }:

{
  boot.initrd.luks.devices.crypted = {
    device = "/dev/disk/by-uuid/0b57ac1e-ba55-4807-be11-c011ec7ab1e5";
    allowDiscards = true; # https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
    preLVM = true;
  };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/B007-AB1E";
      fsType = "vfat";
    };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/0ff1c1a1-be57-4807-a150-d155a715f1ed";
      fsType = "ext4";
    };

  swapDevices =
    [
      { device = "/dev/disk/by-uuid/c0deba5e-da7a-4807-a51c-d1917a11571c"; }
    ];
}