{
  pkgs,
  inputs,
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
        newtx
        zref
        needspace
        mhchem
        siunitx
        latexindent
        fancyhdr
        biblatex
        biblatex-chicago
        biber
        csquotes
        babel
        xstring
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
    astyle
    inputs.areofyl-fetch.packages.${pkgs.system}.default
    bat
    bibata-cursors
    broot
    btop
    clang
    clang-tools
    claude-code
    cmake
    codex
    curl
    dix
    efibootmgr
    fd
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
    libffi
    libnotify
    libxkbcommon
    # llama-cpp
    lsof
    lua5_1
    matugenFixed
    microfetch
    mpv
    inputs.ncro.packages.${pkgs.system}.ncro
    niri
    nixfmt-rs
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
    # libsForQt5.qtgraphicaleffects
    # libsForQt5.qtmultimedia
    # libsForQt5.qtquickcontrols
    # libsForQt5.qtquickcontrols2
    # libsForQt5.qtsvg
    # pkgs.kdePackages.qtvirtualkeyboard
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
    tree-sitter
    unzip
    uv
    wayland-bongocat
    wev
    wezterm
    wget
    wl-clipboard
    xwayland-satellite
    yazi
    zathura
    zathuraPkgs.zathura_pdf_poppler
    inputs.zen-browser.packages.${pkgs.system}.default
    zsh
    # Neovim lsp packages
    bash-language-server
    lua-language-server
    ty
    rust-analyzer
  ];
}
