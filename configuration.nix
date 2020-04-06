# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # LUKS configuration and mounting points
      ./filesystems.nix
      # Nix configuration
      ./nix.nix
      # Local and language
      ./locale.nix
      # Audio and sound
      ./audio.nix
      # The qqii user and other user configuration
      ./qqii.nix
      # IGVT-g configuration
      ./iGVT-g.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "operator-name"; # Define your hostname.
  networking.networkmanager.enable = true; # Enables wireless support via network-manager.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [];

  # TODO: figure out how this works and some numbers for it
  hardware.trackpoint.enable = true;
  hardware.trackpoint.speed = 200;
  hardware.trackpoint.sensitivity = 200;


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ brlaser ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "gb";
  services.xserver.xkbOptions = "";

  services.monero.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = false;
  services.xserver.libinput.naturalScrolling = true;

  # Enable Pantheon
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.pantheon.enable = true;

  # udev for android and adb
  programs.adb.enable = true;
  services.udev.packages = [ pkgs.android-udev-rules ];

  # update firmware
  services.fwupd.enable = true;

  # T480 throttling issue
  services.throttled.enable = true;

  # docker
  virtualisation.docker.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
