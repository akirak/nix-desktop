{ pkgs ? import <nixpkgs> { }
, configFile
}:
let
  config = import configFile;

  xdg-desktop-files =
    pkgs.lib.mapAttrsToList
      (
        name: attrs: pkgs.callPackage ./lib/application.nix {
          # inherit (pkgs) writeTextFile lib;
          inherit name attrs;
          header = ''
            # Desktop entry generated by nix-desktop VERSION from
            # ${builtins.toString configFile}
          '';
        }
      )
      (((config.xdg or { }).menu or { }).applications or { });

  collect-systemd-unit-files = { extension, attrs }:
    pkgs.lib.mapAttrsToList
      (
        name: attrs: pkgs.callPackage ./lib/systemd-unit.nix {
          inherit name attrs extension;
        }
      )
      attrs;

  systemd-unit-files =
    pkgs.lib.flatten
      (pkgs.lib.mapAttrsToList
        (name: attrs:
          collect-systemd-unit-files {
            inherit attrs;
            extension = pkgs.lib.removeSuffix "s" name;
          }
        )
        (config.systemd or { }));

  hook-scripts =
    pkgs.callPackage ./lib/hook-scripts.nix {
      systemd = config.systemd or { };
    };
in
pkgs.symlinkJoin {
  name = "${config.name}-desktop-config";
  paths =
    xdg-desktop-files
    ++ systemd-unit-files
    ++ hook-scripts;
}
