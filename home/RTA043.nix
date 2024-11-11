{ config, ... }:
{
  imports = [
    ./darwin.nix
  ];

  home = {
    file = {
      "iCloud".source = config.lib.file.mkOutOfStoreSymlink (
        config.home.homeDirectory + "/Library/Mobile Documents/com~apple~CloudDocs"
      );
      ".config/git/.gitconfig".source = config.lib.meta.mkDotfilesSymlink "git/.config/git/.gitconfig";
    };
    sessionVariables = {
      COPILOT_MODEL = "gemini-2.5-pro";
      SCRATCH_PATH = "~/iCloud/Documents";
    };
  };
}
