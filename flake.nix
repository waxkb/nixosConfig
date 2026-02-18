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
    
    quickshell-custom =
    quickshell.packages.${system}.default.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [
        pkgs.kdePackages.kirigami
        pkgs.kdePackages.kirigami-addons
        pkgs.qt6.qtdeclarative
        pkgs.qt6.qt5compat
        pkgs.qt6.qtsvg
        pkgs.qt6.qtwayland
        #pkgs.qt6.qtgraphicaleffects
      ];

      nativeBuildInputs = [ pkgs.qt6.wrapQtAppsHook ];

      postBuild = ''
        wrapQtApp $out/bin/quickshell
      '';
    });

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
        quickshell-custom = quickshell-custom;
      };
    };

    packages.${system}.quickshell-custom = quickshell-custom;
  };
}
