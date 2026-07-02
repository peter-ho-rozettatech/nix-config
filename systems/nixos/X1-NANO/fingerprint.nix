{ pkgs, ... }:
{
  # Usage after switching this host:
  # 1. Enroll once with `fprintd-enroll peter`.
  # 2. Verify with `fprintd-list peter` and `fprintd-verify peter`.
  # 3. Test sudo with `sudo -k` followed by `sudo -v`.
  #    `sudo -k` drops cached auth; `sudo -v` forces a fresh auth check.
  environment.systemPackages = with pkgs; [
    fprintd
    usbutils
  ];

  services.dbus.packages = [ pkgs.fprintd ];
  systemd.packages = [ pkgs.fprintd ];
  services.fprintd.package = pkgs.fprintd;

  security.pam.services = {
    greetd.fprintAuth = true;
    sudo.fprintAuth = false;
    hyprlock.fprintAuth = true;
    "polkit-1".fprintAuth = false;
  };
}
