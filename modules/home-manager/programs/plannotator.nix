{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.plannotator = {
    enable = lib.mkEnableOption "plannotator opencode plugin";
  };

  config = lib.mkIf config.programs.plannotator.enable (
    lib.mkMerge [
      { home.packages = [ pkgs.plannotator ]; }
      {
        programs.ai.skills.plannotator-compound = {
          source = "${pkgs.plannotator}/share/plannotator/apps/skills/plannotator-compound";
          clients = {
            opencode = {
              pluginEntries = [ "@plannotator/opencode" ];
              files = lib.mapAttrs' (
                name: _:
                lib.nameValuePair "opencode/commands/${name}" {
                  source = "${pkgs.plannotator}/share/plannotator/apps/opencode-plugin/commands/${name}";
                }
              ) (builtins.readDir "${pkgs.plannotator}/share/plannotator/apps/opencode-plugin/commands");
            };
            "claude-code" = {
              enable = false;
              pluginPaths = [
                "${pkgs.plannotator}/share/plannotator/apps/hook"
              ];
            };
          };
        };
      }
      (lib.mkIf config.programs.opencode.enable {
        home.sessionVariables.PLANNOTATOR_ALLOW_SUBAGENTS = "1";
      })
    ]
  );
}
