{ config, pkgs, ... }:

{
  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "uk";
    defaultLocale = "en_GB.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";
}