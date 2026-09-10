{
  pkgs,
  wrappersLib,
  greeting ? "vex — Mod+/ for the cheatsheet (shortcuts, common commands)",
  extraPackages ? [ ],
  zellijThemeName ? "vitesse-dark",
  zellijThemeColors ? {
    fg = "#dbd7ca";
    bg = "#121212";
    black = "#121212";
    red = "#cb7676";
    green = "#4d9375";
    yellow = "#e6cc77";
    blue = "#6394bf";
    magenta = "#db889a";
    cyan = "#5eaab5";
    white = "#959da5";
    orange = "#d4976c";
  },
}:

let
  lib = pkgs.lib;
  wlib = wrappersLib;

  fishInit = pkgs.writeText "vex-fish-init.fish" ''
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
    set -gx PATH "$PNPM_HOME" $PATH

    set -g fish_greeting "${greeting}"

    alias cd z
    alias cat bat
    alias ls eza

    function just
      if test -f justfile; or test -f .justfile; or test -f Justfile
        command just $argv
      end
    end

    starship init fish | source
    zoxide init fish | source

    if status is-interactive
      and not set -q ZELLIJ
      # `zellij attach -c` with no name always attaches the most recent
      # session, so every new terminal joined the same one and mirrored
      # keystrokes across all of them. A name unique per fish process gives
      # each terminal its own session instead.
      zellij attach -c "term-$fish_pid"
    end
  '';

  commonRuntimeInputs =
    (with pkgs; [
      bat
      eza
      btop
      ripgrep
      fd
      jq
      jnv
      carapace
      just
      direnv
      starship
      zoxide
    ])
    ++ extraPackages;

  # A zellij-free fish, used only as zellij's own `default_shell` — panes
  # spawned inside zellij already have $ZELLIJ set, so fishInit's attach
  # block is skipped there and zellij never needs to be on this one's PATH.
  # This also avoids a circular dependency: the top-level vexFish (below)
  # bundles vexZellij, and vexZellij's config points at this shell instead
  # of back at vexFish.
  vexFishCore = wlib.wrapPackage {
    inherit pkgs;
    package = pkgs.fish;
    binName = "fish";
    runtimeInputs = commonRuntimeInputs;
    env.CGO_ENABLED = "1";
    flags."-C" = "source ${fishInit}";
  };

  zellijConfig = pkgs.writeText "vex-zellij-config.kdl" ''
    theme "${zellijThemeName}"
    default_shell "${vexFishCore}/bin/fish"
    editor "${pkgs.helix}/bin/hx"
    default_layout "compact"
    pane_frames false
    auto_attach true
    auto_close false

    themes {
      ${zellijThemeName} {
        ${lib.concatStringsSep "\n    " (
          lib.mapAttrsToList (name: value: ''${name} "${value}"'') zellijThemeColors
        )}
      }
    }
  '';

  vexZellij = wlib.wrapPackage {
    inherit pkgs;
    package = pkgs.zellij;
    binName = "zellij";
    flags."--config" = "${zellijConfig}";
  };

  vexFish = wlib.wrapPackage {
    inherit pkgs;
    package = pkgs.fish;
    binName = "fish";
    runtimeInputs = commonRuntimeInputs ++ [ vexZellij ];
    env.CGO_ENABLED = "1";
    flags."-C" = "source ${fishInit}";
  };
in
{
  inherit vexFish vexZellij;
}
