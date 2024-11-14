{
  config,
  lib,
  ...
}:
{
  imports = [ ./base.nix ];

  user = lib.mkForce "peterho";

  networking.hostName = "RTA043";

  homebrew.casks = [
    "figma"
    "jordanbaird-ice"
    "pgadmin4"
    "slack"
  ];

  system.defaults.dock = {
    persistent-apps = lib.mkForce [
      "/System/Applications/Launchpad.app"
      "/System/Cryptexes/App/System/Applications/Safari.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Calendar.app"
      "/Applications/Slack.app"
      "/Applications/Google Chrome.app"
      "/Applications/Floorp.app"
      "/Applications/WezTerm.app"
      "/Applications/Figma.app"
    ];
    persistent-others = lib.mkForce [
      "${config.homePath}/Downloads"
    ];
  };
}
