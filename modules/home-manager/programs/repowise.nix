{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.repowise;
in
{
  options.programs.repowise = {
    enable = lib.mkEnableOption "repowise codebase intelligence";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.repowise ];

    # repowise ships opt-out anonymous usage telemetry. DO_NOT_TRACK is the
    # standard opt-out it (and other tools) respect, so set it globally while
    # repowise is enabled.
    home.sessionVariables.DO_NOT_TRACK = "1";
  };
}
