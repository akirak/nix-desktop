{ pkgs ? import <nixpkgs> { } }:
let
  pre-commit = import ./nix/pre-commit.nix { inherit pkgs; };
in
pkgs.mkShell {
  shellHook = pre-commit.shellHook;
}
