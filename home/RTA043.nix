{
  config,
  pkgs,
  ...
}:
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
      COPILOT_MODEL = "claude-sonnet-4";
      SCRATCH_PATH = "~/iCloud/Documents";
    };
    packages = with pkgs; [
      awscli2
      ngrok
      terraform
      # terragrunt
    ];
  };
}
