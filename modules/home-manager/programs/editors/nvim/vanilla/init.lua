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
vim.opt.showcmd = true
vim.opt.wildmenu = true
vim.opt.cmdheight = 1
vim.opt.confirm = true

-- =============================================================================
-- KEYMAPS
-- =============================================================================

-- Clear search highlight (like clicking away in VSCode)
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal' })

-- Buffer helpers
local function close_buffer(force)
  local cur = vim.api.nvim_get_current_buf()
  local listed = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())
  local bang = (force or vim.bo[cur].buftype == 'terminal') and '!' or ''
  if #listed > 1 then vim.cmd('bprevious') end
  vim.cmd('bdelete' .. bang .. ' ' .. cur)
end

-- Save and quit using leader-based bindings
vim.keymap.set({ 'n', 'i', 'v' }, '<leader>W', '<cmd>update<CR>', { desc = 'Write buffer' })
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { desc = 'Close window' })
vim.keymap.set('n', '<leader>Q', '<cmd>qa<CR>', { desc = 'Quit all' })

-- Buffer navigation and closing (more Vim-native than tab-style switching)
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>bd', function() close_buffer(false) end, { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>bD', function() close_buffer(true) end, { desc = 'Force close buffer' })

-- Window management
vim.keymap.set('n', '<leader>-', '<cmd>split<CR>', { desc = 'Split horizontal' })
vim.keymap.set('n', '<leader>\\', '<cmd>vsplit<CR>', { desc = 'Split vertical' })
vim.keymap.set('n', '<leader>wq', '<C-w>q', { desc = 'Close window' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = 'Only this window' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Equalize windows' })
vim.keymap.set('n', '<leader>wr', '<C-w>r', { desc = 'Rotate windows' })

-- Window navigation uses the native Ctrl+w prefix
-- Example: <C-w>h, <C-w>j, <C-w>k, <C-w>l

-- Move selected lines up/down
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

-- Diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show error' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next error' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev error' })

-- Format now (manual trigger on top of format-on-save)
vim.keymap.set('n', '<leader>lf', function()
  require('conform').format({ async = true, lsp_format = 'fallback' })
end, { desc = 'Format file' })

-- Toggle terminal with a leader-based mapping
local term_buf = nil
local term_win = nil
vim.keymap.set({ 'n', 't' }, '<leader>tt', function()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
    term_win = nil
  elseif term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.cmd('botright 15split')
    term_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(term_win, term_buf)
    vim.cmd('startinsert')
  else
    vim.cmd('botright 15split | terminal')
    term_buf = vim.api.nvim_get_current_buf()
    term_win = vim.api.nvim_get_current_win()
    vim.cmd('startinsert')
  end
end, { desc = 'Toggle terminal' })

-- =============================================================================
-- AUTOCMDS
-- =============================================================================
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- mini.pick + mini.starter + mini.statusline highlights (must reapply after
-- colorscheme changes, including matugen live reloads — mini.statusline's own
-- defaults point at Cursor/Diff*/IncSearch/StatusLineNC, which matugen doesn't
-- define, so they'd fall back to Vim's colors and clash with the palette)
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('mini-pick-hl', { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, 'MiniPickMatchCurrent', { link = 'PmenuSel', force = true })
    local accent = vim.api.nvim_get_hl(0, { name = 'Special' }).fg
    vim.api.nvim_set_hl(0, 'MiniStarterHeader', { fg = accent, bold = true })
    vim.api.nvim_set_hl(0, 'MiniStarterFooter', { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'MiniStarterCurrent', { link = 'PmenuSel', force = true })
    vim.api.nvim_set_hl(0, 'MiniStarterSection', { link = 'Keyword' })
    vim.api.nvim_set_hl(0, 'MiniStarterQuery', { link = 'Function' })
    vim.api.nvim_set_hl(0, 'MiniStarterInactive', { link = 'Comment' })

    -- Mode indicator: distinct accent per mode so it never blends with the
    -- dim location/search groups at the right end of the statusline
    vim.api.nvim_set_hl(0, 'MiniStatuslineModeNormal', { link = 'Keyword', force = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineModeInsert', { link = 'Function', force = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineModeVisual', { link = 'String', force = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineModeReplace', { link = 'Special', force = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineModeCommand', { link = 'Special', force = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineModeOther', { link = 'Constant', force = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineDevinfo', { link = 'LineNr', force = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineFileinfo', { link = 'LineNr', force = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineLocation', { link = 'LineNr', force = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineFilename', {
      fg = vim.api.nvim_get_hl(0, { name = 'Normal' }).fg,
      bold = true,
      force = true,
    })
    -- matugen doesn't define StatusLineNC; without this inactive windows use
    -- Vim's default StatusLineNC and clash with the palette
    vim.api.nvim_set_hl(0, 'MiniStatuslineInactive', { link = 'LineNr', force = true })
    vim.api.nvim_set_hl(0, 'StatusLineNC', {
      fg = vim.api.nvim_get_hl(0, { name = 'LineNr' }).fg,
      bg = vim.api.nvim_get_hl(0, { name = 'StatusLine' }).bg,
    })
  end,
})
vim.api.nvim_set_hl(0, 'MiniPickMatchCurrent', { link = 'PmenuSel', force = true })

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

vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript', 'javascriptreact',
    'typescript', 'typescriptreact',
  },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
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

-- rust_analyzer is managed by rustaceanvim — do NOT re-add it here (double client)
vim.lsp.enable({ 'lua_ls', 'nixd', 'ts_ls', 'tailwindcss' })

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
    vim.keymap.set('i', '<C-s>', vim.lsp.buf.signature_help,
      { buffer = event.buf, desc = 'LSP: Signature help' })
    -- Actions (like right-click menu in VSCode)
    map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('<leader>D', vim.lsp.buf.type_definition, 'Type definition')

    -- Inlay hints
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    end
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(
        not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
        { bufnr = event.buf }
      )
    end, 'Toggle inlay hints')

  end,
})

-- =============================================================================
-- PLUGINS via vim.pack
-- =============================================================================

vim.pack.add({
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/Saghen/blink.cmp',
  'https://github.com/rmagatti/auto-session',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/mrcjkb/rustaceanvim',
})

-- Rust tooling (rustaceanvim) — manages rust-analyzer itself, adds cargo
-- integration (:RustRun/:RustTest), DAP debugging, and RustLsp commands.
-- Debugging uses lldb-dap (from the lldb package in vanilla.nix); rust-analyzer
-- is picked up from PATH.
vim.g.rustaceanvim = {
  tools = {
    float_win_config = { border = 'rounded' }, -- match mini.pick's rounded border
  },
  dap = {
    adapter = {
      type = 'executable',
      command = 'lldb-dap',
      args = {},
    },
  },
}

-- Format on save via conform.nvim — explicit formatter per filetype,
-- bypass via :FormatDisable (buffer: !), re-enable via :FormatEnable
require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    nix = { 'alejandra' },
    rust = { 'rustfmt' },
    javascript      = { 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    typescript      = { 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    json     = { 'prettierd', 'prettier', stop_after_first = true },
    jsonc    = { 'prettierd', 'prettier', stop_after_first = true },
    css      = { 'prettierd', 'prettier', stop_after_first = true },
    html     = { 'prettierd', 'prettier', stop_after_first = true },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
    yaml     = { 'prettierd', 'prettier', stop_after_first = true },
  },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
    return { timeout_ms = 2000, lsp_format = 'fallback' }
  end,
})
vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then vim.b.disable_autoformat = true else vim.g.disable_autoformat = true end
end, { bang = true, desc = 'Disable autoformat (! = buffer-local)' })
vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = 'Re-enable autoformat' })

pcall(function()
  require('blink.cmp').setup({
    keymap = { preset = 'default' },
    appearance = { use_nvim_cmp_as_default = false },
    sources = {
      default = { 'lsp', 'path', 'snippets' },
      providers = {
        buffer = { min_keyword_length = 4 },
      },
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    fuzzy = { implementation = 'lua' },
  })
end)

-- Project root detection (auto-cd when opening a file)
-- Makes find-files and file explorer always work from the project root
require('mini.misc').setup()
MiniMisc.setup_auto_root({ '.git', 'flake.nix', 'Cargo.toml', 'package.json', 'pyproject.toml' })

-- =============================================================================
-- COLORSCHEME (matugen-driven, FS-watched for live reload)
-- =============================================================================
-- ~/.config/nvim/colors/matugen.lua is a home-manager symlink to a /nix/store
-- path produced by modules/shared/matugen.nix. The symlink target changes on
-- every nh switch when the matugen palette is regenerated; we watch the path
-- and re-source :colorscheme matugen so live nvim instances pick up the new
-- colors without a restart.
local colors_file = vim.fn.expand('~/.config/nvim/colors/matugen.lua')

local function reload_colorscheme()
  vim.schedule(function()
    pcall(vim.cmd.colorscheme, 'matugen')
  end)
end

local watcher = vim.uv.new_fs_event()
if watcher then
  watcher:start(colors_file, {}, function(err)
    if not err then reload_colorscheme() end
  end)
end

pcall(vim.cmd.colorscheme, 'matugen')

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

-- Git operations (blame, log, show commit at cursor)
require('mini.git').setup()
vim.keymap.set({ 'n', 'v' }, '<leader>gs', MiniGit.show_at_cursor, { desc = 'Git show at cursor' })

-- Notifications (replaces the default bottom-right echo messages)
require('mini.notify').setup()
vim.notify = MiniNotify.make_notify()

-- Buffer tabs at the top (like VSCode's tabs)
require('mini.tabline').setup()

-- Status line at the bottom — matugen-themed via the ColorScheme autocmd above
local statusline = require('mini.statusline')

local function statusline_content()
  local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
  local git = statusline.section_git({ trunc_width = 40 })
  local diff = statusline.section_diff({ trunc_width = 75 })
  local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
  local lsp = statusline.section_lsp({ trunc_width = 75 })
  local filename = statusline.section_filename({ trunc_width = 140 })
  local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
  local location = statusline.section_location({ trunc_width = 75 })
  local search = statusline.section_searchcount({ trunc_width = 75 })

  if vim.bo.modified then filename = filename .. ' ●' end

  return statusline.combine_groups({
    { hl = mode_hl, strings = { mode } },
    { hl = 'MiniStatuslineDevinfo', strings = { git, diff } },
    '%<', -- truncate point for narrow windows
    { hl = 'MiniStatuslineFilename', strings = { filename } },
    '%=', -- end of left-aligned part
    { hl = 'MiniStatuslineDevinfo', strings = { diagnostics, lsp } },
    { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
    { hl = 'MiniStatuslineLocation', strings = { search, location } },
  })
end

statusline.setup({ content = { active = statusline_content } })

-- Highlight the word under cursor across the file (like VSCode)
require('mini.cursorword').setup({ delay = 200 })

-- Minimap (like VSCode's scrollbar overview on the right)
local map_mod = require('mini.map')
map_mod.setup({
  integrations = {
    map_mod.gen_integration.builtin_search(),   -- show / search matches
    map_mod.gen_integration.diagnostic(),       -- show LSP errors/warnings
    map_mod.gen_integration.diff(),             -- show git changes
  },
  symbols = {
    encode = map_mod.gen_encode_symbols.dot('4x2'), -- resolution
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
require('mini.pick').setup({
  mappings = {
    move_down  = '<C-n>',
    move_up    = '<C-p>',
    arrow_down = { char = '<Down>', func = function()
      local k = vim.api.nvim_replace_termcodes('<C-n>', true, true, true)
      vim.api.nvim_feedkeys(k, 'n', false)
    end },
    arrow_up   = { char = '<Up>', func = function()
      local k = vim.api.nvim_replace_termcodes('<C-p>', true, true, true)
      vim.api.nvim_feedkeys(k, 'n', false)
    end },
  },
  window = {
    config = { border = 'rounded' },
    prompt_caret = '▎',
    prompt_prefix = ' ',
  },
})
vim.keymap.set('n', '<leader>ff', MiniPick.builtin.files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', MiniPick.builtin.grep_live, { desc = 'Search in project' })
vim.keymap.set('n', '<leader>fb', MiniPick.builtin.buffers, { desc = 'Open buffers' })
vim.keymap.set('n', '<leader>fh', MiniPick.builtin.help, { desc = 'Help' })
vim.keymap.set('n', '<leader>fd', function()
  MiniPick.builtin.diagnostic({ scope = 'all' })
end, { desc = 'Find diagnostics' })

-- Extra pickers: LSP symbols, git commits/branches, treesitter, etc.
require('mini.extra').setup()
vim.keymap.set('n', '<leader>fs', function()
  MiniExtra.pickers.lsp({ scope = 'document_symbol' })
end, { desc = 'LSP symbols' })
vim.keymap.set('n', '<leader>fS', function()
  MiniExtra.pickers.lsp({ scope = 'workspace_symbol' })
end, { desc = 'LSP workspace symbols' })
vim.keymap.set('n', '<leader>gc', MiniExtra.pickers.git_commits, { desc = 'Git commits' })
vim.keymap.set('n', '<leader>gb', MiniExtra.pickers.git_branches, { desc = 'Git branches' })

-- 2-char jump anywhere on screen (like hop.nvim / flash.nvim)
require('mini.jump2d').setup({ mappings = { start_jumping = '<leader><leader>' } })

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
vim.keymap.set('n', '-', function()
  if not MiniFiles.close() then MiniFiles.open() end
end, { desc = 'Toggle file explorer' })

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(ev)
    vim.keymap.set('n', '<Esc>', MiniFiles.close, { buffer = ev.data.buf_id, desc = 'Close explorer' })
  end,
})

-- Keybinding hints popup (shows what keys do after you press <leader>)
-- Like VSCode's keyboard shortcut tooltips
local clue = require('mini.clue')
clue.setup({
  window = {
    delay = 0,
    config = { width = 50 },
  },
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
    { mode = 'n', keys = '<leader>t', desc = '+toggle' },
    { mode = 'n', keys = '<leader>l', desc = '+lsp' },
    { mode = 'n', keys = '<leader>s', desc = '+session' },
    { mode = 'n', keys = '<leader>w', desc = '+window' },
  },
})

-- =============================================================================
-- SESSIONS (auto-session — save/restore per cwd like VSCode workspaces)
-- =============================================================================
-- Shared session picker (search via <leader>ss, delete via <leader>sd,
-- also reused by the starter's Quick actions)
local function pick_session(delete)
  local dir = require('auto-session').get_root_dir()
  local files = vim.fn.glob(dir .. '*.vim', false, true)
  local items = {}
  for _, path in ipairs(files) do
    local name = vim.fn.fnamemodify(path, ':t:r'):gsub('%%2F', '/')
    table.insert(items, { text = name, _path = path })
  end
  MiniPick.start({
    source = {
      items = items,
      name = delete and 'Delete Session' or 'Sessions',
      choose = function(item)
        if delete then
          vim.fn.delete(item._path)
          vim.notify('Deleted session: ' .. item.text)
        else
          vim.schedule(function()
            vim.cmd('%bdelete!')
            vim.cmd('source ' .. vim.fn.fnameescape(item._path))
          end)
        end
      end,
    },
  })
end

pcall(function()
  require('auto-session').setup({
    auto_save = true,
    auto_restore = false, -- starter screen picks session; see <leader>ss
    suppressed_dirs = { '~/', '~/Downloads', '/' },
  })
  vim.keymap.set('n', '<leader>ss', function() pick_session(false) end, { desc = 'Search sessions' })
  vim.keymap.set('n', '<leader>sd', function() pick_session(true) end, { desc = 'Delete session' })
end)

-- Sessions section for mini.starter
local function sessions_section()
  local sessions_dir = vim.fn.stdpath('data') .. '/sessions/'
  local items = {}
  local files = vim.fn.glob(sessions_dir .. '*.vim', false, true)
  table.sort(files, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)
  for i, path in ipairs(files) do
    if i > 5 then break end
    local name = vim.fn.fnamemodify(path, ':t:r'):gsub('%%2F', '/')
    table.insert(items, {
      name = name,
      action = 'AutoSession restore ' .. vim.fn.fnameescape(name),
      section = 'Sessions',
    })
  end
  return items
end

-- Startup screen (opens when nvim started with no file args)
local starter = require('mini.starter')

-- Header: NVM logo + version line (like NVchad's logo + version)
local function starter_header()
  local v = vim.version()
  return table.concat({
    '  ███╗   ██╗██╗   ██╗██╗███╗   ███╗',
    '  ████╗  ██║██║   ██║██║████╗ ████║',
    '  ██╔██╗ ██║██║   ██║██║██╔████╔██║',
    '  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║',
    '  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║',
    '  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝',
    '',
    '  nvim v' .. v.major .. '.' .. v.minor .. '.' .. v.patch,
  }, '\n')
end

-- Footer: random quote + date (like NVchad's quote of the day)
local starter_quotes = {
  'Programming is the art of telling another human what one wants the computer to do.',
  'Simplicity is the soul of efficiency.',
  'There are only two hard things in computer science: cache invalidation and naming things.',
  'Talk is cheap. Show me the code.',
  'First, solve the problem. Then, write the code.',
}
local function starter_footer()
  return starter_quotes[math.random(#starter_quotes)] .. '  •  ' .. os.date('%a %b %d')
end

-- Quick actions (like VSCode's New File / Open Folder buttons)
local function starter_quick_actions()
  return {
    { name = 'New file',          action = function() vim.cmd.enew() end,               section = 'Quick' },
    { name = 'Find files',        action = function() MiniPick.builtin.files() end,      section = 'Quick' },
    { name = 'Search in project', action = function() MiniPick.builtin.grep_live() end,  section = 'Quick' },
    { name = 'File explorer',     action = function() MiniFiles.open() end,              section = 'Quick' },
    { name = 'Open session',      action = function() pick_session(false) end,           section = 'Quick' },
  }
end

starter.setup({
  header = starter_header,
  footer = starter_footer,
  evaluate_single = true, -- auto-run once the query narrows to a single item
  items = {
    starter_quick_actions,
    starter.sections.recent_files(5, false),
    sessions_section,
    starter.sections.builtin_actions(),
  },
  content_hooks = {
    starter.gen_hook.padding(3, 2),                          -- breathing room around the content
    starter.gen_hook.indexing('all', { 'Builtin actions' }), -- numbered list; type the number to jump
    starter.gen_hook.adding_bullet(),                        -- keep the "░ " bullets
    starter.gen_hook.aligning('center', 'center'),           -- keep the centered layout
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

-- Handle first-time async installs
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.kind ~= 'install' then return end
    local name = ev.data.spec.name
    if name == 'nvim-treesitter' then
      setup_treesitter()
    elseif name == 'render-markdown.nvim' then
      pcall(function() require('render-markdown').setup() end)
    end
  end,
})

-- rainbow-delimiters config (must be set before the plugin loads)
vim.g.rainbow_delimiters = {
  highlight = {
    'RainbowDelimiterRed',
    'RainbowDelimiterYellow',
    'RainbowDelimiterBlue',
    'RainbowDelimiterOrange',
    'RainbowDelimiterGreen',
    'RainbowDelimiterViolet',
    'RainbowDelimiterCyan',
  },
}

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.pack.add({
      'https://github.com/nvim-treesitter/nvim-treesitter',
      'https://github.com/MeanderingProgrammer/render-markdown.nvim',
      'https://github.com/hiphish/rainbow-delimiters.nvim',
      'https://github.com/wakatime/vim-wakatime',
    })
    if pcall(require, 'nvim-treesitter.configs') then setup_treesitter() end
    if pcall(require, 'render-markdown') then require('render-markdown').setup() end
  end,
})
