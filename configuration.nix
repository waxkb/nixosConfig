{ config, pkgs, zen-browser, matugen, silentSDDM, grubshin, spicetify-nix, ... }:

let
  system = pkgs.system;
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  imports = [
    ./hardware-configuration.nix
    silentSDDM.nixosModules.default
    spicetify-nix.nixosModules.spicetify
  ];

  environment.systemPackages = with pkgs; [
    activate-linux
    btop
    cairo
    cava
    clipse
    cmake
    curl
    discord-canary
    efibootmgr
    fastfetch
    fd
    ffmpeg
    freetype
    fzf
    gammastep
    gcc
    gdu
    git
    gita
    harfbuzz
    hyprlock
    hyprpicker
    hyprpolkitagent
    imagemagick
    iwd
    jq
    kitty
    lazygit
    lazyjournal
    libnotify
    libva
    lsof
    mako
    mesa
    mpv
    neovim
    niri
    obs-studio
    obsidian
    openssl
    pango
    patchelf
    pavucontrol
    pkg-config
    playerctl
    poppler
    rustup
    starship
    stow
    swww
    tree
    unzip
    vesktop
    vicinae
    vulkan-loader
    vulkan-tools
    waybar
    wev
    wget
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    yazi
    yt-dlp
    zathura
    zathuraPkgs.zathura_pdf_poppler
    zen-browser.packages.${system}.default
    zsh
    (let
      matugenFixed = pkgs.writeShellScriptBin "matugen" ''
        #!/usr/bin/env bash

        args=()
        for arg in "$@"; do
          case "$arg" in
            file://*)
              args+=("$(printf '%s\n' "$arg" | sed 's|^file://||')")
              ;;
            *)
              args+=("$arg")
              ;;
          esac
        done

        exec ${pkgs.matugen}/bin/matugen "''${args[@]}"
      '';
    in matugenFixed)
  ];

  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
    ];
    theme = spicePkgs.themes.text;
    colorScheme = "CatppuccinMocha";
  };

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };

  programs.silentSDDM = {
      enable = true;
      theme = "silvia";
    };

  programs.zsh = {
    enable = true;
    #ohMyZsh = {
    #  enable = true;
    #  theme = "";
    #};
  };

  programs.niri.enable = true;

  services.xserver.enable = true;

  services.displayManager.defaultSession = "niri";

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  systemd.services."getty@tty1".enable = false;


# Probably don't need to edit these

  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    gfxmodeEfi = "2560x1440";
  };


  boot.loader.grub.theme = let
    colorscheme = "night";
    layout = "teleport";
    resolution = "1920x1080";
  in grubshin.theme.${colorscheme}.layout.${layout}.${resolution};

nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.max = {
    isNormalUser = true;
    description = "max";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [];
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  hardware.graphics.enable = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    "amdgpu.enable=0"
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
