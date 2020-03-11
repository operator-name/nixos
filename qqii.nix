{ config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    # ref = "release-19.03";
  };
in
{
  imports =
    [
      # Pinned home-manager
      "${home-manager}/nixos"
    ];

  users.mutableUsers = false; # just for now, rebuilding seems to mess with user groups without this
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.qqii = {
    # Randomly chosen, used for setup script to chown /etc/nixos
    uid = 7919;
    # defaults for home, etc
    isNormalUser = true;
    extraGroups = [
      "wheel" # sudo
      "networkmanager" # wifi
      "video" # brightness control
      "audio"
      "adbusers"
      "docker"
    ];
    initialHashedPassword = "$6$password$4XlRDLri/hbFx14B1YGPsc.0c8P2NVd7UhJ/YF7i2tPt./oEsdVcdGrjU7Pys93/FKEMt6p948FMO2BpuLd0J.";
  };

  # can be replaced with a overriding export of $SSH_ASKPASS=""
  programs.ssh.askPassword = "";
  # can be replaced with an export of $EDTIOR="vim"
  programs.vim.defaultEditor = true;

  home-manager.useUserPackages = true;
  home-manager.users.qqii = { pkgs, ... }: {

    # xsession = {
      # enable = true;
      # windowManager.xmonad = {
      #   enable = true;
      #   enableContribAndExtras = true;
      #   extraPackages = haskellPackages: [
      #     haskellPackages.xmonad-contrib
      #     haskellPackages.xmonad-extras
      #     haskellPackages.xmonad
      #   ];
      # };
    # };

    #TODO: add comments describing each package
    home.packages = with pkgs; [
      nix-index
      wget
      bitwarden-cli
      vscodium
      file
      xclip
      tig
      texlive.combined.scheme-full
      ripgrep
      exa
      fd
      jq
      jc
      jp
      jetbrains.webstorm
      
      tor-browser-bundle-bin
      kleopatra
      # monero-gui
      
      ranger
      # wasabiwallet
    ] ++ (
      with (import <nixos> { config.allowUnfree = true; }); [
        minecraft
        spotify
        google-chrome
      ]
    );

    programs = {
      kakoune.enable = true;
      gpg.enable = true;
      chromium = {
        enable = true;
        extensions = [];
      };
      bash = {
        enable = true;
        # jc 
        enableAutojump = false;
        historySize = -1;
        historyFileSize = -1;
        historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
        # TODO: nixpkg for shell scripts to make sure dependaicies are availible
        initExtra = ''
          # get bitwarden object and copy it to clipbard
          # a common use is bwclip password <website>
          function bwclip() {
            bw get $1 $2 | xclip -selection clipboard
            # TODO: add feedback for if the vault is locked
          }

          # super resolution with the same scaling for screenshots and for crisp magnifier
          # best when given a multiple of 2
          function superresolution() {
            # increase resolution
            xrandr --output eDP-1 --scale "$1x$1"
            # increase window scaling (integer)
            gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "[{'Gdk/WindowScalingFactor', <$1>}]"
            gsettings set org.gnome.desktop.interface scaling-factor "$1"
            # increase mouse scaling
            gsettings set org.gnome.desktop.interface cursor-size "$((24*$1*$1))"
          }
        '';
        shellAliases = {
          # unlock bitwarden and set session key
          # bash makes it so that trying to get the return variable of `bw unlock` non trivial so bw sync is ran to check the password is correct thus bwunlock cannot provide password feedback offline
          bwunlock = "$(bw unlock | grep export | cut -c 3-) && bw sync";
          # copy to clipboard, use -o to paste from clipboard
          xclipboard = "${pkgs.xclip}/bin/xclip -selection clipboard";
          # ls stuff
          ls = "exa";
          la = "exa --all";
          ll = "exa --long";
        };
      };
      bat = {
        enable = true;
        config = {};
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
          commit = {
            verbose = "true";
          };
        };
        aliases = {
          graph = "log --graph --decorate --abbrev-commit";
          tree = "log --graph --decorate --pretty=oneline --abbrev-commit";
          patch = "add --patch";
          interactive = "add --interactive";
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
      gpg-agent = {
        enable = true;
      };
    };
  };
}
