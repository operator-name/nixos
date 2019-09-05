{ config, pkgs, ... }:

let home-manager = builtins.fetchGit {
  url = "https://github.com/rycee/home-manager.git";
  ref = "release-19.03";
};
in {
  imports = 
    [ 
      # Pinned home-manager
      "${home-manager}/nixos"
    ];

    programs.vim.defaultEditor = true;

    home-manager.useUserPackages = true;
    
    home-manager.users.qqii = { pkgs, ... }: {
      home.packages = with pkgs; [ 
        wget bitwarden-cli vscodium file
      ];
      
      programs = {
        bash = {
          enable = true;
          enableAutojump = true;
          historyControl = [ "ignoredups" ];
          shellAliases = {
            
          };
        };
        bat = {
          enable = true;
          config = {

          };
        };
        fzf.enable = true;
        home-manager.enable = true;
        htop.enable = true;
        lesspipe.enable = true;
        man.enable = true;
        obs-studio.enable = true;
        alacritty.enable = true;
        vim.enable = true;
        firefox = {
          enable = true;
          
        };
        git = {
          enable = true;
          userEmail = "operator.name@protonmail.com";
          userName = "operator.name";
          extraConfig = {
            core = {
              editor = "vim";
            };
          };
        };
      };
      services = {
        network-manager-applet.enable = true;
        random-background = {
          enable = false;
          # imageDirectory = "%h/Pictures/backgrounds"; 
          # interval = null; # null for once per login, otherwise a systemd time
        };

      };
    };
}