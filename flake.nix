{
  description = "NixOS flake with MineGRUB + Minecraft Plymouth theme";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matugen = {
        url = "github:/InioX/Matugen";
    };

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grubshin.url = "github:max-ishere/grubshin-bootpact";

  };

  outputs = { self, nixpkgs, zen-browser, matugen, silentSDDM, grubshin, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix
      ];

      specialArgs = {
        zen-browser = zen-browser;
        matugen = matugen;
        silentSDDM = silentSDDM;
        grubshin = grubshin;
      };
    };
  };
}
