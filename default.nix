with import <nixpkgs> {};

stdenv.mkDerivation rec {
    name = "nixos";

    buildInputs = [ git ];
}