{
  description = "Nix Flake for Input Leap.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.outputs.legacyPackages.${system};
        in
        {
          packages.input-leap = pkgs.libsForQt5.callPackage ./dist/nix/input-leap.nix { avahi = pkgs.avahi.override { withLibdnssdCompat = true; }; };
          packages.default = self.outputs.packages.${system}.input-leap;

          devShells.default = self.packages.${system}.default.overrideAttrs (super: {
            nativeBuildInputs = super.nativeBuildInputs;
          });
        })
    // {
      overlays.default = final: prev: {
        inherit (self.packages.${final.system}) input-leap;
      };
    };
}
