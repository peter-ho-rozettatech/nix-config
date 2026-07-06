{ pkgs, ... }: {
  imports = [
    ./greetd.nix
    ./i18n.nix
    ./niri.nix
  ];
  services = {
    desktopManager = {
      gnome.enable = false;
      plasma6.enable = false;
      cosmic.enable = false;
    };
    xserver = {
      enable = false;
      xkb = {
        layout = "au";
        variant = "";
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;

  # security.pam.services.login.enableGnomeKeyring = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    evince
    nautilus
    networkmanagerapplet
    pwvucontrol
    seahorse
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
