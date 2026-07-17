{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hallmark;
in
{
  options.programs.hallmark.enable = lib.mkEnableOption "hallmark anti-AI-slop design skill";

  config = lib.mkIf cfg.enable {
    programs.ai.skills.hallmark.source = "${pkgs.hallmark}/share/hallmark/skills/hallmark";
  };
}
