{
  description = "saldkjf";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matugen = {
      url = "github:InioX/Matugen";
    };

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grubshin.url = "github:max-ishere/grubshin-bootpact";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{
    self,
    nixpkgs,
    zen-browser,
    matugen,
    silentSDDM,
    grubshin,
    spicetify-nix,
    dms,
    quickshell,
    ...
  }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix
      ];

      specialArgs = {
        inherit inputs;  # ← REQUIRED for noctalia.nix
        zen-browser = zen-browser;
        matugen = matugen;
        silentSDDM = silentSDDM;
        grubshin = grubshin;
        spicetify-nix = spicetify-nix;
        dms = dms;
        quickshell = quickshell;
      };
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [ ];
    };
  };
}
