{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../profiles/darwin.nix
  ];

  home = {
    file = {
      "iCloud".source = config.lib.file.mkOutOfStoreSymlink (
        config.home.homeDirectory + "/Library/Mobile Documents/com~apple~CloudDocs"
      );
      ".config/git/.gitconfig".source = config.lib.meta.mkDotfilesSymlink "git/.config/git/.gitconfig";
      ".ideavimrc".source = config.lib.meta.mkDotfilesSymlink "jetbrains/.ideavimrc";
    };
    sessionVariables = {
      # COPILOT_MODEL = "gpt-5-mini";
      SCRATCH_PATH = "~/iCloud/Documents";
      SNACKS_HEADER = "ROZETTA";
    };
    packages = with pkgs; [
      awscli2
      jira-cli-go
      # jiratui
      # lima
      terraform
      # terragrunt
    ];
  };
  programs.fish.shellAbbrs = {
    j = "jira";
    jim = "jira issue list -a(jira me)";
    jsl = "jira sprint list";
    jslc = "jira sprint list --current";
    jsm = "jira sprint list --current -a(jira me)";
    ju = "jiratui ui";
  };
}
