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
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.outputs.legacyPackages.${system};
      in
      with pkgs;
      {
        packages = {
          input-leap-qt6 = qt6Packages.callPackage ./dist/nix/input-leap-qt6.nix { };
          input-leap-qt5 = libsForQt5.callPackage ./dist/nix/input-leap-qt5.nix { };
          default = self.packages.${pkgs.system}.input-leap-qt6;
        };

        devShells.default = mkShell {
          buildInputs = [
            self.packages.${system}.input-leap-qt5
            self.packages.${system}.input-leap-qt6
          ];
        };
      }
    )
    // {
      overlays.default = final: prev: {
        inherit (self.packages.${final.system}) input-leap-qt6 input-leap-qt5;
      };
    };
}
