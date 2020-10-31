{
  name = "nix-desktop-test-xdg-1";
  xdg.menu.applications.true = {
    Name = "true";
    Icon = "true";
    TryExec = "/bin/false";
    Exec = "/bin/true";
    StartupWMClass = "true";
  };
}
