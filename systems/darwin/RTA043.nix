{
  config,
  lib,
  ...
}:
{
  imports = [ ./base.nix ];

  # Aikido Endpoint Protection intercepts TLS (incl. crates.io, npm, pypi) with
  # its own root CA. Trust it in the system bundle so nix-daemon builds
  # (fetchCargoVendor etc.) can verify re-signed connections.
  #
  # The CA is machine-generated per Aikido install (valid until 2046). If Aikido
  # is reinstalled and rotates it, re-extract with:
  #   security find-certificate -a -c "Aikido" -p /Library/Keychains/System.keychain \
  #     > systems/darwin/certs/aikido-root-ca.pem
  #
  # One-time bootstrap on a fresh machine (chicken-and-egg: `darwin-rebuild
  # switch` builds packages before activation installs the new bundle, so the
  # first build still fails TLS verification). Run from the repo root:
  #   1. Build the new CA bundle and point the daemon at it temporarily:
  #      nix build -o /tmp/ca-bundle '.#darwinConfigurations.RTA043.config.environment.etc."ssl/certs/ca-certificates.crt".source'
  #      sudo ln -sfn "$(readlink /tmp/ca-bundle)" /etc/ssl/certs/ca-certificates.crt
  #   2. Build the system (no activation, no sudo):
  #      nix build --no-link .#darwinConfigurations.RTA043.config.system.build.toplevel
  #   3. Restore the managed symlink BEFORE switching, or nix-darwin's
  #      activation check aborts on the unmanaged file:
  #      sudo ln -sfn /etc/static/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
  #   4. Activate as usual (everything already built):
  #      sudo nix run nix-darwin/master -- darwin-rebuild switch --flake .#RTA043 --accept-flake-config
  security.pki.certificateFiles = [ ./certs/aikido-root-ca.pem ];

  # Aikido patches ssl-cert-file into the store copy of nix.conf, which is lost
  # on every rebuild; declare it against the managed bundle instead.
  nix.settings.ssl-cert-file = "/etc/ssl/certs/ca-certificates.crt";

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
