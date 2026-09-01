{ modulesPath, ... }:
{
  imports = [
    ./hardware.nix
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "demo";

  vex.desktop.niri.enable = true;

  # NixOS's qemu-vm module attaches no GPU device by default, so the guest
  # has no /dev/dri and wlroots has nothing to get a DRM/KMS or EGL context
  # from. Attach a GL-accelerated virtio-gpu device (virgl) so niri gets
  # real GPU acceleration rather than falling back to software rendering.
  # Use the sdl display frontend, not gtk: gtk's key grab doesn't reliably
  # capture Super/Meta, breaking niri's SUPER-based keybinds.
  hardware.graphics.enable = true;
  virtualisation.qemu.options = [
    "-vga none"
    "-device virtio-gpu-gl-pci"
    "-display sdl,gl=on"
  ];

  vex.ai.enable = true;

  vex.autoUpgrade = {
    enable = true;
    flake = "github:acmecorp/acme-vex";
    allowReboot = false;
  };

  virtualisation = {
    diskSize = 8192;
    memorySize = 4096;
    cores = 2;
  };
}
