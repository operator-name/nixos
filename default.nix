with import <nixpkgs> {};

# let
#   srcs = pkgs.fetchFromGitHub {
#     owner = "operator-name";
#     repo = "nixos";
#     rev = "758861db51c911f6074757e30677cb46c81a3fca";
#     sha256 = "0hlffq0gb90nbs918vgclmkrg34yzmr7wy1grshyby1pjnfafgbs"; #lib.fakeSha256;
#   };
# in 
stdenv.mkDerivation {
  name = "nixos-config";
  
  buildInputs = with pkgs; [
    gptfdisk
    dosfstools
    cryptsetup
    lvm2
    e2fsprogs
    utillinux
    git
  ];
}

