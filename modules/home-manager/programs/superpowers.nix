{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.superpowers = {
    enable = lib.mkEnableOption "superpowers skills";
  };

  config = lib.mkIf config.programs.superpowers.enable {
    programs.ai.skills.superpowers = {
      source = "${pkgs.superpowers}/share/superpowers/skills";
      clients = {
        opencode.files."opencode/plugins/superpowers.js".source =
          "${pkgs.superpowers}/share/superpowers/.opencode/plugins/superpowers.js";
        "claude-code" = {
          enable = false;
          pluginPaths = [
            "${pkgs.superpowers}/share/superpowers"
          ];
        };
      };
    };
  };
}
