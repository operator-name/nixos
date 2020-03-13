with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "nixos";

  buildInputs = [
    gptfdisk
    dosfstools
    cryptsetup
    lvm2
    e2fsprogs
    utillinux
    git
  ];
}
