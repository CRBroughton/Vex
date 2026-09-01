# Placeholder hardware config - replace with output of:
#   nixos-generate-config --root /mnt --show-hardware-config
_:

{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
