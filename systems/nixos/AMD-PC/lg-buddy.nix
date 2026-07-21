{
  config,
  lib,
  pkgs,
  ...
}:
let
  configFile = "${config.homePath}/.config/lg-buddy/config.env";
  keyFile = "${config.homePath}/.config/lg-buddy/.aiopylgtv.sqlite";
  lgBuddyEnv = {
    LG_BUDDY_BSCPYLGTV_KEY_FILE = keyFile;
    LG_BUDDY_BSCPYLGTV_OWNER_USER = config.user;
    LG_BUDDY_CONFIG = configFile;
  };

  # Compares the MAC stored in config.env against the live neighbour cache
  # entry for the TV's IP. When they disagree (the TV has roamed between
  # Wi-Fi radios on a multi-band LG OLED), re-runs lg-buddy-configure so the
  # Wake-on-LAN target tracks the active radio.
  #
  # Also appends every distinct observed MAC to known_macs so the startup
  # wrapper can retry with historical candidates if the TV is unreachable
  # at boot time.
  macSyncScript = pkgs.writeShellScript "lg-buddy-mac-sync" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [
      pkgs.coreutils
      pkgs.gnused
      pkgs.gawk
      pkgs.gnugrep
      pkgs.iputils
      pkgs.iproute2
    ]}"

    config_file="${configFile}"
    [ -r "$config_file" ] || exit 0

    read_cfg() {
      local key="$1"
      sed -n "s/^''${key}=//p" "$config_file" | tail -n1
    }

    tv_ip="$(read_cfg tvs_primary_ip)"
    tv_ip="''${tv_ip:-$(read_cfg tv_ip)}"
    configured_mac="$(read_cfg tvs_primary_mac)"
    configured_mac="''${configured_mac:-$(read_cfg tv_mac)}"

    [[ "$tv_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || exit 0
    [[ "$configured_mac" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]] || exit 0

    # Light ICMP nudge to refresh the neighbour entry if it has gone STALE.
    # ICMP does not wake a TV in deep standby; only Wake-on-LAN does.
    ${lib.getBin pkgs.iputils}/bin/ping -c 1 -W 1 "$tv_ip" >/dev/null 2>&1 || true

    current_mac="$(${lib.getBin pkgs.iproute2}/bin/ip neigh show "$tv_ip" 2>/dev/null \
      | awk '/lladdr/ { print $5; exit }')"
    [[ "$current_mac" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]] || exit 0

    current_mac="$(printf '%s' "$current_mac" | tr 'A-F' 'a-f')"
    configured_mac="$(printf '%s' "$configured_mac" | tr 'A-F' 'a-f')"

    # Record the observed MAC in the history file. Deduplication preserves the
    # most-recently-observed order: move the entry to the end so the startup
    # wrapper iterates oldest-to-newest when retrying.
    known_macs_file="$(dirname "$config_file")/known_macs"
    touch "$known_macs_file"
    chmod 600 "$known_macs_file" 2>/dev/null || true
    tmp_known="$(mktemp)"
    grep -Fxv -- "$current_mac" "$known_macs_file" > "$tmp_known" 2>/dev/null || true
    printf '%s\n' "$current_mac" >> "$tmp_known"
    cat "$tmp_known" > "$known_macs_file"
    rm -f "$tmp_known"

    if [[ "$current_mac" == "$configured_mac" ]]; then
      exit 0
    fi

    printf 'lg-buddy-mac-sync: TV MAC drift detected (configured=%s current=%s); running lg-buddy-configure\n' \
      "$configured_mac" "$current_mac"
    exec ${pkgs.lg-buddy}/bin/lg-buddy-configure
  '';

  # Wraps `lg-buddy startup auto` so that if the currently configured MAC fails
  # to wake the TV, we fall back to other MACs previously observed for this TV
  # (recorded by mac-sync). Each candidate is swapped into config.env before
  # the startup attempt; whichever MAC succeeds is left in the config so the
  # next regular mac-sync picks it up.
  startupWrapper = pkgs.writeShellScript "lg-buddy-startup-wrapper" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [
      pkgs.coreutils
      pkgs.gnused
      pkgs.gawk
      pkgs.gnugrep
    ]}"

    config_file="${configFile}"
    [ -r "$config_file" ] || exec ${pkgs.lg-buddy}/bin/lg-buddy startup auto

    config_dir="$(dirname "$config_file")"
    known_macs_file="$config_dir/known_macs"
    lg_buddy="${pkgs.lg-buddy}/bin/lg-buddy"
    bscpylgtv="${pkgs.lg-buddy.passthru.bscpylgtv}/bin/bscpylgtvcommand"
    key_file="${keyFile}"

    read_cfg() {
      local key="$1"
      sed -n "s/^''${key}=//p" "$config_file" | tail -n1
    }

    configured_mac="$(read_cfg tvs_primary_mac)"
    configured_mac="''${configured_mac:-$(read_cfg tv_mac)}"

    # Build the candidate list. Configured MAC first (already in config so no
    # rewrite needed for it); then any known MACs that differ. Iterate in
    # reverse order of known_macs so the most recently observed MAC is tried
    # before older candidates.
    macs_to_try=()
    if [[ "$configured_mac" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
      macs_to_try+=("$(printf '%s' "$configured_mac" | tr 'A-F' 'a-f')")
    fi
    if [[ -r "$known_macs_file" ]]; then
      while IFS= read -r mac; do
        [[ "$mac" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]] || continue
        mac="$(printf '%s' "$mac" | tr 'A-F' 'a-f')"
        skip=0
        for existing in "''${macs_to_try[@]:-}"; do
          [[ "$existing" == "$mac" ]] && skip=1 && break
        done
        [[ $skip -eq 0 ]] && macs_to_try+=("$mac")
      done < <(tac "$known_macs_file" 2>/dev/null)
    fi

    update_config_mac() {
      local mac="$1"
      local tmp
      tmp="$(mktemp)"
      awk -v mac="$mac" '
        BEGIN { saw_legacy = 0; saw_primary = 0 }
        /^tv_mac=/ { print "tv_mac=" mac; saw_legacy = 1; next }
        /^tvs_primary_mac=/ { print "tvs_primary_mac=" mac; saw_primary = 1; next }
        { print }
        END {
          if (!saw_legacy) print "tv_mac=" mac
          if (!saw_primary) print "tvs_primary_mac=" mac
        }
      ' "$config_file" > "$tmp"
      # Use cat to overwrite in place; preserves the file's existing owner and
      # mode, which matters because lg-buddy.service runs as root while the
      # config file is owned by the user.
      cat "$tmp" > "$config_file"
      rm -f "$tmp"
    }

    startup_succeeds() {
      # lg-buddy startup returns 0 even when it gives up on set_input retries,
      # so we detect success by scanning stdout for the success marker.
      local output
      output="$("$lg_buddy" startup auto 2>&1)" || true
      printf '%s\n' "$output"
      if printf '%s' "$output" | grep -q "TV turned on and set to"; then
        return 0
      fi
      return 1
    }

    run_diagnostic() {
      # lg-buddy's startup loop only logs "Attempt N failed" and discards the
      # underlying set_input error, so on overall failure we replay the WebOS
      # command directly to surface *why* it failed (handshake timeout, auth
      # refusal, SSL error, ...). Read-only (get_input) so TV state is never
      # changed, and bounded by `timeout` in case the TV is fully unreachable.
      local tv_ip neigh diag
      tv_ip="$(read_cfg tvs_primary_ip)"
      tv_ip="''${tv_ip:-$(read_cfg tv_ip)}"
      printf 'lg-buddy-startup-wrapper: --- diagnostic after startup failure ---\n' >&2
      if [[ -z "$tv_ip" ]]; then
        printf 'lg-buddy-startup-wrapper: no TV IP in config; skipping diagnostic\n' >&2
        return 0
      fi
      neigh="$(${lib.getBin pkgs.iproute2}/bin/ip neigh show "$tv_ip" 2>/dev/null || true)"
      printf 'lg-buddy-startup-wrapper: neighbour for %s: %s\n' "$tv_ip" "$neigh" >&2
      if ${lib.getBin pkgs.iputils}/bin/ping -c 1 -W 1 "$tv_ip" >/dev/null 2>&1; then
        printf 'lg-buddy-startup-wrapper: %s responds to ICMP (TV network stack is up)\n' "$tv_ip" >&2
      else
        printf 'lg-buddy-startup-wrapper: %s does NOT respond to ICMP (TV offline or in deep standby)\n' "$tv_ip" >&2
      fi
      if [[ -x "$bscpylgtv" ]]; then
        printf 'lg-buddy-startup-wrapper: bscpylgtv get_input against %s (reveals the WebOS error lg-buddy hid):\n' "$tv_ip" >&2
        diag="$(timeout 20 "$bscpylgtv" -p "$key_file" "$tv_ip" get_input 2>&1)" || true
        printf '%s\n' "$diag" >&2
      fi
    }

    if [[ "''${#macs_to_try[@]}" -eq 0 ]]; then
      exec "$lg_buddy" startup auto
    fi

    for mac in "''${macs_to_try[@]}"; do
      printf 'lg-buddy-startup-wrapper: trying MAC %s\n' "$mac" >&2
      # Only rewrite config if this MAC differs from the currently configured
      # one; otherwise just run startup with the existing config.
      current_cfg_mac="$(read_cfg tvs_primary_mac)"
      current_cfg_mac="''${current_cfg_mac:-$(read_cfg tv_mac)}"
      if [[ -n "$current_cfg_mac" ]] \
        && [[ "$(printf '%s' "$current_cfg_mac" | tr 'A-F' 'a-f')" != "$mac" ]]; then
        update_config_mac "$mac"
      fi
      if startup_succeeds; then
        printf 'lg-buddy-startup-wrapper: TV woke with MAC %s\n' "$mac" >&2
        exit 0
      fi
      printf 'lg-buddy-startup-wrapper: MAC %s did not wake the TV\n' "$mac" >&2
    done

    printf 'lg-buddy-startup-wrapper: all %d MAC candidate(s) failed\n' \
      "''${#macs_to_try[@]}" >&2
    run_diagnostic
    exit 1
  '';
in
{
  environment.systemPackages = [ pkgs.lg-buddy ];

  systemd.tmpfiles.rules = [
    "d /run/lg_buddy 0755 root root -"
    "d ${config.homePath}/.config/lg-buddy 0700 ${config.user} users -"
  ];

  systemd.services."lg-buddy" = {
    description = "Controls LG WebOS TV at startup and shutdown";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    environment = lgBuddyEnv // {
      # lg-buddy hardcodes 6 wake attempts and applies this value as a flat
      # sleep before each one. After a long standby the screen lights fast but
      # the WebOS SSAPI layer can take a few minutes to accept commands; at 20s
      # every attempt landed before that window opened (the 19:28 boot exhausted
      # all 6 by ~144s). 45s spreads the attempts across ~270s so one lands once
      # WebOS is ready. Safe because Type=oneshot has TimeoutStartSec=infinity.
      LG_BUDDY_STARTUP_RETRY_DELAY_SECS = "45";
    };
    unitConfig = {
      ConditionPathExists = configFile;
      StartLimitIntervalSec = 30;
      StartLimitBurst = 5;
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Refresh the Wake-on-LAN MAC before startup so we target the radio the
      # TV is currently associated on (handles Wi-Fi band roaming). Falls
      # through silently if the TV is unreachable at boot.
      ExecStartPre = macSyncScript;
      # Try the configured MAC first; on failure, fall back to other MACs
      # previously observed for this TV.
      ExecStart = startupWrapper;
      ExecStop = "${pkgs.lg-buddy}/bin/lg-buddy shutdown";
    };
  };

  systemd.services."lg-buddy-lifecycle" = {
    description = "LG Buddy system sleep/wake lifecycle monitor";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = lgBuddyEnv;
    unitConfig.ConditionPathExists = configFile;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.lg-buddy}/bin/lg-buddy lifecycle";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

  systemd.services."lg-buddy-mac-sync" = {
    description = "LG Buddy TV MAC drift auto-correction";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = lgBuddyEnv;
    unitConfig.ConditionPathExists = configFile;
    # Run as the user so the known_macs history file stays user-owned and
    # lg-buddy-configure's writes to config.env don't change its owner.
    serviceConfig = {
      Type = "oneshot";
      ExecStart = macSyncScript;
      User = config.user;
    };
  };

  systemd.timers."lg-buddy-mac-sync" = {
    description = "LG Buddy TV MAC drift periodic check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "5min";
      AccuracySec = "30s";
      Persistent = false;
    };
  };

  networking.networkmanager.dispatcherScripts = [
    {
      type = "pre-down";
      source = pkgs.writeShellScript "lg-buddy-lifecycle" ''
        set -eu

        if [ "''${2:-}" != "pre-down" ]; then
          exit 0
        fi

        if [ ! -r ${lib.escapeShellArg configFile} ]; then
          exit 0
        fi

        export LG_BUDDY_BSCPYLGTV_KEY_FILE=${lib.escapeShellArg keyFile}
        export LG_BUDDY_BSCPYLGTV_OWNER_USER=${lib.escapeShellArg config.user}
        export LG_BUDDY_CONFIG=${lib.escapeShellArg configFile}

        exec ${pkgs.lg-buddy}/bin/lg-buddy nm-pre-down
      '';
    }
    {
      type = "basic";
      source = pkgs.writeShellScript "lg-buddy-mac-sync-dispatch" ''
        if [ "''${2:-}" != "up" ]; then
          exit 0
        fi

        [ -r ${lib.escapeShellArg configFile} ] || exit 0

        systemctl start lg-buddy-mac-sync.service || true
      '';
    }
  ];
}
