{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../base
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
  ];

  stylix.targets = {
    chromium.enable = false;
    console.enable = true;
  };

  nix.gc.dates = "weekly";
  nix.settings.auto-optimise-store = true;

  security.sudo = {
    execWheelOnly = true;
    extraConfig = ''
      Defaults pwfeedback
      Defaults timestamp_timeout=60
      Defaults timestamp_type=tty
    '';
  };

  users.users.${config.user} = {
    isNormalUser = true;
    extraGroups = [
      "dialout"
      "wheel"
    ];
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ ];
  };

  virtualisation = {
    docker = {
      # The rootful Docker socket gives every member of the docker group
      # effective root access. Use the per-user daemon instead.
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  time.timeZone = "Australia/Sydney";

  system.stateVersion = lib.mkDefault "25.11";
}
