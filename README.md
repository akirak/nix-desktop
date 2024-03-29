# Nix-Desktop: Application + Service Manager for Linux Desktop

![CI](https://github.com/akirak/nix-desktop/workflows/CI/badge.svg)

**I no longer wish to maintain this repository, so I will archive it.**

`nix-desktop` lets you define Linux desktop integration of Nix projects. With this script, you can define [XDG desktop menu entries](https://specifications.freedesktop.org/desktop-entry-spec/latest/) and systemd units declaratively using Nix and apply it in an idempotent way.

I am a user of [home-manager](https://github.com/nix-community/home-manager). It lets you manage an entire user (home) configuration including program executables, configuration files, systemd services, and other files, but its way of configuration is centralized. It (apparently) allows only one configuration per home directory. Sometimes, I wanted something slightly decentralized. For example, I have some private Git repositories that contain data, and I want to install applications related to the repositories onto machines that are only relevant. I want to hide their existence from the public, and thus they shouldn't be mentioned in my public configuration.

[Nix flakes](https://nixos.wiki/wiki/Flakes) lets you define packages and apps within project repositories, which look convenient. However, I did not find a way to integrate such apps with Linux desktop. To start them without opening a terminal, I wanted to install menu entries for those apps, defined within projects. This is an attempt to implement it in a consistent way. Note: This does not depend on Nix Flakes.

Unlike naive ad-hoc installation of configuration files using `nix-env`, `nix-desktop` updates the system state. It notifies updates on desktop menu entries and reload/enable/(re)starts installed systemd units (and stops and disables uninstalled units). This is a convenient and reliable solution for deplying a set of desktop applications and services.

## Installation

Install this repository using Nix:

``` shell
nix-env -if .
```

Alternatively, you can use the program without installing it if you have already enabled Nix flakes:

``` shell
nix run 'github:akirak/nix-desktop'
```

## Writing configuration

You can define configuration by creating a file named `desktop.nix` in a repository. The following is an example:

``` nix
let
  pkgs = import <nixpkgs> {};
  thisDir = builtins.toString ./.;
in
{
  name = "my-config";

  # Run Doom Emacs inside a sandboxed nix-shell session.
  xdg.menu.applications.doom-emacs = {
    Name = "Doom Emacs";
    Icon = "emacs";
    TryExec = "${builtins.getEnv "HOME"}/.config/doom-runner/emacs/bin/doom";
    Exec = "${pkgs.nix}/bin/nix-shell ${builtins.toString ./.}/doom/shell.nix --command emacs";
    StartupWMClass = "Emacs";
  };

  # Automatically set up an overlayfs directory in the repository.
  systemd.services.overlayfs-repos = {
    enable = true;
    start = true;
    restart = false;
    text = ''
      [Unit]
      Description=Example overlayfs service
      ConditionPathIsDirectory=${thisDir}/repos-src
      ConditionPathIsDirectory=${thisDir}/repos-overlay
      ConditionPathIsDirectory=${thisDir}/.repos-work
      ConditionPathIsDirectory=${thisDir}/repos
  
      [Service]
      Type=oneshot
      ExecStart=${pkgs.fuse-overlayfs}/bin/fuse-overlayfs -o lowerdir=${thisDir}/repos-src,upperdir=${thisDir}/repos-overlay,workdir=${thisDir}/.repos-work ${thisDir}/repos
      RemainAfterExit=yes
      ExecStop=${pkgs.fuse}/bin/fusermount -u ${thisDir}/repos
  
      [Install]
      WantedBy=default.target
    '';
  };  
}
```

The file exports an attribute set, and it must contain a mandatory `name` field, which is used to uniquely identify projects. It will become part of the Nix derivation to be built, so it should be file name safe.

### XDG applications

`xdg.menu.applications.*` define XDG menu entries. Some fields have sensible defaults, but you have to specify `Name`, `Icon`, `Exec`, and `StartupWMClass`.

### Systemd units

`systemd.TYPE.*` define user systemd services. `TYPE` can be `services`, `timers`, and other plurals for representing unit types that are supported by systemd.

It must contain `text` field which will become the content of the unit file.

It also supports the following optional fields:

- `enable` (bool): Enable the unit after installation.
- `start` (bool): Start the unit after installation, if it is not installation.
- `restart` (bool): If a unit is changed, restart the unit. Unchanged units won't be restarted even with this option.

## Usage

### Install/uninstall a project

`nix-desktop` command has the following synopsis:

``` shell
nix-desktop [install|uninstall|build] DIR
```

or with Nix flakes:

``` shell
nix run 'github:akirak/nix-desktop' [install|uninstall|build] DIR
```

`DIR` is a required argument, and it should be set to a directory that contains `desktop.nix`.

The command supports the following modes of operations, which should be denoted by the optional first argument prepended to the directory:

* With `install`, it installs applications defined in the directory. This mode is the default, so you can omit `install` subcommand and specify the directory as the only argument.
  * If you change the configuration, this command installs new/updated items and uninstalls removed items. It is idempotent.
* With `uninstall`, it uninstall the applications.
* `build` is like `install`, but it only builds the configuration and neither install configuration files nor update the system.

It detects conflicts with applications defined in other projects, so please check error messages.

### List/update the projects in the user's environment

You can browse a list of installed projects:

``` shell
nix-desktop list
```

With `--verify` flag, the list command checks if the source directories exist.

``` shell
nix-desktop list --verify
```

You can also update all installed projects with a single command:

``` shell
nix-desktop update
```
