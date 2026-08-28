{ config, lib, ... }:

let
  cfg = config.vex.git;
in
{
  options.vex.git = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Vex git configuration.";
    };

    userName = lib.mkOption {
      type = lib.types.str;
      description = "Git commit author name.";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "Git commit author email.";
    };

    ignores = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Global git ignore patterns.";
    };

    identityFile = lib.mkOption {
      type = lib.types.str;
      default = "~/.ssh/id_ed25519";
      description = "Path to the SSH identity file.";
    };

    signing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable commit signing via SSH key.";
      };

      key = lib.mkOption {
        type = lib.types.str;
        default = "~/.ssh/id_ed25519";
        description = "Path to the SSH signing key.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      ignores = cfg.ignores;
      signing = lib.mkIf cfg.signing.enable {
        key = cfg.signing.key;
        signByDefault = true;
      };
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        gpg.format = lib.mkIf cfg.signing.enable "ssh";
      };
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*".identityFile = cfg.identityFile;
    };

    services.ssh-agent.enable = true;
  };
}
