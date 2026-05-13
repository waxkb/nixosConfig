{ pkgs, zen-browser, inputs, claude-code, ... }:

let
  playwrightBrowsers = pkgs.playwright-driver.browsers;
in
{
  environment.systemPackages = with pkgs; [
    activate-linux
    bibata-cursors
    btop
    cliphist
    codex
    cmake
    curl
    efibootmgr
    fastfetch
    fd
    ffmpeg
    foot
    fzf
    gcc
    git
    gita
    google-chrome
    gptfdisk
    hyprlock
    hyprpicker
    imagemagick
    infisical
    iwd
    jq
    libffi
    libnotify
    libxkbcommon
    llama-cpp
    lsof
    mpv
    neovim
    niri
    nodejs
    ollama-cuda
    openclaw
    opencode
    parted
    pavucontrol
    pkg-config
    playerctl
    podman-compose
    pulseaudio
    libsForQt5.qtgraphicaleffects
    libsForQt5.qtmultimedia
    libsForQt5.qtquickcontrols
    libsForQt5.qtquickcontrols2
    libsForQt5.qtsvg
    pkgs.kdePackages.qtvirtualkeyboard
    starship
    stress-ng
    stow
    tofi
    unzip
    uv
    ventoy-full
    vicinae
    wev
    wget
    wl-clipboard
    xwayland-satellite
    yazi
    zathura
    zathuraPkgs.zathura_pdf_poppler
    zen-browser.packages.${pkgs.system}.default
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

        exec ${pkgs.matugen}/bin/matugen --base16-backend wal --source-color-index 0 "''${args[@]}"
      '';
    in matugenFixed)
    (pkgs.callPackage ./ratty.nix {})
  ];

  environment.variables = {
    # Reuse the Nix-provided browser bundle for both the CLI wrapper and npm projects.
    PLAYWRIGHT_BROWSERS_PATH = "${playwrightBrowsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };
}
