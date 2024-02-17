{
  description = "kopecky.io site flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        site = pkgs.stdenv.mkDerivation {
          name = "kopecky-io-site";
          src = ./.;
          buildInputs = with pkgs; [
            zola
          ];
          installPhase = ''
            cd zola
            zola build
            mkdir -p $out
            cp -r public/* $out
          '';
        };
      }
    );
}
