---
name: vex-list-modules
description: List all available vex.* modules/options in this Vex repo, and which ones are currently enabled for the user's config. Use when the user asks "what modules do I have" or "what's available" or "what's enabled".
---

# List Vex modules

Vex modules are auto-discovered directory trees, each file defining one or
more `options.vex.*` blocks:

- `modules/system/core/` — always-on NixOS system modules
- `modules/system/services/` — opt-in NixOS services (e.g. `vex.autoUpgrade`, `vex.ai`)
- `modules/system/desktop/` — opt-in desktop sessions (e.g. `vex.desktop.niri`)
- `modules/home/core/` — always-on home-manager modules (e.g. `vex.shell`, `vex.git`, `vex.devenv`)
- `modules/home/desktop/` — home-manager side of desktop sessions
- `modules/home/ai/` — this module

To list what's **available**: grep every `.nix` file under `modules/` for
`options.vex.` and report the option namespace plus its one-line
description.

To list what's **enabled** for the current user: read their config file
(e.g. `users/<name>/default.nix`, `hosts/<name>/default.nix`, or in this
repo's own playground, `playground/users/test/default.nix` and
`playground/hosts/test/default.nix`) and report which `vex.*` options are
explicitly set, noting that modules under `*/core` are enabled by default
(`enable = true` by default) even if not explicitly set.
