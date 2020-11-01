{
  name = "nix-desktop-test-systemd-1";

  systemd.services.true-1.text = ''
    [Unit]
    Description=Test true-1

    [Service]
    Type=Oneshot
    ExecStart=/bin/true
    RemainAfterExit=true

    [Install]
    WantedBy=default.target
  '';

  systemd.services.echo.text = ''
    [Unit]
    Description=Test echo

    [Service]
    Type=Oneshot
    ExecStart=/bin/sh -c "echo Hello"
    RemainAfterExit=true

    [Install]
    WantedBy=default.target
  '';
  systemd.services.echo.enable = true;
  systemd.services.echo.start = true;
  systemd.services.echo.restart = true;

}
