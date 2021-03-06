{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.luks = {
    device = "/dev/disk/by-uuid/0b57ac1e-ba55-4807-be11-c011ec7ab1e5";
    # https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
    allowDiscards = true; 
    preLVM = true;
  };
  
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0ff1c1a1-be57-4807-a150-d155a715f1ed";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/0ff1c1a1-be57-4807-a150-d155a715f1ed";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/0ff1c1a1-be57-4807-a150-d155a715f1ed";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/0ff1c1a1-be57-4807-a150-d155a715f1ed";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/0ff1c1a1-be57-4807-a150-d155a715f1ed";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B007-AB1E";
      fsType = "vfat";
    };

  swapDevices =
    [ 
      { 
        device = "/dev/disk/by-uuid/c0deba5e-da7a-4807-a51c-d1917a11571c";
      }
    ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
