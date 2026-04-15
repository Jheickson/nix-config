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
vim.opt.timeoutlen = 300
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
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>')
vim.keymap.set('n', '<C-l>', '<C-w><C-l>')
vim.keymap.set('n', '<C-j>', '<C-w><C-j>')
vim.keymap.set('n', '<C-k>', '<C-w><C-k>')

-- Move lines in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Clipboard (avoids polluting the unnamed register)
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to clipboard' })
vim.keymap.set('n', '<leader>Y', '"+Y')
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste from clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>P', '"+P')

-- Diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Diagnostic float' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic' })

-- =============================================================================
-- AUTOCMDS
-- =============================================================================
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- =============================================================================
-- LSP (built-in, no lspconfig needed in 0.12)
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

-- LSP keymaps and built-in completion on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('gr', vim.lsp.buf.references, 'References')
    map('gI', vim.lsp.buf.implementation, 'Implementation')
    map('K', vim.lsp.buf.hover, 'Hover')
    map('<C-k>', vim.lsp.buf.signature_help, 'Signature help')
    map('<leader>rn', vim.lsp.buf.rename, 'Rename')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('<leader>D', vim.lsp.buf.type_definition, 'Type definition')

    -- Built-in LSP completion (0.11+)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end,
})

-- =============================================================================
-- PLUGINS via vim.pack
-- =============================================================================

-- mini.nvim: loads immediately, covers most UI needs
vim.pack.add({
  'https://github.com/echasnovski/mini.nvim',
})

require('mini.pairs').setup()
require('mini.ai').setup()
require('mini.icons').setup()
require('mini.statusline').setup()

-- Fuzzy finder
require('mini.pick').setup()
vim.keymap.set('n', '<leader>ff', MiniPick.builtin.files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', MiniPick.builtin.grep_live, { desc = 'Grep' })
vim.keymap.set('n', '<leader>fb', MiniPick.builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', MiniPick.builtin.help, { desc = 'Help' })

-- File explorer
require('mini.files').setup()
vim.keymap.set('n', '-', MiniFiles.open, { desc = 'File explorer' })

-- Treesitter: lazy, loaded after UI is ready
-- PackChanged handles first-time async install; pcall handles subsequent runs
local function setup_treesitter()
  require('nvim-treesitter.configs').setup({
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })
end

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
    -- Already installed: setup immediately
    if pcall(require, 'nvim-treesitter.configs') then
      setup_treesitter()
    end
  end,
})
