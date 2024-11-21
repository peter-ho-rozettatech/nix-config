{ lib, ... }:
{
  imports = [ ./base.nix ];

  user = lib.mkForce "peterho";

  networking.hostName = "RTA043";

  homebrew.casks = [
    "airbuddy"
    "beekeeper-studio"
    "betterdisplay"
    "docker"
    "figma"
    "headlamp"
    "itsycal"
    "jordanbaird-ice"
    "openvpn-connect"
    "pgadmin4"
    "postman"
    "slack"
    "stats"
  ];
}
