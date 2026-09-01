{ config, lib, ... }:

let
  cfg = config.vex.ai;
in
{
  options.vex.ai = {
    enable = lib.mkEnableOption "the Vex AI assistant (local Ollama model service)";

    model = lib.mkOption {
      type = lib.types.str;
      default = "qwen2.5-coder:7b";
      description = "Ollama model to load for the Vex AI assistant.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      description = "Port for the Ollama service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      loadModels = [ cfg.model ];
      inherit (cfg) port;
    };
  };
}
