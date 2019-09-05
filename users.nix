{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.qqii = {
    # Randomly chosen, used for setup script to chown /etc/nixos
    uid = 7919; 
    # defaults for home, etc
    isNormalUser = true;
    # wheel for sudo 
    # networkmanager for networkmanager without having to enter password
    extraGroups = [ "wheel" "networkmanager" ];
    initialHashedPassword = "$6$password$u/Cn/tSGIYFtqv4AwZ9tjP1gMxjlvLHt3KO8zbK6ZnMn8anv6tSCo.XidktlU0MdRjWe3./lahF9FTMcnja9q.";
  };
}
