{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      termguicolors = true;
      clipboard = "unnamedplus";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    plugins = {
      lualine.enable = true;
      treesitter.enable = true;
      telescope.enable = true;
      web-devicons.enable = true;
      cmp.enable = true;
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          lua_ls.enable = true;
        };
      };
    };

    extraPackages = with pkgs; [
      ripgrep
      fd
      nixd
      lua-language-server
      stylua
      alejandra
    ];
  };
}
