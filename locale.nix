{ config, pkgs, ... }:

{
  # Select internationalisation properties.
  console.keyMap = "uk";
  i18n = {
    defaultLocale = "en_GB.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";
}