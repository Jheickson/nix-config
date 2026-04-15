-- =============================================================================
-- OPTIONS
-- =============================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- =============================================================================
-- KEYMAPS
-- =============================================================================

-- Clear search highlight (like clicking away in VSCode)
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal' })

-- Save with Ctrl+S (VSCode muscle memory)
vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<cmd>w<CR><Esc>', { desc = 'Save file' })

-- Close buffer (like closing a tab in VSCode)
vim.keymap.set('n', '<leader>bd', '<cmd>bd<CR>', { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>bD', '<cmd>bd!<CR>', { desc = 'Force close buffer' })

-- Switch buffers (like Alt+Left/Right in VSCode)
vim.keymap.set('n', '<S-h>', '<cmd>bprev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })

-- Window navigation (panes, like Ctrl+1/2/3 in VSCode)
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move to right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move to upper window' })

-- Move selected lines up/down (like Alt+Up/Down in VSCode)
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Scroll and keep cursor centered
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Clipboard (explicit, avoids clobbering the unnamed register on delete)
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to clipboard' })
vim.keymap.set('n', '<leader>Y', '"+Y', { desc = 'Yank line to clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste from clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>P', '"+P', { desc = 'Paste before from clipboard' })

-- Diagnostics (like VSCode's Problems panel hover)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show error' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next error' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev error' })

-- =============================================================================
-- AUTOCMDS
-- =============================================================================
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- =============================================================================
-- LSP (built-in 0.12 API — no lspconfig needed)
-- =============================================================================
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
  settings = {
    Lua = { runtime = { version = 'LuaJIT' } },
  },
})

vim.lsp.config('nixd', {
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
})

vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
})

vim.lsp.config('tailwindcss', {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    'html', 'css', 'scss',
    'javascript', 'javascriptreact',
    'typescript', 'typescriptreact',
    'svelte',
  },
  root_markers = { 'tailwind.config.js', 'tailwind.config.ts', 'package.json', '.git' },
})

vim.lsp.enable({ 'lua_ls', 'nixd', 'rust_analyzer', 'tailwindcss' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    -- Navigation (like F12 / Ctrl+Click in VSCode)
    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('gr', vim.lsp.buf.references, 'References')
    map('gI', vim.lsp.buf.implementation, 'Implementation')
    -- Info (like hovering in VSCode)
    map('K', vim.lsp.buf.hover, 'Hover docs')
    map('<C-k>', vim.lsp.buf.signature_help, 'Signature help')
    -- Actions (like right-click menu in VSCode)
    map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('<leader>D', vim.lsp.buf.type_definition, 'Type definition')

    -- Built-in LSP completion (Neovim 0.11+)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end,
})

-- =============================================================================
-- PLUGINS via vim.pack
-- =============================================================================

vim.pack.add({
  'https://github.com/nvim-mini/mini.nvim',
})

-- Project root detection (auto-cd when opening a file)
-- Makes find-files and file explorer always work from the project root
require('mini.misc').setup()
MiniMisc.setup_auto_root({ '.git', 'flake.nix', 'Cargo.toml', 'package.json', 'pyproject.toml' })

-- Colorscheme: Catppuccin Mocha palette via mini.base16
require('mini.base16').setup({
  palette = {
    base00 = '#1e1e2e', -- background
    base01 = '#181825',
    base02 = '#313244',
    base03 = '#45475a',
    base04 = '#585b70',
    base05 = '#cdd6f4', -- foreground
    base06 = '#f5e0dc',
    base07 = '#b4befe',
    base08 = '#f38ba8', -- red
    base09 = '#fab387', -- orange/peach
    base0A = '#f9e2af', -- yellow
    base0B = '#a6e3a1', -- green
    base0C = '#94e2d5', -- teal
    base0D = '#89b4fa', -- blue
    base0E = '#cba4f7', -- purple/mauve
    base0F = '#f2cdcd', -- pink
  },
})

-- Icons (used by statusline, tabline, etc.)
require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons() -- so plugins expecting nvim-web-devicons work

-- Auto-close brackets and quotes (like VSCode)
require('mini.pairs').setup()

-- Better text objects: `dif` delete inner function, `ca(` change around parens, etc.
require('mini.ai').setup()

-- Surround: `sa"` add quotes, `sd"` delete quotes, `sr"'` replace quotes
require('mini.surround').setup()

-- Comment toggle — maps to `gc` by default, also map Ctrl+/ like VSCode
require('mini.comment').setup()
vim.keymap.set('n', '<C-/>', 'gcc', { remap = true, desc = 'Toggle comment' })
vim.keymap.set('v', '<C-/>', 'gc', { remap = true, desc = 'Toggle comment' })

-- Git gutter (like VSCode's source control indicators in the gutter)
require('mini.diff').setup()
vim.keymap.set('n', '<leader>gd', MiniDiff.toggle_overlay, { desc = 'Git diff overlay' })

-- Notifications (replaces the default bottom-right echo messages)
require('mini.notify').setup()
vim.notify = MiniNotify.make_notify()

-- Buffer tabs at the top (like VSCode's tabs)
require('mini.tabline').setup()

-- Status line at the bottom
require('mini.statusline').setup()

-- Highlight the word under cursor across the file (like VSCode)
require('mini.cursorword').setup({ delay = 200 })

-- Minimap (like VSCode's scrollbar overview on the right)
require('mini.map').setup({
  integrations = {
    MiniMap.gen_integration.builtin_search(),   -- show / search matches
    MiniMap.gen_integration.diagnostic(),       -- show LSP errors/warnings
    MiniMap.gen_integration.diff(),             -- show git changes
  },
  symbols = {
    encode = MiniMap.gen_encode_symbols.dot('4x2'), -- resolution
    scroll_line = '▶',
    scroll_view = '┃',
  },
  window = {
    side = 'right',
    width = 15,
    winblend = 15, -- slight transparency
  },
})
-- Auto-open map for normal files, toggle with <leader>m
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    local ft = vim.bo.filetype
    local excluded = { 'help', 'minifiles', 'minimap', 'notify', '' }
    if not vim.tbl_contains(excluded, ft) then
      MiniMap.open()
    end
  end,
})
vim.keymap.set('n', '<leader>m', MiniMap.toggle, { desc = 'Toggle minimap' })

-- Indent scope indicator (the animated vertical line in the current block)
require('mini.indentscope').setup()

-- Fuzzy finder (like Ctrl+P / Ctrl+Shift+F in VSCode)
require('mini.pick').setup()
vim.keymap.set('n', '<C-p>', MiniPick.builtin.files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>ff', MiniPick.builtin.files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', MiniPick.builtin.grep_live, { desc = 'Search in project' })
vim.keymap.set('n', '<leader>fb', MiniPick.builtin.buffers, { desc = 'Open buffers' })
vim.keymap.set('n', '<leader>fh', MiniPick.builtin.help, { desc = 'Help' })
vim.keymap.set('n', '<leader>fd', function()
  MiniPick.builtin.diagnostic({ scope = 'all' })
end, { desc = 'Find diagnostics' })

-- File explorer (like VSCode sidebar, open with -)
require('mini.files').setup({
  mappings = {
    go_in       = '<Right>', -- enter dir / open file (keep explorer open)
    go_in_plus  = '<CR>',    -- open file AND close explorer
    go_out      = '<Left>',  -- go to parent dir
    go_out_plus = '<BS>',    -- go to parent and close right pane
    close       = 'q',
  },
})
vim.keymap.set('n', '-', MiniFiles.open, { desc = 'File explorer' })

-- Keybinding hints popup (shows what keys do after you press <leader>)
-- Like VSCode's keyboard shortcut tooltips
local clue = require('mini.clue')
clue.setup({
  triggers = {
    { mode = 'n', keys = '<leader>' },
    { mode = 'n', keys = 'g' },
    { mode = 'n', keys = 's' },
    { mode = 'n', keys = ']' },
    { mode = 'n', keys = '[' },
    { mode = 'v', keys = '<leader>' },
    { mode = 'v', keys = 'g' },
  },
  clues = {
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
    -- Group labels
    { mode = 'n', keys = '<leader>b', desc = '+buffer' },
    { mode = 'n', keys = '<leader>f', desc = '+find' },
    { mode = 'n', keys = '<leader>g', desc = '+git' },
  },
})

-- =============================================================================
-- TREESITTER (syntax highlighting — lazy, loads after UI ready)
-- =============================================================================
local function setup_treesitter()
  require('nvim-treesitter.configs').setup({
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })
end

-- Handle first-time async install
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'install' then
      setup_treesitter()
    end
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' })
    if pcall(require, 'nvim-treesitter.configs') then
      setup_treesitter()
    end
  end,
})
