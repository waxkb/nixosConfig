{ pkgs, system, zen-browser, minecraft-plymouth-theme }:

let
  plymouthPkg = minecraft-plymouth-theme.packages.${system}.default;
in
with pkgs; [
  # Core CLI
  btop curl fastfetch fd fzf git stow tree unzip wget yazi zsh

  # Shell / Terminal
  kitty oh-my-posh

  # Editors / Dev
  cmake gcc neovim

  # Media / Graphics
  cairo freetype harfbuzz imagemagick mpv obs-studio obsidian pango

  # Audio
  cava pavucontrol pipewire playerctl wireplumber

  # Wayland / Compositors
  hyprland niri swww waypaper
  xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-hyprland

  # UI / Shell frameworks
  clipse dms-shell matugen quickshell

  # Video / GPU / Vulkan
  libva mesa vulkan-loader vulkan-tools

  # Networking / System utils
  activate-linux efibootmgr iwd plymouth

  # Applications
  spotify
  zen-browser.packages.${system}.default
  plymouthPkg
]
