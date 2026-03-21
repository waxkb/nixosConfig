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

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llama-cpp = {
      #url = "github:ggml-org/llama.cpp";
      url = "github:RokketCrypto/llama.cpp";
      flake = false;
    };

    sddm-themes = {
      url = "git+ssh://git@github.com/waxkb/sddm-themes.git";
      flake = false;
    };

  };
  outputs = inputs@{
    self,
    nixpkgs,
    zen-browser,
    matugen,
    dms,
    llama-cpp,
    sddm-themes,
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
                #npmDepsHash = "sha256-DxgUDVr+kwtW55C4b89Pl+j3u2ILmACcQOvOBjKWAKQ=";
                npmDepsHash = "sha256-DxgUDVr+kwtW55C4b89Pl+j3u2ILmACcQOvOBjKWAKQ=";
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
        dms = dms;
        sddm-themes = sddm-themes;
      };
    };
  };
}
