{ config, pkgs, zen-browser, matugen, silentSDDM, ... }:

let
  system = pkgs.system;
in
{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    silentSDDM.nixosModules.default
    #dms.nixosModules.dankMaterialShell
  ];

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      python313Packages = prev.python313Packages.overrideScope (pyFinal: pyPrev: {
        khal = pyPrev.khal.overridePythonAttrs (old: {
          doCheck = false;
          doInstallCheck = false;
          doDoc = false;
        });
      });
    })
  ];

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

  #programs.dms-shell = {
  #  enable = true;
  #  systemd = {
  #      enable = true;
  #      restartIfChanged = true;
  #    };
  #};

  #systemd.user.services.dms = {
  #  description = "Dank Material Shell";
  #  wantedBy = [ "graphical-session.target" ];

  #  serviceConfig = {
  #    ExecStart = "/run/current-system/sw/bin/dms";
  #    Restart = "on-failure";
  #  };
  #};

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
    theme = "nord";
    backgrounds = {
      purpleKeyboards = ./wall/purpleKeyboards.jpg;
    };
    profileIcons = {
      max = ./wall/xkcdLocalViewing.jpg;
    };

    settings = {
      "LockScreen" = {
        background = "purpleKeyboards.jpg";
        use-background-color = false;
        #blur = false;
      };
      "LockScreen.Clock" = {
        display = false;
      };
      "LockScreen.Date" = {
        display = false;
      };
      "LockScreen.Message" = {
        display = true;
        position= "center";
        text = "λ";
        font-family = "Playfair Display";
        font-size = 100;
        font-weight = 500;
        display-icon= false;
      };
      "LoginScreen" = {
        background = "purpleKeyboards.jpg";
        use-background-color = false;
      };
      "LoginScreen.LoginArea.PasswordInput" = {
        background-color = "#321C33";
        background-opacity = 0.1;
      };
      "LoginScreen.LoginArea.LoginButton" = {
        hide-if-not-needed = true;
        background-color = "#321C33";
      };
      "LoginScreen.MenuArea.Layout" = {
        display = false;
      };
      "LoginScreen.MenuArea.Keyboard" = {
        display = false;
      };
      "Tooltips" = {
        enable = false;
      };
    };
  };

  nix.settings = {
    extra-sandbox-paths = [ "/var/cache/ccache" ];
  };

  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
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

  #services.displayManager.defaultSession = "niri";

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  systemd.services."getty@tty1".enable = false;


# Probably don't need to edit these

  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.loader.systemd-boot.configurationLimit = 5;

  boot.loader.grub = {
    enable = false;
    #efiSupport = true;
    #device = "nodev";
    #useOSProber = true;
    #gfxmodeEfi = "2560x1440";
  };


  #boot.loader.grub.theme = let
  #  colorscheme = "night";
  #  layout = "teleport";
  #  resolution = "1920x1080";
  #in grubshin.theme.${colorscheme}.layout.${layout}.${resolution};

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
