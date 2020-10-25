{ pkgs ? import <nixpkgs> { }
, config
}:
pkgs.symlinkJoin {
  name = "${config.name}-desktop-config";
  paths =
    pkgs.lib.mapAttrsToList
      (
        name: attrs: pkgs.callPackage ./lib/application.nix {
          inherit (pkgs) writeTextFile lib;
          inherit name attrs;
        }
      )
      config.applications;
}
