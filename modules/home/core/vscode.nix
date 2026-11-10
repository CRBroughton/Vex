{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.vex.vscode;

  darwinApps = import ../../../lib/home/darwin-apps.nix { inherit lib; };

  # nixpkgs' darwin postPatch for vscode >= 1.94.0 hardcodes the bundled
  # ripgrep's path (node_modules/@vscode/ripgrep/bin/rg) and chmod +x's it
  # (runs as part of the standard patchPhase, hence that log name). Upstream
  # VS Code 1.144.0 renamed and relocated it to
  # node_modules.asar.unpacked/@vscode/ripgrep-universal/bin/<arch>/rg —
  # useVSCodeRipgrep doesn't help, both its branches reference the same
  # stale path. Only darwin is affected (Linux's path in that same nixpkgs
  # variable never changed), so only patch there.
  defaultPackage =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.vscode.overrideAttrs (
        old:
        {
          postPatch = builtins.replaceStrings
            [ "Contents/Resources/app/node_modules/@vscode/ripgrep/bin/rg" ]
            [
              "Contents/Resources/app/node_modules.asar.unpacked/@vscode/ripgrep-universal/bin/${
                {
                  aarch64-darwin = "darwin-arm64";
                  x86_64-darwin = "darwin-x64";
                }
                .${pkgs.stdenv.hostPlatform.system}
              }/rg"
            ]
            old.postPatch;
        }
      )
    else
      pkgs.vscode;
in
{
  options.vex.vscode = {
    enable = lib.mkEnableOption "VS Code, with declarative extensions and settings";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "The vscode package to use. Defaults to a darwin-ripgrep-patched vscode on darwin, plain vscode elsewhere.";
    };

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra marketplace extensions, on top of Vex's own curated defaults. Source from pkgs.vscode-marketplace.<publisher>.<name> (overlay applied by mk-user.nix).";
    };

    userSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra VS Code user settings, merged over Vex's own defaults.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = cfg.package;

      profiles.default = {
        # Nix language support, since you're likely editing a Vex-based
        # config in it — same rationale as vex.neovim's default languages.
        extensions = (with pkgs.vscode-marketplace; [ jnoortheen.nix-ide ]) ++ cfg.extensions;

        userSettings = {
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nixd";
        } // cfg.userSettings;
      };
    };

    home.file = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (
      darwinApps [
        {
          package = cfg.package;
          name = "Visual Studio Code.app";
        }
      ]
    );
  };
}
