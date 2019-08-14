{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.qqii = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    initialHashedPassword = "$6$password$u/Cn/tSGIYFtqv4AwZ9tjP1gMxjlvLHt3KO8zbK6ZnMn8anv6tSCo.XidktlU0MdRjWe3./lahF9FTMcnja9q.";
  };
}
