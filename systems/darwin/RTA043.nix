{ lib, ... }:
{
  imports = [ ./base.nix ];

  user = lib.mkForce "peterho";

  networking.hostName = "RTA043";

  homebrew.casks = [
    "airbuddy"
    "betterdisplay"
    "docker"
    "figma"
    "jordanbaird-ice"
    "pgadmin4"
    "postman"
    "slack"
    "stats"
  ];
}
