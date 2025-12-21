{
  description = "NixOS flake with MineGRUB + Minecraft Plymouth theme";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
    minecraft-plymouth-theme.url = "github:nikp123/minecraft-plymouth-theme";
  };

  outputs = { self, nixpkgs, zen-browser, minegrub-theme, minecraft-plymouth-theme, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix
        minegrub-theme.nixosModules.default
      ];

      specialArgs = {
        zen-browser = zen-browser;
        minecraft-plymouth-theme = minecraft-plymouth-theme;
      };
    };
  };
}
