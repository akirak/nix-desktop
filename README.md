# nix-desktop

This repository provides a script which lets you define [XDG desktop menu entries](https://specifications.freedesktop.org/desktop-entry-spec/latest/) in a declarative manner using Nix, per project.

I am a user of [home-manager](https://github.com/nix-community/home-manager). It lets you manage whole programs including executables, configuration files, systemd services, and other files, but its way of configuration is centralized. It (apparently) allows only one configuration per home directory. Sometimes, I wanted something more lightweight.

[Nix Flakes](https://nixos.wiki/wiki/Flakes) lets you define packages and apps within project repositories, which look convenient. However, I did not find a way to integrate such apps with Linux desktop. To start them without opening a terminal, I wanted to install menu entries for those apps, defined within projects. This is an attempt to implement it in a consistent way. Note: This does not depend on Nix Flakes.

For now, it supports only XDG menu entries for desktop applications, but in the future, it may support systemd unit files in the future, to simplify the configuration of home-manager.

## Installation

Install this repository using Nix:

``` shell
nix-env -if .
```

## Writing configuration

You can define menu entries by creating a file named `desktop.nix` in a repository and add files to it. The following is an example:

``` nix
let
  pkgs = import <nixpkgs> {};
in
{
  name = "my-config";
  applications.doom-emacs = {
    Name = "Doom Emacs";
    Icon = "emacs";
    TryExec = "${builtins.getEnv "HOME"}/.config/doom-runner/emacs/bin/doom";
    Exec = "${pkgs.nix}/bin/nix-shell ${builtins.toString ./.}/doom/shell.nix --command emacs";
    StartupWMClass = "Emacs";
  };
}
```

That is, the file defines an expression which contain `name` field and one or more `applications.*` fields. The `name` field is a string that can be part of a Nix derivation name. The application entries defines menu entries, whose most fields have sensible defaults. `Name`, `Icon`, `Exec`, and `StartupWMClass` are required and cannot be omitted.

## Usage

`nix-desktop` command has the following synopsis:

``` shell
nix-desktop [install|uninstall] DIR
```

or with Nix flakes:

``` shell
nix run 'github:akirak/nix-desktop' [install|uninstall] DIR
```

* `DIR` is a directory that contains `desktop.nix`. 
* With `install`, it installs applications defined in the directory. This mode is the default, so you can omit `install` subcommand and specify the directory as the only argument.
  * If you change the configuration, this command installs new/updated items and uninstalls removed items. It is idempotent.
* With `uninstall`, it uninstall the applications.

It creates `.nix-desktop-link` in the same directory as `desktop.nix` to track the installation state. Don't remove this file, and I suggest you add it to `.gitignore` in the repository.

It detects conflicts with applications defined in other projects, so please check error messages.
