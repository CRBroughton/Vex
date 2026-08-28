{ inputs, import-tree, ... }:

let
  optionalImportTree = path: if builtins.pathExists path then [ (import-tree path) ] else [ ];
in
{
  mkUser = import ./mk-user.nix { inherit inputs import-tree optionalImportTree; };
  mkHost = import ./mk-host.nix { inherit inputs import-tree optionalImportTree; };
}
