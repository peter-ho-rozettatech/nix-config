{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.programs.playwriter = {
    enable = lib.mkEnableOption "playwriter browser automation";
  };

  config = lib.mkIf config.programs.playwriter.enable {
    home.packages = [ pkgs.playwriter ];
    programs.ai.mcp.playwriter = {
      command = "playwriter";
      args = [ ];
      disabled = false;
    };
    programs.ai.skills.playwriter.source = "${pkgs.playwriter}/share/playwriter/skills/playwriter";
  };
}
