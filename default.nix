{ pkgs ? import <nixpkgs> { } }:
let
  sources = import ./nix/sources.nix;
  gitignore = import sources."gitignore.nix" {
    inherit (pkgs) lib;
  };
  version = "0.1";
in
pkgs.runCommandNoCC "nix-desktop"
{
  src = gitignore.gitignoreSource ./.;
} ''
  share=$out/share
  mkdir -p $share
  cp -r -t $share $src/lib $src/main.nix
  substituteInPlace $share/main.nix \
    --replace VERSION "${version}"

  mkdir -p $out/bin
  cp $src/bin/nix-desktop $out/bin
  substituteInPlace $out/bin/nix-desktop \
    --replace "'main.nix'" "$share/main.nix" \
    --replace "VERSION" "${version}"
''
