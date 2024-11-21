{ lib, ... }:
{
  imports = [ ./base.nix ];

  user = lib.mkForce "peterho";

  networking.hostName = "RTA043";

  homebrew.casks = [
    "betterdisplay"
    "docker"
    "figma"
    "jordanbaird-ice"
    "pgadmin4"
    "postman"
    "slack"
  ];
}
