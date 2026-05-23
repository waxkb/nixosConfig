{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    claude-code
  ];
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = [ "nvim.desktop" ];
      "text/x-log" = [ "nvim.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
      "text/x-markdown" = [ "nvim.desktop" ];
      "application/json" = [ "nvim.desktop" ];
      "application/yaml" = [ "nvim.desktop" ];
      "application/x-yaml" = [ "nvim.desktop" ];
      "application/toml" = [ "nvim.desktop" ];
      "text/x-yaml" = [ "nvim.desktop" ];
      "text/x-python" = [ "nvim.desktop" ];
      "application/x-shellscript" = [ "nvim.desktop" ];
      "text/x-shellscript" = [ "nvim.desktop" ];
      "text/xml" = [ "nvim.desktop" ];
      "application/xml" = [ "nvim.desktop" ];
      "text/csv" = [ "nvim.desktop" ];
      "text/tab-separated-values" = [ "nvim.desktop" ];
    };
  };
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
