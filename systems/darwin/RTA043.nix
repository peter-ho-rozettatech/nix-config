{ lib, ... }:
{
  imports = [ ./base.nix ];

  user = lib.mkForce "peterho";

  networking.hostName = "RTA043";

  homebrew.casks = [
    "airbuddy"
    "beekeeper-studio"
    "betterdisplay"
    "cursorsense"
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
    "steermouse"
  ];
}
