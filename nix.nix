{ config, pkgs, ... }:

{
  nix.autoOptimiseStore = true;
  # nix.gc.automatic = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";
  system.nixos.tags = [ "pantheon" ];
}