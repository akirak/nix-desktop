{ pkgs ? import <nixpkgs> { } }:
let
  sources = import ./nix/sources.nix;
  gitignore = import sources."gitignore.nix" {
    inherit (pkgs) lib;
  };
in
pkgs.runCommandNoCC "nix-desktop"
{
  src = gitignore.gitignoreSource ./.;
} ''
  share=$out/share
  mkdir -p $share
  cp -r -t $share $src/lib $src/main.nix

  mkdir -p $out/bin
  cp $src/bin/nix-desktop $out/bin
  substituteInPlace $out/bin/nix-desktop \
    --replace "'main.nix'" "$share/main.nix"
''
