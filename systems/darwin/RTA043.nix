{ lib, ... }:
{
  imports = [ ./base.nix ];

  user = lib.mkForce "peterho";

  networking.hostName = "RTA043";

  homebrew.casks = [
    "airbuddy"
    "aws-vpn-client"
    "betterdisplay"
    "cursorsense"
    "dbeaver-community"
    "docker-desktop"
    "figma"
    "headlamp"
    "jordanbaird-ice"
    "microsoft-auto-update"
    "microsoft-teams"
    "openvpn-connect"
    "pgadmin4"
    "postman"
    "slack"
    "stats"
    "steermouse"
    "visual-studio-code"
  ];
}
