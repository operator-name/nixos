{ config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    ref = "release-19.03";
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
    ];
    initialHashedPassword = "$6$password$u/Cn/tSGIYFtqv4AwZ9tjP1gMxjlvLHt3KO8zbK6ZnMn8anv6tSCo.XidktlU0MdRjWe3./lahF9FTMcnja9q.";
  };

  # can be replaced with a overriding export of $SSH_ASKPASS=""
  programs.ssh.askPassword = "";
  # can be replaced with an export of $EDTIOR="vim"
  programs.vim.defaultEditor = true;

  home-manager.useUserPackages = true;
  home-manager.users.qqii = { pkgs, ... }: {

    # xsession = {
    #   enable = true;
    #   windowManager.xmonad = {
    #     enable = true;
    #     enableContribAndExtras = true;
    #     extraPackages = haskellPackages: [
    #       haskellPackages.xmonad-contrib
    #       haskellPackages.xmonad-extras
    #       haskellPackages.xmonad
    #     ];
    #   };
    # };

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
    ] ++ (
      with (import <nixos> { config.allowUnfree = true; }); [
        minecraft
      ]
    );

    programs = {
      chromium = {
        enable = true;
        extensions = [];
      };
      bash = {
        enable = true;
        enableAutojump = true;
        historySize = -1;
        historyFileSize = -1;
        historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
        # TODO: nixpkg for shell scripts to make sure dependaicies are availible
        initExtra = ''
          # get bitwarden object and copy it to clipbard
          # a common use is bwclip password <website>
          function bwclip() {
            # bw get ouputs the password with a newline 
            # as an alternative, tr -d [:space:] can be used if no passphrases contain spaces
            bw get $1 $2 | head -c -1 | xclip -selection clipboard
          }
        '';
        shellAliases = {
          # unlock bitwarden and set session key
          bwunlock = "$(bw unlock | grep export | cut -c 3-) && bw sync";
          # copy to clipboard, use -o to paste from clipboard
          xclipboard = "xclip -selection clipboard";
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

    };
  };
}
