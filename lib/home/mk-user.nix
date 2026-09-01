{
  inputs,
  optionalImportTree,
  ...
}:

{
  user,
  self ? null,
  system ? "x86_64-linux",
  stateVersion ? "25.05",
  usersDir ? (if self == null then ../../users else self + "/users"),
  externalModules ? [ ],
}:

inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  modules =
    (optionalImportTree ../../modules/home/core)
    ++ (optionalImportTree ../../modules/home/desktop)
    ++ (optionalImportTree ../../modules/home/ai)
    ++ [ (usersDir + "/${user}") ]
    ++ (optionalImportTree (usersDir + "/${user}/modules"))
    ++ [ { home.stateVersion = stateVersion; } ]
    ++ externalModules;
  extraSpecialArgs = {
    inherit inputs;
  };
}
