{ config, pkgs, ... }:

{
  nix.autoOptimiseStore = true;
  # nix.gc.automatic = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-19.03";
  system.nixos.tags = [ "gnome3" ];
}