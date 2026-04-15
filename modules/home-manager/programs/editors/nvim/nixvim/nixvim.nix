{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    # ── Options ─────────────────────────────────────────────────────────────
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      termguicolors = true;

      list = true;
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
      };

      hlsearch = true;
      inccommand = "split";
      scrolloff = 10;
      mouse = "a";
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      completeopt = "menu,preview,noselect";
    };

    # ── Globals ──────────────────────────────────────────────────────────────
    globals = {
      mapleader = " ";
      maplocalleader = " ";
      netrw_liststyle = 0;
      netrw_banner = 0;
      # vim-rooter
      rooter_buftypes = [ "" ];
      rooter_patterns = [ ".git" "flake.nix" "package.json" "Cargo.toml" "go.mod" "pyproject.toml" ];
      rooter_silent_chdir = 1;
    };

    # ── Autocommands ─────────────────────────────────────────────────────────
    autoGroups.YankHighlight.clear = true;
    autoCmd = [
      {
        event = "TextYankPost";
        group = "YankHighlight";
        pattern = "*";
        callback.__raw = "function() vim.highlight.on_yank() end";
      }
      {
        event = "FileType";
        pattern = "*";
        callback.__raw = ''
          function()
            vim.opt.formatoptions:remove({ "c", "r", "o" })
          end
        '';
      }
    ];

    # ── Keymaps ──────────────────────────────────────────────────────────────
    keymaps = [
      # Clear search highlight
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; }

      # Visual line movement
      { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move line down"; }
      { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move line up"; }

      # Scroll with centering
      { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; options.desc = "Scroll down"; }
      { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; options.desc = "Scroll up"; }
      { mode = "n"; key = "n"; action = "nzzzv"; options.desc = "Next search result"; }
      { mode = "n"; key = "N"; action = "Nzzzv"; options.desc = "Previous search result"; }

      # Buffer management
      { mode = "n"; key = "<leader><leader>["; action = "<cmd>bprev<CR>"; options.desc = "Previous buffer"; }
      { mode = "n"; key = "<leader><leader>]"; action = "<cmd>bnext<CR>"; options.desc = "Next buffer"; }
      { mode = "n"; key = "<leader><leader>l"; action = "<cmd>b#<CR>"; options.desc = "Last buffer"; }
      { mode = "n"; key = "<leader><leader>d"; action = "<cmd>bdelete<CR>"; options.desc = "Delete buffer"; }

      # Wrap-aware j/k
      { mode = "n"; key = "k"; action.__raw = "\"v:count == 0 ? 'gk' : 'k'\""; options = { expr = true; silent = true; }; }
      { mode = "n"; key = "j"; action.__raw = "\"v:count == 0 ? 'gj' : 'j'\""; options = { expr = true; silent = true; }; }

      # Diagnostic
      { mode = "n"; key = "<leader>e"; action.__raw = "vim.diagnostic.open_float"; options.desc = "Open floating diagnostic"; }
      { mode = "n"; key = "<leader>q"; action.__raw = "vim.diagnostic.setloclist"; options.desc = "Open diagnostics list"; }

      # Clipboard (avoid clobbering with unnamedplus)
      { mode = [ "v" "x" "n" ]; key = "<leader>y"; action = "\"+y"; options = { noremap = true; silent = true; desc = "Yank to clipboard"; }; }
      { mode = [ "n" "v" "x" ]; key = "<leader>Y"; action = "\"+yy"; options = { noremap = true; silent = true; desc = "Yank line to clipboard"; }; }
      { mode = [ "n" "v" "x" ]; key = "<leader>p"; action = "\"+p"; options = { noremap = true; silent = true; desc = "Paste from clipboard"; }; }
      { mode = "i"; key = "<C-p>"; action = "<C-r><C-p>+"; options = { noremap = true; silent = true; desc = "Paste from clipboard (insert)"; }; }
      { mode = "x"; key = "<leader>P"; action = "\"_dP"; options = { noremap = true; silent = true; desc = "Paste over selection (no yank)"; }; }

      # Terminal
      { mode = "t"; key = "<Esc><Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode"; }

      # LSP
      { mode = "n"; key = "<leader>rn"; action.__raw = "vim.lsp.buf.rename"; options.desc = "LSP: Rename"; }
      { mode = "n"; key = "<leader>ca"; action.__raw = "vim.lsp.buf.code_action"; options.desc = "LSP: Code action"; }
      { mode = "n"; key = "gd"; action.__raw = "vim.lsp.buf.definition"; options.desc = "LSP: Goto definition"; }
      { mode = "n"; key = "<leader>D"; action.__raw = "vim.lsp.buf.type_definition"; options.desc = "LSP: Type definition"; }
      { mode = "n"; key = "K"; action.__raw = "vim.lsp.buf.hover"; options.desc = "LSP: Hover docs"; }
      { mode = "n"; key = "<C-k>"; action.__raw = "vim.lsp.buf.signature_help"; options.desc = "LSP: Signature help"; }
      { mode = "n"; key = "gD"; action.__raw = "vim.lsp.buf.declaration"; options.desc = "LSP: Goto declaration"; }

      # Formatting
      { mode = [ "n" "v" ]; key = "<leader>FF"; action.__raw = ''
          function()
            require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
          end
        '';
        options.desc = "Format file";
      }

      # Snacks keymaps
      { mode = "n"; key = "-"; action.__raw = "function() Snacks.explorer.open() end"; options.desc = "Snacks Explorer"; }
      { mode = "n"; key = "<C-\\>"; action.__raw = "function() Snacks.terminal.open() end"; options.desc = "Snacks Terminal"; }
      { mode = "n"; key = "<leader>_"; action.__raw = "function() Snacks.lazygit.open() end"; options.desc = "Snacks LazyGit"; }
      { mode = "n"; key = "<leader>sf"; action.__raw = "function() Snacks.picker.smart() end"; options.desc = "Smart find files"; }
      { mode = "n"; key = "<leader><leader>s"; action.__raw = "function() Snacks.picker.buffers() end"; options.desc = "Search buffers"; }
      { mode = "n"; key = "<leader>ff"; action.__raw = "function() Snacks.picker.files() end"; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>fg"; action.__raw = "function() Snacks.picker.git_files() end"; options.desc = "Find git files"; }
      { mode = "n"; key = "<leader>sb"; action.__raw = "function() Snacks.picker.lines() end"; options.desc = "Buffer lines"; }
      { mode = "n"; key = "<leader>sB"; action.__raw = "function() Snacks.picker.grep_buffers() end"; options.desc = "Grep open buffers"; }
      { mode = "n"; key = "<leader>sg"; action.__raw = "function() Snacks.picker.grep() end"; options.desc = "Grep"; }
      { mode = [ "n" "x" ]; key = "<leader>sw"; action.__raw = "function() Snacks.picker.grep_word() end"; options.desc = "Grep word/selection"; }
      { mode = "n"; key = "<leader>sd"; action.__raw = "function() Snacks.picker.diagnostics() end"; options.desc = "Diagnostics"; }
      { mode = "n"; key = "<leader>sD"; action.__raw = "function() Snacks.picker.diagnostics_buffer() end"; options.desc = "Buffer diagnostics"; }
      { mode = "n"; key = "<leader>sh"; action.__raw = "function() Snacks.picker.help() end"; options.desc = "Help pages"; }
      { mode = "n"; key = "<leader>sk"; action.__raw = "function() Snacks.picker.keymaps() end"; options.desc = "Keymaps"; }
      { mode = "n"; key = "<leader>sm"; action.__raw = "function() Snacks.picker.marks() end"; options.desc = "Marks"; }
      { mode = "n"; key = "<leader>sq"; action.__raw = "function() Snacks.picker.qflist() end"; options.desc = "Quickfix list"; }
      { mode = "n"; key = "<leader>sR"; action.__raw = "function() Snacks.picker.resume() end"; options.desc = "Resume picker"; }
      { mode = "n"; key = "<leader>su"; action.__raw = "function() Snacks.picker.undo() end"; options.desc = "Undo history"; }
      { mode = "n"; key = "gr"; action.__raw = "function() Snacks.picker.lsp_references() end"; options.desc = "LSP: References"; }
      { mode = "n"; key = "gI"; action.__raw = "function() Snacks.picker.lsp_implementations() end"; options.desc = "LSP: Implementations"; }
      { mode = "n"; key = "<leader>ds"; action.__raw = "function() Snacks.picker.lsp_symbols() end"; options.desc = "LSP: Document symbols"; }
      { mode = "n"; key = "<leader>ws"; action.__raw = "function() Snacks.picker.lsp_workspace_symbols() end"; options.desc = "LSP: Workspace symbols"; }
    ];

    # ── Plugins ──────────────────────────────────────────────────────────────
    plugins = {
      web-devicons.enable = true;

      # Statusline
      lualine = {
        enable = true;
        settings = {
          options = {
            icons_enabled = false;
            component_separators = "|";
            section_separators = "";
          };
          sections = {
            lualine_c = [
              { __unkeyed-1 = "filename"; path = 1; status = true; }
            ];
          };
          inactive_sections = {
            lualine_b = [
              { __unkeyed-1 = "filename"; path = 3; status = true; }
            ];
            lualine_x = [ "filetype" ];
          };
          tabline = {
            lualine_a = [ "buffers" ];
            lualine_z = [ "tabs" ];
          };
        };
      };

      # Treesitter
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = false;
          incremental_selection = {
            enable = true;
            keymaps = {
              init_selection = "<c-space>";
              node_incremental = "<c-space>";
              scope_incremental = "<c-s>";
              node_decremental = "<M-space>";
            };
          };
        };
      };

      treesitter-textobjects = {
        enable = true;
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "aa" = "@parameter.outer";
            "ia" = "@parameter.inner";
            "af" = "@function.outer";
            "if" = "@function.inner";
            "ac" = "@class.outer";
            "ic" = "@class.inner";
          };
        };
        move = {
          enable = true;
          set_jumps = true;
          goto_next_start = {
            "]m" = "@function.outer";
            "]]" = "@class.outer";
          };
          goto_next_end = {
            "]M" = "@function.outer";
            "][" = "@class.outer";
          };
          goto_previous_start = {
            "[m" = "@function.outer";
            "[[" = "@class.outer";
          };
          goto_previous_end = {
            "[M" = "@function.outer";
            "[]" = "@class.outer";
          };
        };
      };

      # Git
      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "+";
            change.text = "~";
            delete.text = "_";
            topdelete.text = "‾";
            changedelete.text = "~";
          };
          on_attach.__raw = ''
            function(bufnr)
              local gs = package.loaded.gitsigns
              local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
              end
              map({ "n", "v" }, "]c", function()
                if vim.wo.diff then return "]c" end
                vim.schedule(function() gs.next_hunk() end)
                return "<Ignore>"
              end, { expr = true, desc = "Jump to next hunk" })
              map({ "n", "v" }, "[c", function()
                if vim.wo.diff then return "[c" end
                vim.schedule(function() gs.prev_hunk() end)
                return "<Ignore>"
              end, { expr = true, desc = "Jump to previous hunk" })
              map("v", "<leader>hs", function() gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end, { desc = "Stage git hunk" })
              map("v", "<leader>hr", function() gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end, { desc = "Reset git hunk" })
              map("n", "<leader>gs", gs.stage_hunk, { desc = "Git stage hunk" })
              map("n", "<leader>gr", gs.reset_hunk, { desc = "Git reset hunk" })
              map("n", "<leader>gS", gs.stage_buffer, { desc = "Git stage buffer" })
              map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
              map("n", "<leader>gR", gs.reset_buffer, { desc = "Git reset buffer" })
              map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview git hunk" })
              map("n", "<leader>gb", function() gs.blame_line { full = false } end, { desc = "Git blame line" })
              map("n", "<leader>gd", gs.diffthis, { desc = "Git diff against index" })
              map("n", "<leader>gD", function() gs.diffthis "~" end, { desc = "Git diff against last commit" })
              map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "Toggle git blame line" })
              map("n", "<leader>gtd", gs.toggle_deleted, { desc = "Toggle git show deleted" })
              map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
            end
          '';
        };
      };

      # Keybinding hints
      which-key = {
        enable = true;
        settings.spec = [
          { __unkeyed-1 = "<leader><leader>"; group = "buffer commands"; }
          { __unkeyed-1 = "<leader>c"; group = "[c]ode"; }
          { __unkeyed-1 = "<leader>d"; group = "[d]ocument"; }
          { __unkeyed-1 = "<leader>g"; group = "[g]it"; }
          { __unkeyed-1 = "<leader>r"; group = "[r]ename"; }
          { __unkeyed-1 = "<leader>f"; group = "[f]ind"; }
          { __unkeyed-1 = "<leader>s"; group = "[s]earch"; }
          { __unkeyed-1 = "<leader>t"; group = "[t]oggles"; }
          { __unkeyed-1 = "<leader>w"; group = "[w]orkspace"; }
          { __unkeyed-1 = "<leader>a"; group = "[a]i"; }
        ];
      };

      # Completion
      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "default";
          appearance.nerd_font_variant = "mono";
          signature.enabled = true;
          sources.default = [ "lsp" "path" "snippets" "buffer" ];
        };
      };

      # LSP
      lsp = {
        enable = true;
        servers = {
          nixd = {
            enable = true;
            settings = {
              nixd = {
                nixpkgs.expr = "import <nixpkgs> {}";
                formatting.command = [ "alejandra" ];
                diagnostic.suppress = [ "sema-escaping-with" ];
              };
            };
          };
          lua_ls = {
            enable = true;
            settings = {
              Lua = {
                runtime.version = "LuaJIT";
                signatureHelp.enabled = true;
                diagnostics = {
                  globals = [ "vim" ];
                  disable = [ "missing-fields" ];
                };
                telemetry.enabled = false;
              };
            };
          };
        };
      };

      # Formatting
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            lua = [ "stylua" ];
            nix = [ "alejandra" ];
          };
        };
      };

      # Mini utilities
      mini = {
        enable = true;
        modules = {
          pairs = {};
          ai = {};
          icons = {};
        };
      };

      # Session management
      auto-session = {
        enable = true;
        settings = {
          auto_restore = true;
          auto_save = true;
          lazy_support = true;
          bypass_save_filetypes = [ "snacks_dashboard" "terminal" ];
          close_filetypes_on_save = [ "terminal" ];
          session_lens.picker = "snacks";
        };
      };

      # Snacks (picker, explorer, lazygit, terminal, dashboard, notifier)
      snacks = {
        enable = true;
        settings = {
          explorer = {};
          picker = {};
          dashboard = {
            enabled = true;
            preset = {
              keys = [
                { icon = " "; key = "f"; desc = "Find File"; action = ":lua Snacks.dashboard.pick('files')"; }
                { icon = " "; key = "q"; desc = "Quit"; action = ":qa"; }
              ];
            };
            sections = [
              {
                section = "header";
                header = ''
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██║   ██║██║██║╚██╔╝██║
██║ ╚████║╚██████╔╝██║██║ ╚═╝ ██║
╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝     ╚═╝'';
              }
              { section = "keys"; gap = 1; padding = 1; }
              { icon = " "; title = "Recent Files"; section = "recent_files"; indent = 2; padding = 1; }
            ];
          };
          bigfile = {};
          lazygit = {};
          terminal = {};
          rename = {};
          notifier = {};
          indent = {};
          gitbrowse = {};
          scope = {};
        };
      };
    };

    # ── Extra plugins (not in nixvim modules) ────────────────────────────────
    extraPlugins = with pkgs.vimPlugins; [
      vim-rooter
      vim-sleuth
    ];

    # ── Runtime dependencies ─────────────────────────────────────────────────
    extraPackages = with pkgs; [
      ripgrep
      fd
      nixd
      lua-language-server
      stylua
      alejandra
      lazygit
    ];

    # ── Extra Lua ────────────────────────────────────────────────────────────
    extraLuaConfig = ''
      -- Open dashboard on startup when no file args
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          if vim.fn.argc() == 0 then
            Snacks.dashboard.open()
          end
        end,
      })

      -- autoread
      vim.o.autoread = true

      -- gitsigns highlights
      vim.cmd([[hi GitSignsAdd guifg=#04de21]])
      vim.cmd([[hi GitSignsChange guifg=#83fce6]])
      vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
    '';
  };
}
