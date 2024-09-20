{
  description = "My configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = {
    nixpkgs,
    rust-overlay,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        flake-parts.flakeModules.easyOverlay
      ];
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
      ];
      perSystem = {
        config,
        system,
        pkgs,
        ...
      }: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
          ];
          config = {};
        };
        rustToolChain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustToolChain;
          rustc = rustToolChain;
        };
        spr = pkgs.callPackage ./package.nix {inherit rustPlatform pkgs;};
      in rec {
        overlayAttrs = {
          inherit (config.packages) spr;
        };

        packages = {
          inherit spr;
          default = spr;
        };

        apps = {
          default = {
            type = "app";
            program = "${packages.default}/bin/spr";
          };
        };

        devShells = {
          default = with pkgs;
            mkShell {
              buildInputs =
                [
                  openssl
                  pkg-config
                  rustToolChain
                  mdbook
                ]
                ++ packages.default.buildInputs;

              shellHook = ''
              '';
            };
        };
      };
    };
}
