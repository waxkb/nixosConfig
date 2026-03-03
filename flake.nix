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

    #dms = {
    #  url = "github:AvengeMedia/DankMaterialShell";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    llama-cpp = {
      url = "github:ggml-org/llama.cpp";
      flake = false;
    };

  };

  outputs = inputs@{
    self,
    nixpkgs,
    zen-browser,
    matugen,
    silentSDDM,
    #dms,
    llama-cpp,
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
        {
          # Overlay to replace the standard llama-cpp with your git version
          nixpkgs.overlays = [
            (final: prev: {
              llama-cpp = (prev.llama-cpp.override {
                cudaSupport = true;
                blasSupport = false;
              }).overrideAttrs (oldAttrs: {
                # We use the source from our flake input
                src = llama-cpp;
                npmDepsHash = "sha256-FKjoZTKm0ddoVdpxzYrRUmTiuafEfbKc4UD2fz2fb8A=";
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
          ];
        }
      ];

      specialArgs = {
        inherit inputs;  # ← REQUIRED for noctalia.nix
        zen-browser = zen-browser;
        matugen = matugen;
        silentSDDM = silentSDDM;
        #dms = dms;
      };
    };
  };
}
