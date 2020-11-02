{ pkgs ? import <nixpkgs> { } }:
let
  sources = import ./nix/sources.nix;
  gitignore = import sources."gitignore.nix" {
    inherit (pkgs) lib;
  };
  version = "0.1";
  ansi = builtins.fetchTarball (import ./nix/sources.nix).ansi.url;
in
pkgs.runCommandNoCC "nix-desktop"
{
  src = gitignore.gitignoreSource ./.;
  propagateBuildInputs = [
    # Needed for xdg-desktop-menu executable
    pkgs.xdg_utils
    ansi
  ];
} ''
  share=$out/share
  mkdir -p $share
  cp -r -t $share $src/lib $src/main.nix
  substituteInPlace $share/main.nix \
    --replace VERSION "${version}"

  mkdir -p $out/bin
  cp $src/bin/nix-desktop $out/bin
  substituteInPlace $out/bin/nix-desktop \
    --replace "'ansi/ansi'" "'${ansi}/ansi'" \
    --replace "'main.nix'" "$share/main.nix" \
    --replace "VERSION" "${version}"
''
