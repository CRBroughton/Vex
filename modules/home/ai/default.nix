{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.vex.ai;

  pi-coding-agent = pkgs.callPackage ../../../pkgs/pi-coding-agent { };

  settingsJson = pkgs.writeText "vex-pi-settings.json" (
    builtins.toJSON {
      defaultProvider = "ollama";
      defaultModel = cfg.model;
      defaultTools = [
        "bash"
        "read"
        "edit"
        "write"
      ];
    }
  );

  modelsJson = pkgs.writeText "vex-pi-models.json" (
    builtins.toJSON {
      providers.ollama = {
        baseUrl = "http://localhost:${toString cfg.port}/v1";
        api = "openai-completions";
        apiKey = "ollama";
        models = [ { id = cfg.model; } ];
      };
    }
  );
in
{
  options.vex.ai = {
    enable = lib.mkEnableOption "the Vex AI assistant (Pi, configured against a local Ollama model)";

    model = lib.mkOption {
      type = lib.types.str;
      default = "qwen2.5-coder:7b";
      description = "Ollama model Pi should use by default. Should match vex.ai.model on the system side.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      description = "Port the local Ollama service listens on. Should match vex.ai.port on the system side.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pi-coding-agent ];

    home.file.".pi/agent/settings.json".source = settingsJson;
    home.file.".pi/agent/models.json".source = modelsJson;

    home.file.".pi/agent/skills/vex-explain-option/SKILL.md".source = ./skills/explain-option.md;
    home.file.".pi/agent/skills/vex-list-modules/SKILL.md".source = ./skills/list-modules.md;
    home.file.".pi/agent/skills/vex-debug-nix/SKILL.md".source = ./skills/debug-nix.md;
  };
}
