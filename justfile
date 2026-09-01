# List available commands
default:
    @just --list

# Build the test VM (via the playground, a real external consumer of vex)
build-vm:
    cd playground && nix build '.#nixosConfigurations.test.config.system.build.vm'

# Run the test VM
run-vm:
    cd playground && ./result/bin/run-test-vm

# Build and run the test VM
vm:
    just build-vm
    just run-vm

# Build a specific host VM in the playground
vm-host host:
    cd playground && nix build ".#nixosConfigurations.{{host}}.config.system.build.vm"
    cd playground && ./result/bin/run-{{host}}-vm

# Build a bootable Vex ISO (boots into the config directly, installs nothing)
build-iso:
    cd playground && nix build '.#nixosConfigurations.iso.config.system.build.isoImage'

# Boot the built ISO in a local QEMU VM, to test it before flashing to USB
run-iso:
    qemu-system-x86_64 -m 4096 -enable-kvm -cdrom playground/result/iso/vex.iso

# Check flake for errors
check:
    nix flake check

# Build the Vex Home activation package (proves mkUser evaluates/builds)
test-home:
    cd playground && nix build '.#homeConfigurations.test.activationPackage'

# Build the VexOS system, evaluation only (proves mkHost evaluates)
test-os:
    cd playground && nix build '.#nixosConfigurations.test.config.system.build.toplevel' --dry-run

# Format all Nix files
fmt:
    nix shell nixpkgs#nixfmt --command find . -name '*.nix' -exec nixfmt {} +

# Lint all Nix files, auto-fixing what statix can
lint:
    nix shell nixpkgs#statix --command statix fix .

# Find and remove dead Nix code
dead:
    nix shell nixpkgs#deadnix --command deadnix --edit .

# Verify formatting without writing changes (CI-safe)
fmt-check:
    nix shell nixpkgs#nixfmt --command find . -name '*.nix' -exec nixfmt --check {} +

# Verify lint without writing changes (CI-safe)
lint-check:
    nix shell nixpkgs#statix --command statix check .

# Verify no dead code without writing changes (CI-safe)
dead-check:
    nix shell nixpkgs#deadnix --command deadnix --fail .

# Run all checks, auto-fixing along the way (local use)
ci:
    just fmt
    just lint
    just dead
    just check
    just test-home
    just test-os

# Run all checks without modifying files (use in CI pipelines)
ci-check:
    just fmt-check
    just lint-check
    just dead-check
    just check
    just test-home
    just test-os

# Update flake inputs
update:
    nix flake update

# Show flake outputs
show:
    nix flake show