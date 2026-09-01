---
name: vex-debug-nix
description: Explain a Nix/NixOS/home-manager build error in plain English and suggest a fix, in the context of this Vex repo's structure. Use when the user pastes a `nix build`/`nixos-rebuild`/`home-manager switch` error.
---

# Debug a Nix error

Read the pasted error carefully and check it against these patterns
observed in this repo before speculating:

- **`The option 'vex.foo' does not exist`** — the option is being set in
  the wrong module system. Vex defines separate options for NixOS
  (`modules/system/...`) and home-manager (`modules/home/...`); a system
  option like `vex.autoUpgrade` cannot be set in a home-manager-only file,
  and vice versa. Check where the option is actually defined and where
  it's being set.
- **`Path '...' in the repository "..." is not tracked by Git`** — Nix
  flakes only see git-tracked files. Run `git add <path>` on the new file
  and retry.
- **`attribute 'X' missing`** referencing a flake input — the input was
  added to `flake.nix` but the consuming flake's lock file (e.g.
  `playground/flake.lock`) hasn't been updated to include it. Run
  `nix flake lock --update-input <consuming-input-name>` in that
  directory.
- **`error: infinite recursion encountered`** — usually a module setting
  `imports` conditionally inside a `config = lib.mkIf ...` block. `imports`
  must be a top-level, unconditional module attribute; put the actual
  enable/disable logic in `config`, not around the import.
- **Deprecated option renamed warnings** (e.g. `isoImage.isoBaseName` →
  `image.baseName`) — harmless but worth fixing at the point of definition
  rather than leaving as a standing warning.

If the error doesn't match a known pattern, read the actual failing
module/line referenced in the trace before guessing — don't assume the fix
without checking the real option/module definition first.
