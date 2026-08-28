{
  inputs,
  optionalImportTree,
  ...
}:

{
  user,
  system ? "x86_64-linux",
  stateVersion ? "25.05",
  externalModules ? [ ],
}:

inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  modules =
    (optionalImportTree ../modules/home/core)
    ++ [ ../users/${user} ]
    ++ (optionalImportTree ../users/${user}/modules)
    ++ [ { home.stateVersion = stateVersion; } ]
    ++ externalModules;
  extraSpecialArgs = {
    inherit inputs;
  };
}
