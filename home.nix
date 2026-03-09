{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  programs.git = {
    enable = true;

    userName = "waxkb";
    userEmail = "maxwellr2028@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
