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
      terragrunt
    ];
  };
  programs.claude-code = {
    enable = lib.mkForce true;
    mcpServers.grafana = {
      type = "http";
      url = "https://mcp.grafana.com/mcp";
      headers."X-Grafana-URL" = "\${GRAFANA_URL}";
    };
  };
  # Aikido Endpoint Protection re-signs registry and GitHub TLS. Every few
  # minutes it checks config.fish for these CA blocks and tries to append them,
  # which fails on the store-linked file. The file is Aikido's output verbatim,
  # and its check accepts it through the symlink. If Aikido changes the blocks,
  # its log shows "trust configuration failed" for fish again.
  programs.fish.shellInitLast = builtins.readFile ./RTA043-aikido.fish;
  programs.fish.shellAbbrs = {
    j = "jira";
    jim = "jira issue list -a(jira me)";
    jsl = "jira sprint list";
    jslc = "jira sprint list --current";
    jsm = "jira sprint list --current -a(jira me)";
    ju = "jiratui ui";
  };
}
