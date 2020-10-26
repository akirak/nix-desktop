{
  description = "Linux desktop integration for Nix projects";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-20.03;
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "i686-linux"
    ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        theDrv = import ./default.nix { inherit pkgs; };
      in
        rec {
          packages = flake-utils.lib.flattenTree { nix-desktop = theDrv; };
          defaultPackage = packages.nix-desktop;
          apps.nix-desktop = flake-utils.lib.mkApp { drv = packages.nix-desktop; };
          defaultApp = apps.nix-desktop;
        }
    );
}
