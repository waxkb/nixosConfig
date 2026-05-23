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
    dms.nixosModules.dank-material-shell
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  nix.settings = {
    extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
  };

  programs.ccache = {
    enable = true;
    owner = "root";
    group = "nixbld";
    packageNames = [ "noctalia" ];
  };

  system.activationScripts.ccacheCacheDir.text = ''
    mkdir -p ${config.programs.ccache.cacheDir}
    install -d -m 0770 -o ${config.programs.ccache.owner} -g ${config.programs.ccache.group} ${config.programs.ccache.cacheDir}
    install -d -m 0770 -o ${config.programs.ccache.owner} -g ${config.programs.ccache.group} ${config.programs.ccache.cacheDir}/tmp
  '';

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      material-symbols
      inter
      noto-fonts
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
        rgba = "none";
        lcdfilter = "light";
      };
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Inter" ];
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
      };
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <match target="pattern">
            <test name="family"><string>TerminalFont</string></test>
            <edit name="family" mode="assign" binding="strong">
              <string>JetBrainsMono Nerd Font Mono</string>
            </edit>
            <edit name="style" mode="assign" binding="strong">
              <string>Medium</string>
            </edit>
          </match>

          <match target="font">
            <test name="family"><string>JetBrainsMono Nerd Font Mono</string></test>
            <edit name="antialias" mode="assign"><bool>true</bool></edit>
            <edit name="autohint" mode="assign"><bool>false</bool></edit>
            <edit name="hinting" mode="assign"><bool>true</bool></edit>
            <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
          </match>
        </fontconfig>
      '';
    };
    fontDir.enable = true;
  };

  services.blueman.enable = true;

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 18789 18790 ];

  environment.systemPackages = [
    nier-sddm-theme
  ];

  programs.kdeconnect.enable = true;

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.12"
    "openclaw-2026.5.7"
  ];

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

  services.searx = {
    enable = true;
    settings = {
      server = {
        default_http_headers = {
          "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36";
          "Accept-Language" = "en-US,en;q=0.9";
        };
        # Standard local port
        port = 9090;
        bind_address = "127.0.0.1";
        # Essential: Open WebUI needs a secret key to communicate safely
        secret_key = "a"; 
      };
      search = {
        safe_search = 0;
        autocomplete = "google";
        # CRITICAL: Open WebUI requires JSON format to parse results
        formats = [ "html" "json" ];
      };
      # Optional: Enable engines you like
      engines = [
        { name = "google"; engine = "google"; shortcut = "go"; }
        { name = "duckduckgo"; engine = "duckduckgo"; shortcut = "ddg"; }
        { name = "reddit"; engine = "reddit"; shortcut = "re"; }
      ];
      enabled_plugins = [
        "Hash plugin"
        "Self_Information"
        "Tracker_aware"
      ];
    };
  };

  boot.kernelModules = [ "ryzen_smu" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.ryzen-smu ];

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
  hardware.graphics.enable = true;


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

  programs.dank-material-shell = {
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


  programs.zsh = {
    enable = true;
  };

  programs.java.enable = true;

  programs.niri.enable = true;

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };


  #environment.etc."sddm.conf.d/theme.conf".text = ''
  #  [Theme]
  #  Current=nier-automata
  #  ThemeDir=/run/current-system/sw/share/sddm/themes
  #'';

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
    extraGroups = [ "networkmanager" "wheel" "podman" ];
    packages = [];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

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
    open = false;
    nvidiaSettings = true;
  };


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
}
