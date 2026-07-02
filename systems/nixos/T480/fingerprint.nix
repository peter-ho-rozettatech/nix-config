{ pkgs, ... }:
let
  sleepTargets = [
    "suspend.target"
    "hibernate.target"
    "hybrid-sleep.target"
    "suspend-then-hibernate.target"
  ];
in
{
  # Usage after switching this host:
  # 1. Enroll once with `fprintd-enroll peter`.
  # 2. Verify with `fprintd-list peter` and `fprintd-verify peter`.
  # 3. Test sudo with `sudo -k` followed by `sudo -v`.
  #    `sudo -k` drops cached auth; `sudo -v` forces a fresh auth check.
  # If the device needs firmware recovery, run
  # `sudo validity-sensors-firmware`, then restart
  # `open-fprintd` and `python3-validity`.
  environment.systemPackages = with pkgs; [
    fprintd
    open-fprintd
    python-validity
    usbutils
  ];

  environment.etc."python-validity/dbus-service.yaml".text = ''
    user_to_sid: {}
  '';

  services.dbus.packages = with pkgs; [
    open-fprintd
    python-validity
  ];

  services.fprintd = {
    enable = false;
    package = pkgs.fprintd;
  };

  systemd.packages = with pkgs; [
    open-fprintd
    python-validity
  ];

  systemd.services = {
    open-fprintd.wantedBy = [ "multi-user.target" ];
    python3-validity.wantedBy = [ "multi-user.target" ];
    open-fprintd-suspend.wantedBy = sleepTargets;
    open-fprintd-resume.wantedBy = sleepTargets;
  };

  security.pam.services = {
    greetd.fprintAuth = true;
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
    "polkit-1".fprintAuth = true;
  };
}
