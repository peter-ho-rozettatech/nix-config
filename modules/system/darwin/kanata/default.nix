{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.kanata;
  keymaps = import ../../kanata/keymaps.nix;
  KDK_VER = "6.14.0";
  KDK_PKG = pkgs.fetchurl {
    url = "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v${KDK_VER}/Karabiner-DriverKit-VirtualHIDDevice-${KDK_VER}.pkg";
    hash = "sha256-6/tqZD6pi7fC4IpPmTU7KjEp45f0MCNARDu9k28S6xw=";
  };
  KDK_MANAGER = "/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager";
  KDK_DAEMON = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
in
{
  options = {
    services.kanata = {
      enable = lib.mkEnableOption "kanata";

      config = lib.mkOption {
        type = lib.types.str;
        default = keymaps.darwin;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.preActivation.text =
      # sh
      ''
        NEEDS_INSTALL=false

        # Check if manager exists
        if [ ! -f ${KDK_MANAGER} ]; then
            echo "Karabiner DriverKit not found, installing..."
            NEEDS_INSTALL=true
        else
            # Check version from Info.plist
            PLIST_PATH="/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/Info.plist"
            if [ -f "$PLIST_PATH" ]; then
                INSTALLED_VERSION=$(/usr/bin/plutil -extract CFBundleShortVersionString raw "$PLIST_PATH" 2>/dev/null || echo "unknown")
                if [ "$INSTALLED_VERSION" != "${KDK_VER}" ]; then
                    echo "Karabiner DriverKit version mismatch (installed: $INSTALLED_VERSION, expected: ${KDK_VER}), reinstalling..."
                    NEEDS_INSTALL=true
                fi
            else
                echo "Cannot determine installed version, reinstalling..."
                NEEDS_INSTALL=true
            fi
        fi

        if [ "$NEEDS_INSTALL" = true ]; then
            /usr/sbin/installer -pkg ${KDK_PKG} -target /
        fi

        if [ -f ${KDK_MANAGER} ]; then
            ${KDK_MANAGER} activate
        else
            echo "Karabiner DriverKit installation failed"
        fi
      '';

    system.activationScripts.postActivation.text =
      # sh
      ''
        echo "Restarting Karabiner DriverKit ..."
        launchctl unload /Library/LaunchDaemons/org.pqrs.karabiner.driverkit.plist 2> /dev/null || true
        launchctl load /Library/LaunchDaemons/org.pqrs.karabiner.driverkit.plist

        echo "Restarting Kanata ..."
        launchctl unload /Library/LaunchDaemons/local.jtroo.kanata.plist 2> /dev/null || true
        launchctl load /Library/LaunchDaemons/local.jtroo.kanata.plist
      '';

    launchd.daemons = {
      karabinerDriverKit = {
        serviceConfig = {
          Label = "org.pqrs.karabiner.driverkit";
          ProgramArguments = [ KDK_DAEMON ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "/Library/Logs/Karabiner-DriverKit-VirtualHIDDevice/out.log";
          StandardErrorPath = "/Library/Logs/Karabiner-DriverKit-VirtualHIDDevice/error.log";
        };
      };
      kanata = {
        serviceConfig = {
          Label = "local.jtroo.kanata";
          ProgramArguments = [
            "${pkgs.kanata}/bin/kanata"
            "-c"
            "/etc/kanata/kanata.kbd"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "/Library/Logs/Kanata/out.log";
          StandardErrorPath = "/Library/Logs/Kanata/error.log";
        };
      };
    };

    environment = {
      systemPackages = with pkgs; [
        kanata
      ];
      etc."kanata/kanata.kbd".text = cfg.config;
    };
  };
}
