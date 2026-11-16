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

let
  inherit (inputs.nixpkgs) lib;
  # modules/home/desktop is Wayland-only (niri, noctalia) — importing it
  # on Darwin isn't just dead weight, it's a real hazard: both modules
  # import their upstream home-manager module unconditionally, regardless
  # of any enable flag, so a version mismatch or an upstream bug there
  # (e.g. noctalia's module currently double-declares `checkConfig`) can
  # break a Mac config that will never use either.
  isLinux = lib.hasSuffix "linux" system;
in
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [ inputs.nix-vscode-extensions.overlays.default ];
  };
  modules =
    (optionalImportTree ../../modules/home/core)
    ++ (lib.optionals isLinux (optionalImportTree ../../modules/home/desktop))
    ++ (optionalImportTree ../../modules/home/ai)
    ++ [ (usersDir + "/${user}") ]
    ++ (optionalImportTree (usersDir + "/${user}/modules"))
    ++ [ { home.stateVersion = stateVersion; } ]
    ++ externalModules;
  extraSpecialArgs = {
    inherit inputs;
  };
}
