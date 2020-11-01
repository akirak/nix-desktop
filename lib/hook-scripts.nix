{ systemd, stdenv, lib, writeTextFile }:
let
  systemdUnits =
    lib.mapAttrsToList
      (name: attrs: ({
        filename = "${name}.service";
      } // attrs))
      (systemd.services or { });

  systemdEnabledUnits =
    builtins.map (attrs: attrs.filename)
      (builtins.filter (attrs: attrs.enable or false) systemdUnits);

  systemdStartedUnits =
    builtins.map (attrs: attrs.filename)
      (builtins.filter (attrs: attrs.start or false) systemdUnits);

  systemdRestartedUnits =
    builtins.map (attrs: attrs.filename)
      (builtins.filter (attrs: attrs.restart or false) systemdUnits);

  makeHookScript = name: text: writeTextFile {
    inherit name;
    text = "#!${stdenv.shell}\n" + text;
    executable = true;
    destination = "/.${name}";
    checkPhase = ''
      ${stdenv.shell} -n $out/.${name}
    '';
  };

  pre-remove-hook =
    if builtins.length systemdUnits == 0
    then null
    else
      makeHookScript "pre-remove-hook" ''
        dir="$1"
        file="$2"

        case "$dir" in
          share/systemd/user)
            if systemctl --user --quiet is-active "$file"; then
              systemctl --user --no-pager stop "$file"
              echo "systemd: stopped $file"
            fi
            if systemctl --user --quiet is-enabled "$file"; then
              systemctl --user --no-pager disable "$file"
            fi
            ;;
        esac
      '';

  addSystemdUnitSh = name: "systemdUnits[${name}]=1";

  post-add-hook =
    if builtins.length systemdEnabledUnits == 0
    then null
    else
      makeHookScript "post-add-hook" ''
        dir="$1"
        file="$2"
        declare -A systemdUnits
        ${builtins.concatStringsSep "\n" (builtins.map addSystemdUnitSh systemdEnabledUnits)}
        case "$dir" in
          share/systemd/user)
            if [[ -n "''${systemdUnits[$file]}" ]]; then
              if systemctl --user --quiet is-enabled "$file"; then
                echo "systemd: $file is already enabled"
              else
                systemctl --user --no-pager enable "$file"
              fi
            fi
            ;;
        esac
      '';

  activate-on-add-hook =
    if builtins.length systemdStartedUnits == 0
    then null
    else
      makeHookScript "activate-on-add-hook" ''
        dir="$1"
        file="$2"
        declare -A systemdUnits
        ${builtins.concatStringsSep "\n" (builtins.map addSystemdUnitSh systemdStartedUnits)}
        case "$dir" in
          share/systemd/user)
            if [[ -n "''${systemdUnits[$file]}" ]]; then
              echo -n "systemd: starting $file... "
              if systemctl --user --quiet is-active "$file"; then
                echo "ignored (already started)"
              else
                systemctl --user --no-pager start "$file"
                echo "OK"
              fi
            fi
            ;;
        esac
      '';

  activate-on-change-hook =
    if builtins.length systemdRestartedUnits == 0
    then null
    else
      makeHookScript "activate-on-change-hook" ''
        dir="$1"
        file="$2"
        declare -A systemdUnits
        ${builtins.concatStringsSep "\n" (builtins.map addSystemdUnitSh systemdRestartedUnits)}
        echo "$*"
        case "$dir" in
          share/systemd/user)
            if [[ -n "''${systemdUnits[$file]}" ]]; then
              echo -n "systemd: restarting $file... "
              systemctl --user --no-pager restart "$file"
              echo "OK"
            fi
            ;;
        esac
      '';

in
builtins.filter (x: x != null)
  [
    pre-remove-hook
    post-add-hook
    activate-on-add-hook
    activate-on-change-hook
  ]
