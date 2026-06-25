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
    bat
    bibata-cursors
    vimPlugins.blink-cmp
    # broot
    btop
    # claude-code
    codex
    curl
    e2fsprogs
    efibootmgr
    fd
    fio
    foot
    fzf
    git
    gita
    # gnumake
    gptfdisk
    hyperfine
    hyprlock
    hyprpicker
    infisical
    iwd
    jq
    libnotify
    # lsof
    matugenFixed
    microfetch
    inputs.ncro.packages.${pkgs.system}.ncro
    niri
    noctalia
    # noctalia-shell
    opencode
    parted
    pavucontrol
    pkg-config
    playerctl
    pulseaudio
    ripgrep
    starship
    stow
    # tex
    tofi
    tree
    tree-sitter
    udisks
    unzip
    # uv
    # wayland-bongocat
    wget
    wl-clipboard
    xwayland-satellite
    yazi
    zathura
    zathuraPkgs.zathura_pdf_poppler
    inputs.zen-browser.packages.${pkgs.system}.default
    zsh

    # ---Neovim formatters---

    # astyle
    # clang-tools
    nixfmt-rs
    # ruff
    # rustfmt
    shfmt
    stylua

    # ---Neovim lsp packages---

    bash-language-server
    lua-language-server
    # ty
    # rust-analyzer

    # ---Lz4 initrd confirmation stuff---

    # dracut
    file
    # tinyxxd
    lz4
  ];
}
