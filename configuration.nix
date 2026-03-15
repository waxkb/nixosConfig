{ config, pkgs, zen-browser, matugen, dms, sddm-themes, ... }:

let
  system = pkgs.system;
  nier-sddm-theme = pkgs.stdenv.mkDerivation {
    name = "nier-sddm-theme";
    src = sddm-themes;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      # Copy the specific nier folder into the output
      cp -r ./themes/nier-automata $out/share/sddm/themes/
    '';
  };
in
{

  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    #silentSDDM.nixosModules.default
    #dms.nixosModules.dankMaterialShell
  ];

  environment.systemPackages = [
    nier-sddm-theme
  ];

  services.displayManager.sddm = {
    enable = true;
    theme = "nier-automata";
    wayland.enable = false;
    extraPackages = [ 
      nier-sddm-theme 
      pkgs.kdePackages.qt5compat
      pkgs.kdePackages.qtshadertools
      pkgs.kdePackages.qtsvg
      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtvirtualkeyboard
      pkgs.kdePackages.qtdeclarative
    ];
    package = pkgs.kdePackages.sddm.overrideAttrs (old: {
      buildCommand = old.buildCommand + ''
        ln -s $out/bin/sddm-greeter-qt6 $out/bin/sddm-greeter
      '';
    });
  };

  services.displayManager.sddm.settings = {
    General ={
      DisplayServer = "x11";
      InputMethod = "";
    };
    Theme = {
      ThemeDir = "/run/current-system/sw/share/sddm/themes";
      Current = "nier-automata";
    };
  };

  security.pam.loginLimits = [
    { domain = "*"; item = "memlock"; value = "unlimited"; type = "soft"; }
    { domain = "*"; item = "memlock"; value = "unlimited"; type = "hard"; }
  ];

  hardware.opengl.enable = true;

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  services.envfs.enable = true;

  security.polkit.enable = true;

  programs.hyprland.enable = true;

  programs.obs-studio = {
    enable = true;
    package = (pkgs.obs-studio.override {
      cudaSupport = true;
    });
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
    ];
  };

  fonts.fontconfig.enable = true;

  programs.dms-shell = {
    enable = true;
    systemd = {
        enable = true;
        restartIfChanged = true;
      };
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

  #programs.silentSDDM = {
  #  enable = false;
  #  theme = "nord";
  #  backgrounds = {
  #    purpleKeyboards = ./wall/purpleKeyboards.jpg;
  #  };
  #  profileIcons = {
  #    max = ./wall/xkcdLocalViewing.jpg;
  #  };

  #  settings = {
  #    "LockScreen" = {
  #      background = "purpleKeyboards.jpg";
  #      use-background-color = false;
  #      #blur = false;
  #    };
  #    "LockScreen.Clock" = {
  #      display = false;
  #    };
  #    "LockScreen.Date" = {
  #      display = false;
  #    };
  #    "LockScreen.Message" = {
  #      display = true;
  #      position= "center";
  #      text = "λ";
  #      font-family = "Playfair Display";
  #      font-size = 100;
  #      font-weight = 500;
  #      display-icon= false;
  #    };
  #    "LoginScreen" = {
  #      background = "purpleKeyboards.jpg";
  #      use-background-color = false;
  #    };
  #    "LoginScreen.LoginArea.PasswordInput" = {
  #      background-color = "#321C33";
  #      background-opacity = 0.1;
  #    };
  #    "LoginScreen.LoginArea.LoginButton" = {
  #      hide-if-not-needed = true;
  #      background-color = "#321C33";
  #    };
  #    "LoginScreen.MenuArea.Layout" = {
  #      display = false;
  #    };
  #    "LoginScreen.MenuArea.Keyboard" = {
  #      display = false;
  #    };
  #    "Tooltips" = {
  #      enable = false;
  #    };
  #  };
  #};

  nix.settings = {
    extra-sandbox-paths = [ "/var/cache/ccache" ];
  };

  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
  };

  programs.zsh = {
    enable = true;
  };

  programs.niri.enable = true;

  services.xserver.enable = true;


  #environment.etc."sddm.conf.d/theme.conf".text = ''
  #  [Theme]
  #  Current=nier-automata
  #  ThemeDir=/run/current-system/sw/share/sddm/themes
  #'';

  services.xserver.videoDrivers = [ "nvidia" ];

  systemd.services."getty@tty1".enable = false;

  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.loader.systemd-boot.configurationLimit = 5;

  boot.loader.grub = {
    enable = false;
  };

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

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono material-symbols google-fonts ];
  fonts.fontDir.enable = true;

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    "amdgpu.enable=0"
  ];

  boot.initrd.availableKernelModules = [
      "nvidia_drm" "nvidia_modeset" "nvidia" "nvidia_uvm"
  ];


  nixpkgs.config.cudaSupport = true;

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
