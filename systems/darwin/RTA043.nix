{ lib, ... }:
{
  imports = [ ./base.nix ];

  user = lib.mkForce "peterho";

  networking.hostName = "RTA043";

  homebrew.casks = [
    "airbuddy"
    "betterdisplay"
    "cursorsense"
    "dbeaver-community"
    "docker"
    "figma"
    "headlamp"
    "jordanbaird-ice"
    "openvpn-connect"
    "pgadmin4"
    "postman"
    "slack"
    "stats"
    "steermouse"
    "visual-studio-code"
  ];
}
