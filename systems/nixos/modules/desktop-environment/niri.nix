{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  xdg.portal = {
    enable = true;
    config.niri = {
      default = lib.mkForce [ "gtk" ];
      "org.freedesktop.impl.portal.Access" = lib.mkForce [ "gtk" ];
      "org.freedesktop.impl.portal.Notification" = lib.mkForce [ "gtk" ];
      "org.freedesktop.impl.portal.Settings" = lib.mkForce [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = lib.mkForce [ "gnome-keyring" ];
    };
    extraPortals = lib.mkForce [
      pkgs.xdg-desktop-portal-gtk
      pkgs.gnome-keyring
    ];
  };

  security.pam.services.hyprlock = { };
}
