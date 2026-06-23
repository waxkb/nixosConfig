{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.system;
in
{

  imports = [
    ./hardware-configuration.nix
    ./packages.nix
  ];

  # nix.package = pkgs.lixPackageSets.git.lix;

  system.nixos-core.enable = true;

  services.ncro = {
    enable = true;
    settings = {
      server = {
        listen = ":8081";
      };
      upstreams = [
        {
          url = "https://cache.nixos.org";
          priority = 10;
          public_key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
        }
        {
          url = "https://nix-community.cachix.org";
          priority = 20;
          public_key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
        }
        {
          url = "https://claude-code.cachix.org";
          priority = 5;
          public_key = "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=";
        }
        {
          url = "https://noctalia.cachix.org";
          priority = 1;
          public_key = "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=";
        }
      ];
    };
  };

  nix.settings.substituters = [ "http://localhost:8081" ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/max/nixos"; # sets NH_OS_FLAKE variable for you
  };

  programs.ccache = {
    enable = true;
    owner = "root";
    group = "nixbld";
    packageNames = [ "noctalia" ];
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.kdeconnect.enable = false;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    libx11
    libxinerama
    libxext
    libGL
  ];

  # Disable generation of documentation to bypass the Sphinx/Docutils bug
  documentation.enable = false;
  documentation.man.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${
          inputs.tuigreet.packages.${system}.tuigreet
        }/bin/tuigreet --cmd niri-session --remember --remember-session";
        user = "greeter";
      };
    };
  };

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  # programs.obs-studio = {
  #   enable = true;
  #   package = (
  #     pkgs.obs-studio.override {
  #       cudaSupport = true;
  #     }
  #   );
  #   plugins = with pkgs.obs-studio-plugins; [
  #     obs-pipewire-audio-capture
  #   ];
  # };

  programs.dank-material-shell = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  programs.java.enable = true;

  programs.niri.enable = true;

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  systemd.services."getty@tty1".enable = false;

  system.stateVersion = "25.11";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.loader.limine = {
    enable = false;
    maxGenerations = null;
    extraConfig = ''
      quiet: yes
    '';
  };

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = null;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.max = {
    isNormalUser = true;
    description = "max";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
      "input"
    ];
    packages = [ ];
  };

  services.power-profiles-daemon.enable = false;
  services.upower.enable = false;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    "amdgpu.enable=0"
    "8250.nr_uarts=0"
    "nvme_core.default_ps_max_latency_us=0"
    "pcie_aspm=off"
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=false"
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
  ];
  boot.initrd.includeDefaultModules = false;

  boot.consoleLogLevel = 0;

  systemd.services.systemd-journal-flush.enable = false;

  boot.initrd.systemd.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false; # Doesn't wait to connect to internet before booting

  systemd.services.systemd-udev-settle.enable = false;

  boot.initrd.compressor = pkgs: "${pkgs.lz4.out}/bin/lz4";
  boot.initrd.compressorArgs = [
    "-l"
    "--best"
    "--favor-decSpeed"
  ];

  boot.kernelPackages = pkgs.linuxPackagesFor (
    (pkgs.linux.override {
      stdenv = pkgs.ccacheStdenv;
    }).overrideAttrs
      (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.lz4 ];
      })
  );

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

  nixpkgs.config = {
    allowUnfree = true;
    freetype = {
      hinting = true;
    };
  };

  hardware.bluetooth = {
    enable = false;
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  services.blueman.enable = false;

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      maple-mono.NF-unhinted
      commit-mono
      inter
      noto-fonts
      material-symbols
      corefonts
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        autohint = false;
        style = "slight";
      };
      subpixel = {
        lcdfilter = "none";
        rgba = "none";
      };
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Inter" ];
        monospace = [ "Maple Mono NF" ];
      };
    };
    fontDir.enable = true;
  };

  environment.variables = {
    FREETYPE_PROPERTIES = "truetype:interpreter-version=40";
  };

  nix.settings = {
    extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
  };

  system.activationScripts.ccacheCacheDir.text = ''
      mkdir -p ${config.programs.ccache.cacheDir}
    install -d -m 0770 -o ${config.programs.ccache.owner} -g ${config.programs.ccache.group} ${config.programs.ccache.cacheDir}
    install -d -m 0770 -o ${config.programs.ccache.owner} -g ${config.programs.ccache.group} ${config.programs.ccache.cacheDir}/tmp
  '';

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      value = "unlimited";
      type = "soft";
    }
    {
      domain = "*";
      item = "memlock";
      value = "unlimited";
      type = "hard";
    }
  ];

  hardware.graphics.enable = true;

  services.envfs.enable = true;

  security.polkit.enable = true;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };
}
