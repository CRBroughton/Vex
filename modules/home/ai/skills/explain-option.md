---
name: vex-explain-option
description: Explain what a vex.* option does, where it's defined, and what it configures. Use when the user asks what a specific vex.* option (e.g. vex.shell.enable, vex.desktop.niri.enable) does or is for.
---

# Explain a Vex option

Vex options all live under the `vex.*` namespace and are defined as NixOS or
home-manager modules under `modules/system/` and `modules/home/`, each in
its own `*/core`, `*/services`, or `*/desktop` subdirectory.

To explain an option:

1. Grep the `modules/` tree for the option's namespace, e.g. for
   `vex.desktop.niri.enable`, search for `vex.desktop.niri` across
   `modules/system/desktop/*.nix` and `modules/home/desktop/*.nix` — Vex
   options are frequently defined twice (once per module system), since
   NixOS and home-manager don't share option state.
2. Read the `options.vex.*` block to get the option's type, default, and
   description.
3. Read the corresponding `config = lib.mkIf cfg.enable { ... }` block to
   explain what actually gets configured when it's turned on — this is
   often more informative than the option's one-line description.
4. Check whether the option is currently set in the user's own config
   (typically `users/<name>/default.nix` or `hosts/<name>/default.nix` for
   a real deployment, or `playground/users/test/default.nix` /
   `playground/hosts/test/default.nix` in this repo's own playground).

Report: what the option does, its type/default, and whether it's currently
enabled for this user/host.
