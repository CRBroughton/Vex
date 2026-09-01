{ modulesPath, lib, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  networking.hostName = "vex-iso";

  vex.desktop.niri.enable = true;

  image.baseName = lib.mkForce "vex";
}
