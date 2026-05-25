{ pkgs, pkgs25, zen-browser, inputs, claude-code, ... }:

let
  tex = (pkgs.texliveSmall.withPackages (
    ps: with ps; [
      latexmk
      thmtools
      tikz-cd
      mdframed
      zref
      needspace
      mhchem
      siunitx
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
    bat
    bibata-cursors
    broot
    btop
    cliphist
    cmake
    codex
    curl
    efibootmgr
    fastfetch
    fd
    foot
    fzf
    gcc
    git
    gita
    gnumake
    gptfdisk
    hyperfine
    hyprlock
    hyprpicker
    imagemagick
    infisical
    iwd
    jq
    kitty
    libffi
    libnotify
    libxkbcommon
    llama-cpp
    lsof
    matugenFixed
    mpv
    niri
    nnd
    noctalia
    ollama
    opencode
    parted
    pavucontrol
    pkg-config
    playerctl
    pulseaudio
    libsForQt5.qtgraphicaleffects
    libsForQt5.qtmultimedia
    libsForQt5.qtquickcontrols
    libsForQt5.qtquickcontrols2
    libsForQt5.qtsvg
    pkgs.kdePackages.qtvirtualkeyboard
    ratty
    ripgrep
    starship
    stress-ng
    stow
    tex
    tofi
    tree
    unzip
    uv
    vicinae
    wayland-bongocat
    wev
    wezterm
    wget
    wl-clipboard
    xwayland-satellite
    zathura
    zathuraPkgs.zathura_pdf_poppler
    zen-browser.packages.${pkgs.system}.default
    zsh
  ];
}
