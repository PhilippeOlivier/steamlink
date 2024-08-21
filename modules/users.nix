{ config, pkgs, ... }:

{
  users.mutableUsers = false;

  users.users.root = {
    isSystemUser = true;
    password = "asdf";
  };
  
  users.users.steamlink = {
    isNormalUser = true;
    password = "asdf";
    description = "steamlink";
    home = "/home/steamlink";
    extraGroups = [
      "wheel"
    ];
  };

  services.getty.autologinUser = "steamlink";
}
