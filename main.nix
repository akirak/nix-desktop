{ pkgs ? import <nixpkgs> { }
, configFile
}:
let
  config = import configFile;
in
pkgs.symlinkJoin {
  name = "${config.name}-desktop-config";
  paths =
    pkgs.lib.mapAttrsToList
      (
        name: attrs: pkgs.callPackage ./lib/application.nix {
          inherit (pkgs) writeTextFile lib;
          inherit name attrs;
          header = ''
            # Desktop entry generated by nix-desktop VERSION from
            # ${builtins.toString configFile}
          '';
        }
      )
      config.applications;
}
