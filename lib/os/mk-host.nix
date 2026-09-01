{
  inputs,
  optionalImportTree,
  ...
}:

{
  hostname,
  self ? null,
  users ? [ ],
  hostsDir ? (if self == null then ../../hosts else self + "/hosts"),
  usersDir ? (if self == null then ../../users else self + "/users"),
  hostModule ? hostsDir + "/${hostname}",
  userModules ? map (user: usersDir + "/${user}/common.nix") users,
  system ? "x86_64-linux",
  stateVersion ? "25.05",
  externalModules ? [ ],
}:

let
  inherit (inputs.nixpkgs) lib;
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules =
    (optionalImportTree ../../modules/system/core)
    ++ (optionalImportTree ../../modules/system/services)
    ++ [ hostModule ]
    ++ userModules
    ++ [
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
      inputs.disko.nixosModules.disko
      {
        system.stateVersion = stateVersion;

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs;
          };
          sharedModules = optionalImportTree ../../modules/home/core;
          users = lib.genAttrs users (
            user:
            let
              hostHome = hostsDir + "/${hostname}/users/${user}/home.nix";
            in
            if builtins.pathExists hostHome then import hostHome else import (usersDir + "/${user}")
          );
        };
      }
    ]
    ++ externalModules;
  specialArgs = {
    inherit inputs;
  };
}
