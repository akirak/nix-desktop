{
  name = "nix-desktop-test-xdg-systemd";

  xdg.menu.applications.true2 = {
    Name = "true";
    Icon = "true";
    TryExec = "/bin/false";
    Exec = "/bin/true";
    StartupWMClass = "true";
  };

  systemd.services.true-2.text = ''
    [Unit]
    Description=Test true-2

    [Service]
    Type=Oneshot
    ExecStart=/bin/true
    RemainAfterExit=true

    [Install]
    WantedBy=default.target
  '';

}
