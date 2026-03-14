{
  description = "saldkjf";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-2511.url = "github:NixOS/nixpkgs/nixos-25.11";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matugen.url = "github:InioX/Matugen";

    #silentSDDM = {
    #  url = "github:uiriansan/SilentSDDM";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llama-cpp = {
      url = "github:ggml-org/llama.cpp";
      flake = false;
    };

    quickshell-src = {
      url = "github:outfoxxed/quickshell";
      flake = false;
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    zen-browser,
    matugen,
    #silentSDDM,
    dms,
    llama-cpp,
    quickshell-src,
    home-manager,
    ...
  }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs25 = import inputs.nixpkgs-2511 {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        ./packages.nix
        home-manager.nixosModules.home-manager
        {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.max = ./home.nix;
        }
        {
          nixpkgs.overlays = [
            (final: prev: {
              llama-cpp = (prev.llama-cpp.override {
                cudaSupport = true;
                blasSupport = false;
              }).overrideAttrs (oldAttrs: {
                src = llama-cpp;
                npmDepsHash = "sha256-5ZswgZFLeI32/xQZqCTTFbCzleDqr5AotjFg/5rNn1M=";
                version = "100000";
                cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
                  "-DGGML_NATIVE=ON"
                  "-DCMAKE_CUDA_ARCHITECTURES=89"
                ];
                preConfigure = ''
                  export NIX_ENFORCE_NO_NATIVE=0
                  ${oldAttrs.preConfigure or ""}
                '';
              });
            })
            (final: prev: {
              khal = pkgs25.khal;
            })
          ];
        }
      ];

      specialArgs = {
        inherit inputs;
        zen-browser = zen-browser;
        matugen = matugen;
        #silentSDDM = silentSDDM;
        dms = dms;
      };
    };

    # This is now properly inside the output set
    packages.${system}.default = pkgs.quickshell.overrideAttrs (oldAttrs: {
      # Add the extra QML/Qt modules your specific shell needs here
      buildInputs = oldAttrs.buildInputs ++ [
        pkgs.kdePackages.qt5compat
        pkgs.kdePackages.qtshadertools
        pkgs.kdePackages.qtsvg
        pkgs.kdePackages.qtimageformats
        pkgs.kdePackages.qtmultimedia
        # Add any other specific ones here (e.g., qtsensors, qtmultimedia)
      ];
    });
  };
}
