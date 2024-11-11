{
  config,
  pkgs,
  lib,
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
      ".aws/amazonq/mcp.json".source = config.lib.meta.mkDotfilesSymlink "aws/.aws/amazonq/mcp.json";
    };
    sessionVariables = {
      COPILOT_MODEL = "gpt-5-mini";
      SCRATCH_PATH = "~/iCloud/Documents";
    };
    packages = with pkgs; [
      awscli2
      jiratui
      terraform
      # terragrunt
    ];
  };
  programs.opencode.settings = {
    mcp = {
      atlassian.enabled = lib.mkForce true;
      terraform.enabled = lib.mkForce true;
    };
  };
  programs.fish.shellAbbrs = {
    ji = "jiratui ui";
  };
}
