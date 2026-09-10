{ pkgs, ... }:

let
  templates = {
    typescript = ../templates/typescript;
    go = ../templates/go;
  };

  # `${templates.typescript}` etc. bake the real store paths in at build
  # time, so `vex new` works fully offline — no network fetch, no `nix
  # flake init` registry resolution at runtime.
  templateCase = pkgs.lib.concatMapStringsSep "\n" (name: ''
    ${name})
      template_src="${templates.${name}}"
      ;;
  '') (builtins.attrNames templates);
in
pkgs.writeShellApplication {
  name = "vex";
  runtimeInputs = with pkgs; [
    gnused
    coreutils
  ];
  text = ''
    usage() {
      echo "vex — an opinionated, declarative developer environment"
      echo ""
      echo "Usage: vex new <template> [directory]"
      echo "  Templates: ${builtins.concatStringsSep ", " (builtins.attrNames templates)}"
    }

    cmd_new() {
      local template="''${1:-}"
      local dir="''${2:-.}"

      if [ -z "$template" ]; then
        echo "error: missing template name" >&2
        usage
        exit 1
      fi

      local template_src=""
      case "$template" in
      ${templateCase}
      *)
        echo "error: unknown template '$template'" >&2
        usage
        exit 1
        ;;
      esac

      mkdir -p "$dir"
      cp -rT "$template_src" "$dir"
      chmod -R u+w "$dir"

      local devenv_nix="$dir/devenv.nix"
      if [ ! -f "$devenv_nix" ]; then
        echo "warning: $devenv_nix not found, skipping interactive setup" >&2
        echo "vex: wrote '$template' template to $dir"
        return
      fi

      echo ""
      echo "Setting up $template project in $dir"
      echo ""

      local want_postgres want_redis want_precommit
      read -rp "Do you need a database (postgres)? [y/N] " want_postgres
      read -rp "Do you need Redis? [y/N] " want_redis
      read -rp "Do you want pre-commit hooks? [Y/n] " want_precommit

      if [[ "$want_precommit" =~ ^[Nn] ]]; then
        sed -i '/# VEX:PRECOMMIT-START/,/# VEX:PRECOMMIT-END/d' "$devenv_nix"
      else
        sed -i '/# VEX:PRECOMMIT-START/d; /# VEX:PRECOMMIT-END/d' "$devenv_nix"
      fi

      if [[ "$want_postgres" =~ ^[Yy] ]]; then
        sed -i '/# VEX:EXTRA-SERVICES/a\  services.postgres.enable = true;' "$devenv_nix"
      fi

      if [[ "$want_redis" =~ ^[Yy] ]]; then
        sed -i '/# VEX:EXTRA-SERVICES/a\  services.redis.enable = true;' "$devenv_nix"
      fi

      sed -i '/# VEX:EXTRA-SERVICES/d' "$devenv_nix"

      echo ""
      echo "vex: wrote '$template' template to $dir"
      echo "vex: run 'devenv shell' (or 'devenv allow' for auto-activation) inside $dir to get started"
    }

    case "''${1:-}" in
    new)
      shift
      cmd_new "$@"
      ;;
    *)
      usage
      ;;
    esac
  '';
}
