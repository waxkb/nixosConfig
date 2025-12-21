
{ config, pkgs, zen-browser, minecraft-plymouth-theme, ... }:

let
  # Build the Minecraft Plymouth theme package
  plymouthPkg = minecraft-plymouth-theme.packages.${pkgs.system}.default;
  system = pkgs.system;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    # ── CLI utils ───────────────────────────────────────
    btop
    curl
    fastfetch
    fd
    fzf
    git
    stow
    tree
    unzip
    wget
    yazi
    wev

    # ── The one and only ───────────────────────────────
    neovim

    # ── Shell & terminal ───────────────────────────────
    kitty
    zsh
    oh-my-posh

    # ── Languages & compilers ──────────────────────────
    cmake
    gcc

    # ── Media & graphics ───────────────────────────────
    cairo
    freetype
    harfbuzz
    imagemagick
    mpv
    obs-studio
    pango

    # ── Audio ──────────────────────────────────────────
    cava
    pavucontrol
    pipewire
    playerctl
    wireplumber

    # ── Compositors ────────────────
    hyprland
    niri

    # ── Wallpaper ──────────────────────────────────────
    swww
    waypaper

    # ── Portals ────────────────────────────────────────
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland

    # ── Welcome to the rice fields ─────────────────────
    dms-shell
    matugen
    quickshell

    # ── GPU stuff ──────────────────────────────────────
    libva
    mesa
    vulkan-loader
    vulkan-tools

    # ── Utils ──────────────────────────────────────────
    clipse
    efibootmgr
    iwd

    # ── Applications ───────────────────────────────────
    spotify
    obsidian
    zen-browser.packages.${system}.default

    # ── Funzies ────────────────────────────────────────
    activate-linux
    plymouth

  ];


  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
    systemd.restartIfChanged = false;
    enableSystemMonitoring = true;
    enableClipboard = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "hyprland";
    configHome = "/home/max";
  };

programs.niri.enable = true;

  services.xserver.enable = false;

  boot.plymouth = {
    enable = true;
    theme = "mc";
    themePackages = [ plymouthPkg ];
    font = "${plymouthPkg}/share/fonts/OTF/Minecraft.otf";
  };

# Probably don't need to edit these

  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.minegrub-theme.enable = true;


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;

  users.users.max = {
    isNormalUser = true;
    description = "max";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [];
  };

  xdg.portal.enable = true;

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

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono plymouthPkg ];

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

  nixpkgs.config.allowUnfree = true;
}
