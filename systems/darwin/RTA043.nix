{
  config,
  lib,
  pkgs,
  ...
}:
let
  nixCaBundle = pkgs.runCommand "rta043-nix-ca-bundle" { } ''
    cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt ${../../certs/aikido-l4-mitm-ca.localhost.pem} > $out
  '';
in
{
  imports = [ ./base.nix ];

  nix.settings.ssl-cert-file = "${nixCaBundle}";

  environment.variables = {
    CURL_CA_BUNDLE = "${nixCaBundle}";
    NIX_SSL_CERT_FILE = "${nixCaBundle}";
    REQUESTS_CA_BUNDLE = "${nixCaBundle}";
    SSL_CERT_FILE = "${nixCaBundle}";
  };

  homebrew = {
    taps = [
      "ariga/tap"
    ];
    brews = [
      "ariga/tap/atlas"
      "dnsmasq"
    ];
    casks = [
      # "airbuddy"
      "another-redis-desktop-manager"
      "aws-vpn-client"
      "betterdisplay"
      "claude"
      "cursorsense"
      "dbeaver-community"
      "docker-desktop"
      "figma"
      # "jordanbaird-ice"
      # "kubetail"
      # "microsoft-auto-update"
      # "microsoft-teams"
      # "openvpn-connect"
      "pgadmin4"
      "postman"
      "slack"
      "stats"
      "steermouse"
      "tailscale-app"
      "thaw"
      # "visual-studio-code"
    ];
  };

  system.defaults.dock = {
    persistent-apps = lib.mkForce [
      "/System/Applications/Apps.app"
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
