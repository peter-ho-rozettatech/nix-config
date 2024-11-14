{ config, ... }:
{
  imports = [
    ./darwin.nix
  ];

  home.file."iCloud".source = config.lib.file.mkOutOfStoreSymlink (
    config.home.homeDirectory + "/Library/Mobile Documents/com~apple~CloudDocs"
  );
}
