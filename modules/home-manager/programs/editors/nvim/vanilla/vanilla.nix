{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim # 0.12.1 from nixos-unstable

    # LSP servers & tools
    lua-language-server
    nixd
    alejandra
    stylua
    rust-analyzer
    tailwindcss-language-server
    typescript-language-server
    lazygit
    nodejs

    # Formatters (used by conform.nvim)
    prettierd

    # Treesitter auto_install deps (CLI + C compiler for parser builds)
    tree-sitter
    gcc

    # System clipboard providers (Wayland + X11 fallback)
    wl-clipboard
    xclip
  ];

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
    v = "nvim";
  };

  xdg.configFile."nvim/init.lua".source = ./init.lua;
}
