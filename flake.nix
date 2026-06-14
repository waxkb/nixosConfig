{
  description = "saldkjf";
  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-2511.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixos-core.url = "github:manic-systems/nixos-core";

    ncro.url = "github:manic-systems/ncro";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matugen.url = "github:InioX/Matugen";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llama-cpp = {
      # url = "github:ggml-org/llama.cpp/9f26182";
      # url = "github:ggml-org/llama.cpp?ref=refs/pull/23352/merge";
      url = "github:ggml-org/llama.cpp";
      # url = "github:ggml-org/llama.cpp/67b2b7f2f2d6dac7962b219168a4c7a20c7359b7";
      # url = "github:TheTom/llama-cpp-turboquant/feature/turboquant-kv-cache";
      flake = false;
    };

    # sddm-themes = {
    #   url = "git+ssh://git@github.com/waxkb/sddm-themes.git";
    #   flake = false;
    # };

    tuigreet.url = "github:NotAShelf/tuigreet";

    claude-code.url = "github:sadjow/claude-code-nix";

    areofyl-fetch.url = "github:areofyl/fetch";

  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      zen-browser,
      matugen,
      dms,
      noctalia,
      # llama-cpp,
      # sddm-themes,
      tuigreet,
      home-manager,
      claude-code,
      areofyl-fetch,
      ncro,
      nixos-core,
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
          nixos-core.nixosModules.default
          inputs.dms.nixosModules.dank-material-shell
          inputs.ncro.nixosModules.default
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
              # (final: prev: {
              #   inherit (prev.lixPackageSets.stable)
              #     nixpkgs-review
              #     nix-eval-jobs
              #     nix-fast-build
              #     colmena
              #     ;
              # })
              noctalia.overlays.default
              # (
              #   final: prev:
              #   let
              #     ccacheCudaPackages = prev.cudaPackages.overrideScope (
              #       _: cudaPrev: {
              #         # llama-cpp uses cudaPackages.backendStdenv when CUDA is enabled,
              #         # so wrapping only the package's stdenv does not reach the actual compiler.
              #         backendStdenv = final.ccacheStdenv.override {
              #           stdenv = cudaPrev.backendStdenv;
              #         };
              #       }
              #     );
              #   in
              #   {
              #     llama-cpp =
              #       (prev.llama-cpp.override {
              #         cudaSupport = true;
              #         cudaPackages = ccacheCudaPackages;
              #         rocmSupport = false;
              #         metalSupport = false;
              #         blasSupport = true;
              #       }).overrideAttrs
              #         (oldAttrs: {
              #           src = llama-cpp;
              #           npmDepsHash = "sha256-TU4Gv+dd48WDpswhfVtm79IVIOwoCXz1fZ/DI/z40Wg=";
              #           version = "1";

              #           patches = [ ];
              #           postPatch = "";

              #           nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
              #             prev.ninja
              #           ];

              #           cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
              #             "-GNinja"
              #             "-DGGML_NATIVE=ON"
              #             "-DCMAKE_CUDA_ARCHITECTURES=89"
              #             "-DGGML_AVX=ON"
              #             "-DGGML_AVX2=ON"
              #             "-DGGML_AVX512=ON"
              #             "-DGGML_CUDA_FA_ALL_QUANTS=ON"
              #             "-DGGML_CUDA_GRAPHS=ON"
              #             # "-DCMAKE_UNITY_BUILD=ON"
              #             # "-DCMAKE_UNITY_BUILD_BATCH_SIZE=32"
              #           ];

              #           NIX_CFLAGS_COMPILE =
              #             (oldAttrs.NIX_CFLAGS_COMPILE or "") + " -march=native -mtune=native -fuse-ld=mold -Wl,--threads";

              #           buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ prev.mold ];

              #           preConfigure = ''
              #             export NIX_ENFORCE_NO_NATIVE=0
              #             ${oldAttrs.preConfigure or ""}
              #           '';
              #         });
              #   }
              # )
              (final: prev: {
                khal = pkgs25.khal;
              })
              claude-code.overlays.default
            ];
          }
        ];

        specialArgs = {
          inherit inputs;
        };
      };
    };
}
