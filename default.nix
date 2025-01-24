{  
  pkgs ? import <nixpkgs> {},
  lib ? import <nixpkgs/lib>,
  darwin ? pkgs.darwin,
  stdenv ? pkgs.stdenv,
  rustPlatform ? pkgs.rustPlatform,
}:

rustPlatform.buildRustPackage {
      pname = "spr";
      version = "1.3.4";

      src = ./.;
      cargoLock = {
        lockFile = ./Cargo.lock;
      };

      buildInputs = 
    lib.optional stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
        ];

  meta = with lib; {
        description = "Submit pull requests for individual, amendable, rebaseable commits to GitHub";
        mainProgram = "spr";
        homepage = "https://github.com/getcord/spr";
        license = licenses.mit;
        maintainers = with maintainers; [sven-of-cord];
      };
}
