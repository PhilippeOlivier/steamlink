{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      # # Normally:
      # PasswordAuthentication = false;
      # KbdInteractiveAuthentication = false;
      # AuthenticationMethods = "publickey";

      # In order to `ssh-copy-id` a new machine:
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;

      PermitRootLogin = "no";
      PrintMotd = false;
    };
  };
}
