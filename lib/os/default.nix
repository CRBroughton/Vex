{ inputs, import-tree, optionalImportTree, ... }:
{
  mkHost = import ./mk-host.nix { inherit inputs import-tree optionalImportTree; };
}
