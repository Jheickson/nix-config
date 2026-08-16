{
  pkgs,
  stylixConfig,
  inputs,
  ...
}:

let
  generator = import ../../../../../shared/generators.nix { inherit pkgs stylixConfig inputs; };
  nvimColorscheme = generator.nvim;
in
{
  home.packages = with pkgs; [
    neovim # 0.12.1 from nixos-unstable

    # LSP servers & tools
    lua-language-server
    nixd
    alejandra
    stylua
    rust-analyzer
    lldb # DAP debugger for rustaceanvim (:RustDebuggables) — provides lldb-dap
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

  # Generator-derived colorscheme (matugen or iris). Regenerated on every nh
  # switch when the wallpaper or palette inputs change. nvim FS-watches this
  # file (see init.lua) and re-sources :colorscheme matugen on write.
  xdg.configFile."nvim/colors/matugen.lua".source = nvimColorscheme;
}
