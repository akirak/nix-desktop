{ lib }:
let
  mkIniEntry = toValue: name: value: "${name}=${toValue name value}";

  unserialize = name: value:
    if name == "Categories" || name == "MimeType"
    then builtins.concatStringsSep "," value
    else if value == true
    then "true"
    else if value == false
    then "false"
    else if builtins.isString value
    then value
    else builtins.toString value;

  attrPred = _: value:
    if builtins.isList value
    then builtins.length value > 0
    else true;

  mkDesktopEntry = attrs:
    "[Desktop Entry]\n" + builtins.concatStringsSep "\n" (
      lib.mapAttrsToList
        (mkIniEntry unserialize)
        (lib.filterAttrs attrPred attrs)
    );
in
mkDesktopEntry
