{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.jscpd;
  jscpd = pkgs.llm-agents.jscpd;
  skillsDir = "${jscpd.src}/skills";
  availableSkills = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir)
  );
  selectedSkills = builtins.listToAttrs (
    map (name: lib.nameValuePair name "${skillsDir}/${name}") availableSkills
  );
in
{
  options.programs.jscpd = {
    enable = lib.mkEnableOption "jscpd copy-paste detector and skills";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ jscpd ];
    programs.ai.skills = lib.mapAttrs (_: source: { inherit source; }) selectedSkills;
  };
}
