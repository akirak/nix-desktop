{ lib, writeTextFile, name, attrs }:
# Check for required attributes
assert (builtins.hasAttr "Name" attrs);
assert (builtins.hasAttr "Icon" attrs);
assert (builtins.hasAttr "Exec" attrs);
assert (builtins.hasAttr "StartupWMClass" attrs);
writeTextFile
  {
    name = "${name}-desktop";
    destination = "/share/applications/${name}.desktop";
    text = import ./desktop-entry.nix { inherit lib; }
      (
        {
          Version = "1.0";
          Type = "Application";
          Terminal = false;
          DBusActivatable = false;
        } // attrs
      );
  }
