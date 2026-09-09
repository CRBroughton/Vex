# Vex

> [!CAUTION]
> Vex is a work in progress. I'm building it slowly and publicly, expect rough edges, missing modules, and breaking changes.

Vex is an opinionated declarative developer environment and NixOS distro. Opinionated by default, extensible by design.

Vex comes in two flavours:

- **Vex** - a declarative developer environment that works on any system running Nix, Works on macOS, Ubuntu, NixOS. Manages your shell, tools, language runtimes, and dotfiles via Home Manager.
- **VexOS** - everything in Vex, plus full NixOS system management. Desktop environment, services, hardware, secrets, and fleet management. 


## Getting Started

Vex is a library, you consume it from your own configuration repository rather than cloning it directly.

### Vex (Home Manager)

Works on macOS, Ubuntu, NixOS, or any system with Nix installed.

Create a `flake.nix` in your config repository:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    vex = {
      url = "github:CRBroughton/vex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { vex, self, ... }@inputs:
  {
    homeConfigurations."craig" = vex.lib.mkUser {
      inherit self;
      user = "craig";
      system = "aarch64-darwin"; # or x86_64-linux
      stateVersion = "25.05";
    };
  };
}
```

`self` lets Vex resolve `users/craig` against *your* repository rather than Vex's own — always pass it.

Create `users/craig/default.nix`:

```nix
{ ... }:
{
  home.username = "craig";
  home.homeDirectory = "/home/craig";

  vex.shell.enable = true;

  vex.git = {
    userName = "Craig Broughton";
    userEmail = "craig@example.com";
    ignores = [ ".DS_Store" ".local/" ];
  };
}
```

Apply:

```bash
home-manager switch --flake .#craig
```

---

### VexOS (NixOS)

Full system management for NixOS machines.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    vex = {
      url = "github:CRBroughton/vex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { vex, self, ... }@inputs:
  {
    nixosConfigurations.my-machine = vex.osLib.mkHost {
      inherit self;
      hostname = "my-machine";
      users = [ "craig" ];
      stateVersion = "25.05";
    };
  };
}
```

`self` lets Vex resolve `hosts/my-machine` and `users/craig` against *your* repository rather than Vex's own — always pass it.

Create `hosts/my-machine/default.nix`:

```nix
{ ... }:
{
  imports = [ ./hardware.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "my-machine";
}
```

`hosts/my-machine/hardware.nix` is generated for you by `nixos-generate-config` (see [Deploying a New Machine](#deploying-a-new-machine) below).

Vex splits each user into two files: a NixOS-level `common.nix` for the system account, and a home-manager `default.nix` for the user's environment.

Create `users/craig/common.nix`:

```nix
{ config, pkgs, ... }:
{
  users.users.craig = {
    isNormalUser = true;
    home = "/home/craig";
    shell = pkgs.fish; # a package, not a string — required for /etc/shells registration
    hashedPasswordFile = config.age.secrets.craig-password.path;
  };

  age.secrets.craig-password = {
    file = ../../secrets/craig-password.age;
  };
}
```

Create `users/craig/default.nix`:

```nix
{ ... }:
{
  home.username = "craig";
  home.homeDirectory = "/home/craig";
  home.stateVersion = "25.05";

  vex.shell.enable = true;

  vex.git = {
    userName = "Craig Broughton";
    userEmail = "craig@example.com";
    signing.enable = true;
  };
}
```

Apply:

```bash
nixos-rebuild switch --flake .#my-machine
```

---

## Modules

Vex uses a layered module system. Modules are opt-in unless marked as default.

### Shell (`vex.shell`)

Fish shell with Starship prompt, Zoxide, and a curated set of CLI tools.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `vex.shell.enable` | bool | `true` | Enable the Vex shell. Set to `false` to manage your own. |

Included tools: `bat`, `eza`, `btop`, `ripgrep`, `fd`, `carapace`, `just`, `direnv`

To opt out:

```nix
vex.shell.enable = false;
```

To extend:

```nix
programs.fish.shellAliases = {
  g = "git";
  k = "kubectl";
};
```

---

### Git (`vex.git`)

Git, SSH, and commit signing configuration.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `vex.git.enable` | bool | `true` | Enable Vex git configuration. |
| `vex.git.userName` | string | — | Git commit author name. |
| `vex.git.userEmail` | string | — | Git commit author email. |
| `vex.git.ignores` | list | `[]` | Global gitignore patterns. |
| `vex.git.identityFile` | string | `~/.ssh/id_ed25519` | SSH identity file path. |
| `vex.git.signing.enable` | bool | `false` | Enable SSH commit signing. |
| `vex.git.signing.key` | string | `~/.ssh/id_ed25519` | SSH signing key path. |

Example:

```nix
vex.git = {
  userName = "Craig Broughton";
  userEmail = "craig@example.com";
  ignores = [ ".local/" ".DS_Store" ];
  signing = {
    enable = true;
    key = "~/.ssh/id_ed25519";
  };
};
```

---

### Devenv (`vex.devenv`)

Installs [devenv](https://devenv.sh) for declarative, per-project development environments — separate from your system-level Vex config, scoped to whatever repo you're in.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `vex.devenv.enable` | bool | `true` | Install devenv. |

See [Templates](#templates) below for ready-made devenv projects.

---

### Neovim (`vex.neovim`)

Neovim configured via [nvf](https://github.com/notashelf/nvf) — LSP, completion (nvim-cmp), fuzzy-find (telescope), file tree (neo-tree), statusline (lualine), and the gruvbox theme, with Nix language support (LSP + treesitter) on by default since you're likely editing a Vex-based config in it.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `vex.neovim.enable` | bool | `false` | Enable Neovim via nvf. |

nvf exposes its full option surface as `programs.nvf.settings` — nothing is hidden. Extend it directly for more languages, plugins, or to override any default:

```nix
vex.neovim.enable = true;

programs.nvf.settings.vim.languages = {
  go.enable = true;
  typescript.enable = true; # also covers JS, via ts_ls
};
```

---

### AI Assistant (`vex.ai`)

A local AI coding assistant: [Pi](https://pi.dev) configured against a locally-running [Ollama](https://ollama.com) model. Split across both flavours — the system side runs the Ollama service, the home side installs and configures Pi.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `vex.ai.enable` | bool | `false` | Enable (system: Ollama service; home: Pi + skills). |
| `vex.ai.model` | string | `"qwen2.5-coder:7b"` | Ollama model to load/use. Keep the system and home values in sync. |
| `vex.ai.port` | port | `11434` | Port the local Ollama service listens on. |

VexOS hosts need both halves enabled — Ollama on the system, Pi on the user:

```nix
# hosts/my-machine/default.nix
vex.ai.enable = true;

# users/craig/default.nix
vex.ai.enable = true;
```

---

### Desktop (`vex.desktop`) — VexOS only

A niri-based desktop session: [niri](https://github.com/YaLTeR/niri) (scrollable-tiling Wayland compositor) plus [noctalia](https://github.com/noctalia-dev/noctalia) (bar, launcher, control center, lock screen, wallpaper theming). `vex.desktop.enable` turns both on together, at both the system and home level.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `vex.desktop.enable` | bool | `false` | Enable niri + noctalia together. |
| `vex.desktop.niri.enable` | bool | `false` | Niri alone (compositor, keybinds, greetd/tuigreet login). |
| `vex.desktop.noctalia.enable` | bool | `false` | Noctalia alone (bar, launcher, wallpaper, a built-in `Mod+Slash` keybind cheatsheet shipped as a noctalia plugin). |

The individual toggles still exist if you want niri without noctalia (or vice versa), but the wallpaper and a couple of niri's own defaults (window rounding, focus-ring color auto-derived from the wallpaper) currently assume both are on together.

```nix
# hosts/my-machine/default.nix (system)
vex.desktop.enable = true;

# users/craig/default.nix (home)
vex.desktop.enable = true;
```

---

### Auto-Upgrade (`vex.autoUpgrade`) — VexOS only

Scheduled, unattended `nixos-rebuild` upgrades from your own config repo.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `vex.autoUpgrade.enable` | bool | `false` | Enable scheduled upgrades. |
| `vex.autoUpgrade.flake` | string | — | Your config repo's flake URL (not Vex's). Required. |
| `vex.autoUpgrade.schedule` | string | `"04:00"` | When to run, systemd calendar format. |
| `vex.autoUpgrade.allowReboot` | bool | `false` | Reboot automatically after kernel updates. |
| `vex.autoUpgrade.flags` | list | `[]` | Extra flags passed to `nixos-rebuild`. |
| `vex.autoUpgrade.rebootWindow.lower` / `.upper` | string | `"03:00"` / `"05:00"` | Permitted reboot window, when `allowReboot` is set. |

```nix
vex.autoUpgrade = {
  enable = true;
  flake = "github:yourorg/your-config";
  allowReboot = false;
};
```

---

## Templates

Vex ships ready-made [devenv](https://devenv.sh)-based project templates, independent of the OS/home-manager side — use them for a project's dev environment regardless of whether that project has anything to do with Vex.

```bash
nix flake init -t github:CRBroughton/vex#typescript   # pnpm workspace, catalog-pinned
nix flake init -t github:CRBroughton/vex#go
```

Both drop a `devenv.nix`, `devenv.yaml`, `devenv.lock` (locked, so builds are reproducible out of the box), `.envrc`, and `justfile` into the current directory. Enter the environment with `devenv shell` or `direnv allow`.

---

## Repository Structure

A typical Vex consumer repository looks like this:

```
my-config/
├── flake.nix
├── hosts/
│   └── my-machine/
│       ├── default.nix
│       └── hardware.nix
├── users/
│   └── craig/
│       ├── common.nix    # NixOS system account (VexOS only)
│       └── default.nix   # home-manager profile
├── modules/          # Your own custom modules
└── secrets/          # agenix encrypted secrets
    └── secrets.nix
```

---

## Trying It Without Installing

Want to see Vex running on real hardware (real GPU, real EGL — no VM software-rendering caveats) without touching your disk? Two options:

### Option 1: Live-rebuild from the official NixOS minimal ISO

Boot the [official NixOS minimal ISO](https://nixos.org/download) from USB. It runs entirely from RAM — nothing is written to disk unless you deliberately partition/install. Once you have network in the live session:

```bash
sudo nixos-rebuild test --flake github:yourorg/your-config#my-machine
```

This activates your Vex config live on the running (RAM-only) system. Use `test`, not `switch` — `switch` also installs the bootloader, which fails on the live ISO's read-only/non-existent EFI partition. `test` skips that step entirely. Reboot and it's gone, as if it never happened.

Working example against this repo's playground (the `demo` host):

```bash
sudo nixos-rebuild test --flake github:CRBroughton/vex?dir=playground#demo
```

### Option 2: Build your own bootable Vex ISO

This bakes your config directly into a bootable image, so it boots straight into it — no live-rebuild step needed. Still installs nothing; still boots from USB.

```bash
# Build the ISO (via the playground's `iso` host — see playground/hosts/iso/)
just build-iso

# Test it locally in QEMU before flashing to a USB stick
just run-iso

# Flash to USB (replace /dev/sdX with your actual device — this is destructive)
sudo dd if=playground/result/iso/vex.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

To build an ISO for your own config rather than the playground, add a host that imports `"${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"` (see `playground/hosts/iso/default.nix` for a working example) and build `.config.system.build.isoImage`.

---

## Deploying a New Machine

### Local deploy (from the NixOS minimal ISO)

```bash
nix-shell -p git
git clone https://github.com/yourorg/your-config
cd your-config

nix run github:nix-community/nixos-anywhere -- \
  --flake .#my-machine \
  --target-host root@localhost \
  --generate-hardware-config nixos-generate-config ./hosts/my-machine/hardware.nix
```

### Remote deploy (from your machine)

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#my-machine \
  root@192.168.1.100
```

---

## Secrets Management

Vex uses [agenix](https://github.com/ryantm/agenix) for secrets management. Secrets are encrypted with SSH keys and decrypted at activation time.

```nix
# secrets/secrets.nix
let
  my-machine = "ssh-ed25519 AAAA... root@my-machine";
  craig = "ssh-ed25519 AAAA... craig@my-machine";
in
{
  "craig-password.age".publicKeys = [ my-machine craig ];
}
```

Encrypt a secret:

```bash
cd secrets
nix run github:ryantm/agenix -- -e craig-password.age
```

---

## Playground

The `playground/` directory is a self-contained consumer of Vex for development testing. It points at the local Vex source via `url = "path:../"` so changes can be tested immediately without pushing to GitHub.

```bash
# Build and run the test VM
just vm

# Test Vex Home build
just test-home

# Test VexOS build
just test-os

# Build a bootable ISO of the playground config
just build-iso
```

---

## Escape Hatches

Vex is opinionated but not a cage. At every level you can opt out or extend:

```nix
# Disable a default module
vex.shell.enable = false;

# Add your own packages
home.packages = with pkgs; [ steam discord ];

# Bring your own modules
home-manager.users.craig.imports = [ ./my-custom-module.nix ];
```

## Licence

MIT