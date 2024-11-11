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
      ".ideavimrc".source = config.lib.meta.mkDotfilesSymlink "jetbrains/.ideavimrc";
    };
    sessionVariables = {
      COPILOT_MODEL = "gpt-5-mini";
      SCRATCH_PATH = "~/iCloud/Documents";
    };
    packages = with pkgs; [
      awscli2
      jira-cli-go
      # jiratui
      lima
      terraform
      # terragrunt
    ];
  };
  programs.opencode.settings = {
    mcp = {
      atlassian.enabled = lib.mkForce true;
      # terraform.enabled = lib.mkForce true;
      # pencil = {
      #   type = "local";
      #   command = [
      #     "/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64"
      #     "--app"
      #     "desktop"
      #   ];
      #   enabled = true;
      # };
    };
    plugin = [
      "opencode-supermemory"
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
  xdg.configFile = {
    "opencode/supermemory.jsonc".source =
      config.lib.meta.mkDotfilesSymlink "opencode/.config/opencode/supermemory.jsonc";
    "opencode/commands/supermemory-init.md".source =
      config.lib.meta.mkDotfilesSymlink "opencode/.config/opencode/commands/supermemory-init.md";
    "opencode/commands/supermemory-login.md".source =
      config.lib.meta.mkDotfilesSymlink "opencode/.config/opencode/commands/supermemory-login.md";
  };
}
