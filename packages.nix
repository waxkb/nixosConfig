{ pkgs, zen-browser, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    activate-linux
    bibata-cursors
    btop
    claude-code
    cliphist
    cmake
    codex
    curl
    discord-canary
    efibootmgr
    fastfetch
    fd
    ffmpeg
    fzf
    gcc
    gdu
    git
    gita
    hyprlock
    hyprpicker
    imagemagick
    iwd
    jdk
    jq
    kitty
    libnotify
    libxkbcommon
    llama-cpp
    mpv
    neovim
    niri
    noctalia-shell
    obs-studio
    opencode
    parallel-full
    pavucontrol
    pkg-config
    playerctl
    pulseaudio
    python314
    libsForQt5.qtgraphicaleffects
    libsForQt5.qtmultimedia
    libsForQt5.qtquickcontrols
    libsForQt5.qtquickcontrols2
    libsForQt5.qtsvg
    pkgs.kdePackages.qtvirtualkeyboard
    rofi
    starship
    stow
    swww
    texliveFull
    tofi
    unzip
    vesktop
    vicinae
    vscode
    wev
    wget
    wl-clipboard
    xwayland-satellite
    yazi
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

        exec ${pkgs.matugen}/bin/matugen --base16-backend wal --source-color-index 0 "''${args[@]}"
      '';
    in matugenFixed)
  ];
}
