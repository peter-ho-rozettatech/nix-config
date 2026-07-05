```
███╗   ██╗██╗██╗  ██╗      ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
████╗  ██║██║╚██╗██╔╝     ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
██╔██╗ ██║██║ ╚███╔╝█████╗██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
██║╚██╗██║██║ ██╔██╗╚════╝██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
██║ ╚████║██║██╔╝ ██╗     ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝      ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝
```

Personal Nix configuration for macOS, Linux (Debian-based), and NixOS systems.

## Quick Start

Bootstrap the configuration on a fresh system:

```bash
curl -fsSL https://raw.githubusercontent.com/petertriho/nix-config/main/scripts/bootstrap | bash
```

Bootstrap selects an activation target from the host registry. It uses the
current hostname first, prompts when multiple compatible targets are possible,
and also accepts an explicit host when needed:

```bash
curl -fsSL https://raw.githubusercontent.com/petertriho/nix-config/main/scripts/bootstrap | bash -s -- --host T480
```
