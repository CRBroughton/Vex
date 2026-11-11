{ lib }:
# [ { package = pkgs.obsidian; name = "Obsidian.app"; } ... ] -> home.file attrs
#
# Nixpkgs' darwin builds put the .app bundle inside the store output, but
# nothing registers it anywhere macOS looks (Spotlight, Dock, dockutil)
# unless it's symlinked into ~/Applications.
apps:
lib.listToAttrs (
  map (
    a: lib.nameValuePair "Applications/${a.name}" { source = "${a.package}/Applications/${a.name}"; }
  ) apps
)
