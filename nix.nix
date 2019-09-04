{ config, pkgs, ... }:

{
  nix.autoOptimiseStore = true;
#   nix.gc.automatic = true;

  system.autoUpgrade.enable = true;
  system.nixos.tags = [ "gnome3" ];
}