{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.vex.neovim;
in
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  options.vex.neovim = {
    enable = lib.mkEnableOption "Neovim, configured via nvf (https://github.com/notashelf/nvf)";
  };

  config = lib.mkIf cfg.enable {
    programs.nvf = {
      enable = true;

      settings = {
        vim.viAlias = false;
        vim.vimAlias = true;

        vim.theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };

        vim.statusline.lualine.enable = true;
        vim.telescope.enable = true;
        vim.filetree.neo-tree.enable = true;

        vim.autocomplete.nvim-cmp.enable = true;

        vim.lsp = {
          enable = true;
          formatOnSave = true;
          lspkind.enable = true;
          lightbulb.enable = true;
        };

        # Nix support is on unconditionally since this is, itself, a Nix
        # project — extend vim.languages.* for anything else you need.
        vim.languages.nix.enable = true;
      };
    };
  };
}
