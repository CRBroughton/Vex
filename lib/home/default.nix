{
  inputs,
  import-tree,
  optionalImportTree,
  ...
}:
{
  mkUser = import ./mk-user.nix { inherit inputs import-tree optionalImportTree; };
}
