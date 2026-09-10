{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.vex.cli;
in
{
  options.vex.cli = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the vex CLI (project scaffolding via `vex new <template>`).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.callPackage ../../../cli { inherit pkgs; }) ];
  };
}
