{
  description = "Nix Flake for Input Leap.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.05";
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
          packages = {
            input-leap = pkgs.qt6Packages.callPackage ./dist/nix { };
            default = self.packages.${system}.input-leap;
          };

          devShells.default = pkgs.mkShell {
            buildInputs = [ self.packages.${system}.default ];
          };
        }) // {
      overlays.default = final: prev: {
        inherit (self.packages.${final.system}) input-leap;
      };
    };
}
