{ config, pkgs, ... }:

{
  home = {
    stateVersion = "24.05";
    username = "steamlink";
    homeDirectory = "/home/steamlink";
    packages = with pkgs; [
      coreutils
      curl
      emacs
      git
      htop
      magic-wormhole
      neofetch
      openssh
      tree
    ];
    
    sessionVariables = {
      EDITOR = "emacs";
    };

    shellAliases = {
      ls = "ls --color=auto";  # Colorize the `ls` command
    };
  };

  programs.bash = {
    enable = true;
    historyControl = [
      "erasedups"
      "ignoredups"
      "ignorespace"
    ];
    initExtra = ''PS1="[\u@\h \W]\$ "'';
  };

  programs.home-manager.enable = true;
}
