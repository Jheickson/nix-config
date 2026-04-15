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
    lazygit
    nodejs
  ];

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
    v = "nvim";
  };

  xdg.configFile."nvim/init.lua".source = ./init.lua;
}
