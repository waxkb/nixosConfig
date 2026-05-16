{ pkgs, pkgs25, zen-browser, inputs, claude-code, ... }:

let
  tex = (pkgs.texliveSmall.withPackages (
    ps: with ps; [
      latexmk
      thmtools
    ]
  ));
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
in
{
  environment.systemPackages = with pkgs; [
    activate-linux
    inputs.areofyl-fetch.packages.${pkgs.system}.default
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
    gnumake
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
    matugenFixed
    mpv
    neovim
    niri
    nodejs
    openclaw
    ollama-cuda
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
    ratty
    starship
    stress-ng
    stow
    tex
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
  ];
}
