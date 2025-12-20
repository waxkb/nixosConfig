# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # Import unstable nixpkgs alongside stable
  unstable = import <nixos-unstable> {
    config.allowUnfree = true;
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  environment.systemPackages = [
    pkgs.btop
    pkgs.fastfetch
    pkgs.fd
    pkgs.fzf
    pkgs.git
    pkgs.iwd
    pkgs.mpv
    pkgs.pavucontrol
    pkgs.stow
    pkgs.tree
    pkgs.firefox
    pkgs.curl
    pkgs.wget
    pkgs.cmake
    pkgs.unzip
    pkgs.zsh
    pkgs.oh-my-posh
    pkgs.neovim
    pkgs.obs-studio
    pkgs.obsidian
    pkgs.swww
    pkgs.waypaper
    pkgs.clipse
    pkgs.alacritty
    pkgs.chromium
    pkgs.gcc
    pkgs.yazi
    pkgs.matugen
    pkgs.pango
    pkgs.cairo
    pkgs.freetype
    pkgs.harfbuzz
    pkgs.kitty
    pkgs.mesa
    pkgs.vulkan-tools
    pkgs.vulkan-loader
    pkgs.libva
    pkgs.pipewire
    pkgs.wireplumber
    pkgs.hyprland
    pkgs.xdg-desktop-portal
    pkgs.xdg-desktop-portal-hyprland
    pkgs.xdg-desktop-portal-gtk
    pkgs.dms-shell
    pkgs.quickshell
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  programs.zsh.enable = true;
  users.users.max = {
  shell = pkgs.zsh;
  };

  xdg.portal.enable = true;

  services.xserver.enable = false;

  hardware.graphics.enable = true;

  programs.hyprland.enable = true;

  environment.sessionVariables = {
  WLR_NO_HARDWARE_CURSORS = "1";
  LIBVA_DRIVER_NAME = "nvidia";
  GBM_BACKEND = "nvidia-drm";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  XDG_SESSION_TYPE = "wayland";
  NIXOS_OZONE_WL = "1";
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
  modesetting.enable = true;
  powerManagement.enable = false;
  powerManagement.finegrained = false;
  open = false;
  nvidiaSettings = true;
  };

services.displayManager.dms-greeter = {
  enable = true;
  compositor = {
    name = "hyprland"; # Required. Can be also "hyprland" or "sway"
  };
  configHome = "/home/max";
};

  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
  "nvidia-drm.modeset=1"
  "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.max = {
    isNormalUser = true;
    description = "max";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

}

