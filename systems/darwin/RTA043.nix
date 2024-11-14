{ lib, ... }:
{
  imports = [ ./base.nix ];

  user = lib.mkForce "peterho";

  networking.hostName = "RTA043";

  homebrew.casks = [
    "figma"
    "jordanbaird-ice"
    "slack"
  ];
}
