{
  config,
  lib,
  ...
}:
{
  imports = [ ./base.nix ];

  user = lib.mkForce "peterho";

  networking.hostName = "RTA043";

  homebrew = {
    taps = [
      "ariga/tap"
      "localstack/tap"
    ];
    brews = [
      "ariga/tap/atlas"
      "dnsmasq"
      "localstack/tap/localstack-cli"
    ];
    casks = [
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
  };

  system.defaults.dock = {
    persistent-apps = lib.mkForce [
      "/System/Applications/Launchpad.app"
      "/System/Cryptexes/App/System/Applications/Safari.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Calendar.app"
      "/System/Applications/Notes.app"
      "/Applications/Slack.app"
      "/Applications/Google Chrome.app"
      "/Applications/Firefox.app"
      "/Applications/Floorp.app"
      "/Applications/Ghostty.app"
      "/Applications/Figma.app"
    ];
    persistent-others = lib.mkForce [
      "${config.homePath}/Downloads"
    ];
  };
}
