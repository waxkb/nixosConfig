{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  programs.git = {
    settings = {
      user = {
        name = "waxkb";
        email = "maxwellr2028@gmail.com";
      };
      init.defaultBranch = "main";
    };
    enable = true;
  };
}
