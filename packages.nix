{
  pkgs,
  pkgs25,
  zen-browser,
  inputs,
  claude-code,
  ...
}:

let
  tex = (
    pkgs.texliveSmall.withPackages (
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
    )
  );
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
    clang
    clang-tools
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
    google-java-format
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
    matcha
    matugenFixed
    mpv
    niri
    nixfmt-rs
    nnd
    noctalia
    nodejs
    ollama
    opencode
    parted
    pavucontrol
    pkg-config
    playerctl
    pnpm
    pulseaudio
    libsForQt5.qtgraphicaleffects
    libsForQt5.qtmultimedia
    libsForQt5.qtquickcontrols
    libsForQt5.qtquickcontrols2
    libsForQt5.qtsvg
    pkgs.kdePackages.qtvirtualkeyboard
    ratty
    ripgrep
    ruff
    rustfmt
    shfmt
    starship
    stress-ng
    stow
    stylua
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
