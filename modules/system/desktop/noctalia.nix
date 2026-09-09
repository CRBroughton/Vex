{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.vex.desktop.noctalia;
in
{
  imports = [ inputs.noctalia.nixosModules.default ];

  options.vex.desktop.noctalia = {
    enable = lib.mkEnableOption "system-level support for Noctalia (Bluetooth, UPower, power profiles)";
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia.recommendedServices.enable = true;
  };
}
