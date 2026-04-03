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
      #url = "github:ggml-org/llama.cpp/9f26182";
      #url = "github:ggml-org/llama.cpp?ref=refs/pull/21131/merge";
      #url = "github:ggml-org/llama.cpp";
      #url = "github:AmesianX/TurboQuant";
      url = "github:TheTom/llama-cpp-turboquant/feature/turboquant-kv-cache";
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
                src = llama-cpp; # This refers to your flake input
                npmDepsHash = "sha256-DxgUDVr+kwtW55C4b89Pl+j3u2ILmACcQOvOBjKWAKQ=";
                version = "100000";

                patches = [];   # Ignore patches meant for older versions
                postPatch = ""; # Ignore the cleanup script that is failing

                # 1. Use Ninja for faster build orchestration
                nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ 
                  prev.ninja 
                  prev.ccache 
                ];

                cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
                  "-DGGML_NATIVE=ON"
                  "-DCMAKE_CUDA_ARCHITECTURES=89"
                  "-GNinja" # Tell CMake to use Ninja
                ];

                # 2. Faster Linking with 'mold'
                # We add the flag to the linker via stdenv
                NIX_CFLAGS_COMPILE = (oldAttrs.NIX_CFLAGS_COMPILE or "") + " -fuse-ld=mold";
                buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ prev.mold ];

                preConfigure = ''
                  export NIX_ENFORCE_NO_NATIVE=0
                  # 3. Setup ccache directory within the build sandbox
                  export CCACHE_DIR="/tmp/ccache" 
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
