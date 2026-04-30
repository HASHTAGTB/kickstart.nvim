# Neovim Config Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flatten a kickstart-derived Neovim config into a clean structure with `lua/config/` for editor settings and `lua/plugins/` with one file per plugin, all using uniform lazy.nvim spec conventions.

**Architecture:** Create all new files first (phases 1–2), then swap `init.lua` to point at the new paths (phase 3), verify, then delete the old tree (phase 4). This keeps the config working at every step.

**Tech Stack:** Neovim, lazy.nvim, Lua

---

## File Map

**Create:**
- `lua/config/options.lua` — all `vim.o`/`vim.g` settings + `vim.diagnostic.config`
- `lua/config/keymaps.lua` — global keymaps only
- `lua/config/autocommands.lua` — global autocommands
- `lua/config/matugen.lua` — copy of current matugen, not auto-loaded
- `lua/plugins/blink.lua` — blink.cmp completion
- `lua/plugins/conform.lua` — conform.nvim formatting
- `lua/plugins/flutter.lua` — flutter-tools
- `lua/plugins/gitsigns.lua` — gitsigns
- `lua/plugins/guess-indent.lua` — guess-indent (was inline in init.lua)
- `lua/plugins/lsp.lua` — nvim-lspconfig + mason stack
- `lua/plugins/mini.lua` — mini.nvim
- `lua/plugins/neo-tree.lua` — neo-tree (from kickstart/)
- `lua/plugins/renpy.lua` — renpy syntax + filetype/LSP side effects consolidated
- `lua/plugins/snacks.lua` — snacks.nvim (image support)
- `lua/plugins/spectre.lua` — spectre (keymaps moved to keys={})
- `lua/plugins/telescope.lua` — telescope (static keymaps to keys={}, LspAttach stays in config)
- `lua/plugins/todo-comments.lua` — todo-comments (split from ui.lua)
- `lua/plugins/tokyonight.lua` — tokyonight colorscheme (split from ui.lua)
- `lua/plugins/transparent.lua` — transparent.nvim (was inline in init.lua)
- `lua/plugins/treesitter.lua` — treesitter
- `lua/plugins/which-key.lua` — which-key
- `lua/plugins/yazi.lua` — yazi

**Modify:**
- `init.lua` — rewrite to bootstrap only, source config/, import plugins/

**Delete:**
- `lua/custom/` — entire directory
- `lua/kickstart/` — entire directory

---

### Task 1: Create `lua/config/options.lua`

**Files:**
- Create: `lua/config/options.lua`

- [ ] **Step 1: Create the file**

```lua
-- lua/config/options.lua
vim.g.have_nerd_font = false

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  virtual_lines = false,
  jump = { float = true },
}
```

- [ ] **Step 2: Commit**

```bash
git add lua/config/options.lua
git commit -m "feat: add lua/config/options.lua"
```

---

### Task 2: Create `lua/config/keymaps.lua`

**Files:**
- Create: `lua/config/keymaps.lua`

- [ ] **Step 1: Create the file**

`vim.diagnostic.config` is NOT included here — it moved to `options.lua`.

```lua
-- lua/config/keymaps.lua
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>gt', '<cmd>cd /mnt/ntfs/HTB/Documents/txt/<cr>', { desc = '[G]o to [T]xt folder' })
vim.keymap.set('n', '<leader>gg', '<cmd>cd /home/htb/Documents/Obsidian Vault/<cr>', { desc = '[G]o to Obsidian vault' })
vim.keymap.set('n', '<leader>gh', '<cmd>cd ~<cr>', { desc = '[G]o to [H]ome' })
vim.keymap.set('n', '<leader>gc', '<cmd>cd ~/.config<cr>', { desc = '[G]o to [C]onfig' })
vim.keymap.set('n', '<leader>gd', '<cmd>cd ~/Documents/code/<cr>', { desc = '[G]o to co[D]e' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
```

- [ ] **Step 2: Commit**

```bash
git add lua/config/keymaps.lua
git commit -m "feat: add lua/config/keymaps.lua"
```

---

### Task 3: Create `lua/config/autocommands.lua` and `lua/config/matugen.lua`

**Files:**
- Create: `lua/config/autocommands.lua`
- Create: `lua/config/matugen.lua`

- [ ] **Step 1: Create autocommands.lua**

```lua
-- lua/config/autocommands.lua
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})
```

- [ ] **Step 2: Copy matugen.lua to new location**

```bash
cp lua/custom/matugen.lua lua/config/matugen.lua
```

- [ ] **Step 3: Commit**

```bash
git add lua/config/autocommands.lua lua/config/matugen.lua
git commit -m "feat: add lua/config/autocommands.lua and matugen.lua"
```

---

### Task 4: Create trivial plugin files

These plugins need no logic changes — just copy to the new path and clean up tutorial comments.

**Files:**
- Create: `lua/plugins/gitsigns.lua`
- Create: `lua/plugins/guess-indent.lua`
- Create: `lua/plugins/mini.lua`
- Create: `lua/plugins/snacks.lua`
- Create: `lua/plugins/todo-comments.lua`
- Create: `lua/plugins/transparent.lua`
- Create: `lua/plugins/treesitter.lua`
- Create: `lua/plugins/which-key.lua`
- Create: `lua/plugins/yazi.lua`

- [ ] **Step 1: Create `lua/plugins/gitsigns.lua`**

```lua
return {
  'lewis6991/gitsigns.nvim',
  ---@module 'gitsigns'
  ---@type Gitsigns.Config
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    signs = {
      add = { text = '+' }, ---@diagnostic disable-line: missing-fields
      change = { text = '~' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
    },
  },
}
```

- [ ] **Step 2: Create `lua/plugins/guess-indent.lua`**

```lua
return { 'NMAC427/guess-indent.nvim', opts = {} }
```

- [ ] **Step 3: Create `lua/plugins/mini.lua`**

```lua
return {
  'nvim-mini/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup()
    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function() return '%2l:%-2v' end
  end,
}
```

- [ ] **Step 4: Create `lua/plugins/snacks.lua`**

```lua
return {
  'folke/snacks.nvim',
  ---@type snacks.Config
  opts = {
    image = {},
  },
}
```

- [ ] **Step 5: Create `lua/plugins/todo-comments.lua`**

```lua
return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  ---@module 'todo-comments'
  ---@type TodoOptions
  ---@diagnostic disable-next-line: missing-fields
  opts = { signs = false },
}
```

- [ ] **Step 6: Create `lua/plugins/transparent.lua`**

```lua
return { 'xiyaowong/transparent.nvim', opts = {} }
```

- [ ] **Step 7: Create `lua/plugins/treesitter.lua`**

```lua
return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  branch = 'main',
  config = function()
    local parsers = {
      'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline',
      'query', 'vim', 'vimdoc', 'svelte', 'javascript', 'typescript', 'css',
    }
    require('nvim-treesitter').install(parsers)
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        local buf, filetype = args.buf, args.match
        local language = vim.treesitter.language.get_lang(filetype)
        if not language then return end
        if not vim.treesitter.language.add(language) then return end
        vim.treesitter.start(buf, language)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
```

- [ ] **Step 8: Create `lua/plugins/which-key.lua`**

```lua
return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  ---@module 'which-key'
  ---@type wk.Opts
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
    },
  },
}
```

- [ ] **Step 9: Create `lua/plugins/yazi.lua`**

```lua
---@type LazySpec
return {
  'mikavilpas/yazi.nvim',
  version = '*',
  event = 'VeryLazy',
  dependencies = {
    { 'nvim-lua/plenary.nvim', lazy = true },
  },
  keys = {
    { '<leader>y', '<cmd>Yazi<cr>', mode = { 'n', 'v' }, desc = 'Open yazi at the current file' },
    { '<leader>Y', '<cmd>Yazi cwd<cr>', desc = "Open yazi in nvim's working directory" },
    { '<leader>-', '<cmd>Yazi toggle<cr>', desc = 'Resume the last yazi session' },
  },
  ---@type YaziConfig | {}
  opts = {
    open_for_directories = false,
    keymaps = { show_help = '<f1>' },
  },
  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
}
```

- [ ] **Step 10: Commit**

```bash
git add lua/plugins/
git commit -m "feat: add trivial plugin files to lua/plugins/"
```

---

### Task 5: Create `lua/plugins/tokyonight.lua`

**Files:**
- Create: `lua/plugins/tokyonight.lua`

- [ ] **Step 1: Create the file**

`nvim-base16` (which was `enabled = false`) is dropped — not needed.

```lua
return {
  'folke/tokyonight.nvim',
  priority = 1000,
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('tokyonight').setup {
      styles = { comments = { italic = false } },
    }
    vim.cmd.colorscheme 'tokyonight-night'
  end,
}
```

- [ ] **Step 2: Commit**

```bash
git add lua/plugins/tokyonight.lua
git commit -m "feat: add lua/plugins/tokyonight.lua"
```

---

### Task 6: Create `lua/plugins/neo-tree.lua`

**Files:**
- Create: `lua/plugins/neo-tree.lua`

- [ ] **Step 1: Create the file**

Content is identical to the current `lua/kickstart/plugins/neo-tree.lua`.

```lua
---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    filesystem = {
      hijack_netrw_behavior = 'disabled',
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['h'] = 'close_node',
          ['l'] = 'open',
        },
      },
    },
  },
}
```

- [ ] **Step 2: Commit**

```bash
git add lua/plugins/neo-tree.lua
git commit -m "feat: add lua/plugins/neo-tree.lua"
```

---

### Task 7: Create `lua/plugins/conform.lua`

**Files:**
- Create: `lua/plugins/conform.lua`

- [ ] **Step 1: Create the file**

The format keymap was already using `keys = {}` — keep that.

```lua
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function() require('conform').format { async = true, lsp_format = 'fallback' } end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
    },
  },
}
```

- [ ] **Step 2: Commit**

```bash
git add lua/plugins/conform.lua
git commit -m "feat: add lua/plugins/conform.lua"
```

---

### Task 8: Create `lua/plugins/blink.lua`

**Files:**
- Create: `lua/plugins/blink.lua`

- [ ] **Step 1: Create the file**

Strip tutorial comments, keep all config.

```lua
return {
  'saghen/blink.cmp',
  event = 'VimEnter',
  version = '1.*',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      version = '2.*',
      build = (function()
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
        return 'make install_jsregexp'
      end)(),
      opts = {},
    },
  },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'default' },
    appearance = { nerd_font_variant = 'mono' },
    completion = {
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'lua' },
    signature = { enabled = true },
  },
}
```

- [ ] **Step 2: Commit**

```bash
git add lua/plugins/blink.lua
git commit -m "feat: add lua/plugins/blink.lua"
```

---

### Task 9: Create `lua/plugins/flutter.lua`

**Files:**
- Create: `lua/plugins/flutter.lua`

- [ ] **Step 1: Create the file**

No keymaps to move — the user commands stay in `config`.

```lua
return {
  'nvim-flutter/flutter-tools.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim',
  },
  config = function()
    require('flutter-tools').setup {
      flutter_path = vim.fn.expand '~/develop/flutter/bin/flutter',
    }

    vim.api.nvim_create_user_command('FlutterRunDev', function()
      require('flutter-tools.commands').run { args = { '--flavor', 'dev' } }
    end, {})

    vim.api.nvim_create_user_command('FlutterRunProd', function()
      require('flutter-tools.commands').run { args = { '--flavor', 'prod' } }
    end, {})
  end,
}
```

- [ ] **Step 2: Commit**

```bash
git add lua/plugins/flutter.lua
git commit -m "feat: add lua/plugins/flutter.lua"
```

---

### Task 10: Create `lua/plugins/spectre.lua`

**Files:**
- Create: `lua/plugins/spectre.lua`

- [ ] **Step 1: Create the file**

Keymaps move from `config = function()` to `keys = {}`. `opts = {}` replaces the explicit `setup()` call.

```lua
return {
  'nvim-pack/nvim-spectre',
  event = 'VeryLazy',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {},
  keys = {
    { '<leader>P', function() require('spectre').toggle() end, desc = 'Toggle Spectre' },
    { '<leader>pw', function() require('spectre').open_visual { select_word = true } end, desc = 'Search current word' },
    { '<leader>pw', function() require('spectre').open_visual() end, mode = 'v', desc = 'Search current word' },
    { '<leader>pp', function() require('spectre').open_file_search { select_word = true } end, desc = 'Search on current file' },
  },
}
```

- [ ] **Step 2: Commit**

```bash
git add lua/plugins/spectre.lua
git commit -m "feat: add lua/plugins/spectre.lua with keys={}"
```

---

### Task 11: Create `lua/plugins/renpy.lua`

**Files:**
- Create: `lua/plugins/renpy.lua`

- [ ] **Step 1: Create the file**

The three responsibilities (`vim.filetype.add`, `vim.lsp.config`, `require('renpy-syntax').setup()`) are all consolidated into the single `config` function. The file now has one purpose: configure renpy support.

```lua
return {
  'inzoiniac/renpy-syntax.nvim',
  config = function()
    vim.filetype.add {
      extension = { rpy = 'python' },
    }

    vim.lsp.config('pyright', {
      filetypes = { 'python', 'rpy' },
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = 'workspace',
          },
        },
      },
    })

    require('renpy-syntax').setup()
  end,
}
```

- [ ] **Step 2: Commit**

```bash
git add lua/plugins/renpy.lua
git commit -m "feat: add lua/plugins/renpy.lua (consolidated)"
```

---

### Task 12: Create `lua/plugins/telescope.lua`

**Files:**
- Create: `lua/plugins/telescope.lua`

- [ ] **Step 1: Create the file**

Static global keymaps move to `keys = {}`. The `config` function now only contains: `setup()`, `load_extension` calls, and the `LspAttach` block (buffer-local keymaps cannot use `keys = {}`).

```lua
return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function() return vim.fn.executable 'make' == 1 end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  keys = {
    { '<leader>sh', function() require('telescope.builtin').help_tags() end, desc = '[S]earch [H]elp' },
    { '<leader>sk', function() require('telescope.builtin').keymaps() end, desc = '[S]earch [K]eymaps' },
    { '<leader>sf', function() require('telescope.builtin').find_files() end, desc = '[S]earch [F]iles' },
    { '<leader>sC', function() require('telescope.builtin').find_files { cwd = '/home/htb/.config/' } end, desc = '[S]earch [C]onfig' },
    { '<leader>sH', function() require('telescope.builtin').find_files { cwd = '/home/htb/' } end, desc = '[S]earch [H]ome' },
    { '<leader>ss', function() require('telescope.builtin').builtin() end, desc = '[S]earch [S]elect Telescope' },
    { '<leader>sw', function() require('telescope.builtin').grep_string() end, mode = { 'n', 'v' }, desc = '[S]earch current [W]ord' },
    { '<leader>sg', function() require('telescope.builtin').live_grep() end, desc = '[S]earch by [G]rep' },
    { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', function() require('telescope.builtin').resume() end, desc = '[S]earch [R]esume' },
    { '<leader>s.', function() require('telescope.builtin').oldfiles() end, desc = '[S]earch Recent Files' },
    { '<leader>sc', function() require('telescope.builtin').commands() end, desc = '[S]earch [C]ommands' },
    { '<leader><leader>', function() require('telescope.builtin').buffers() end, desc = '[ ] Find existing buffers' },
    {
      '<leader>/',
      function()
        require('telescope.builtin').current_buffer_fuzzy_find(
          require('telescope.themes').get_dropdown { winblend = 10, previewer = false }
        )
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      '<leader>s/',
      function()
        require('telescope.builtin').live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end,
      desc = '[S]earch [/] in Open Files',
    },
    { '<leader>sn', function() require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' } end, desc = '[S]earch [N]eovim files' },
    { '<leader>st', function() require('telescope.builtin').find_files { cwd = '/mnt/ntfs/HTB/Documents/txt/' } end, desc = '[S]earch [T]ext Folder' },
  },
  config = function()
    require('telescope').setup {
      extensions = {
        ['ui-select'] = { require('telescope.themes').get_dropdown() },
      },
    }
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
      callback = function(event)
        local buf = event.buf
        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
        vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
        vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
        vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
        vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
        vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
      end,
    })
  end,
}
```

- [ ] **Step 2: Commit**

```bash
git add lua/plugins/telescope.lua
git commit -m "feat: add lua/plugins/telescope.lua with keys={} for static keymaps"
```

---

### Task 13: Create `lua/plugins/lsp.lua`

**Files:**
- Create: `lua/plugins/lsp.lua`

- [ ] **Step 1: Create the file**

Strip all tutorial comments. LspAttach keymaps stay in `config` (buffer-local, dynamic — cannot use `keys = {}`).

```lua
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method('textDocument/documentHighlight', event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client:supports_method('textDocument/inlayHint', event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    local servers = {
      pyright = {},
      svelte = {},
      stylua = {},
      lua_ls = {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath 'config'
              and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
            then
              return
            end
          end
          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
              path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            workspace = {
              checkThirdParty = false,
              library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                '${3rd}/luv/library',
                '${3rd}/busted/library',
              }),
            },
          })
        end,
        settings = { Lua = {} },
      },
    }

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {})
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    for name, server in pairs(servers) do
      vim.lsp.config(name, server)
      vim.lsp.enable(name)
    end
  end,
}
```

- [ ] **Step 2: Commit**

```bash
git add lua/plugins/lsp.lua
git commit -m "feat: add lua/plugins/lsp.lua (stripped comments)"
```

---

### Task 14: Rewrite `init.lua`

**Files:**
- Modify: `init.lua`

All new `lua/config/` and `lua/plugins/` files are now in place. Switch `init.lua` to point at them.

- [ ] **Step 1: Back up the current init.lua**

```bash
cp init.lua init.lua.bak2
```

- [ ] **Step 2: Rewrite `init.lua`**

```lua
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'config.options'
require 'config.keymaps'
require 'config.autocommands'

-- uncomment to load matugen theme
-- require 'config.matugen'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙',
      keys = '🗝', plugin = '🔌', runtime = '💻', require = '🌙',
      source = '📄', start = '🚀', task = '📌', lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
```

- [ ] **Step 3: Verify nvim starts without errors**

Open nvim:
```bash
nvim
```

Expected: nvim opens cleanly. Run `:Lazy` — all plugins should show as installed (no red errors). Run `:checkhealth` and scan for unexpected failures.

If there are errors: check `:messages` for the Lua traceback, fix the relevant plugin file, and repeat.

- [ ] **Step 4: Commit**

```bash
git add init.lua
git commit -m "refactor: rewrite init.lua to use lua/config/ and lua/plugins/"
```

---

### Task 15: Delete old directories

Only do this after Task 14 verification passes — nvim starts cleanly with the new init.lua.

**Files:**
- Delete: `lua/custom/` (entire directory)
- Delete: `lua/kickstart/` (entire directory)
- Delete: `init.lua.backup` (old backup from before this refactor)
- Delete: `init.lua.bak2` (backup created in Task 14)

- [ ] **Step 1: Remove old directories and stale backups**

```bash
rm -rf lua/custom/ lua/kickstart/ init.lua.backup init.lua.bak2
```

- [ ] **Step 2: Verify nvim still starts cleanly**

```bash
nvim
```

Expected: nvim opens cleanly. Run `:Lazy` — no errors. The `lua/custom/` and `lua/kickstart/` paths no longer exist but nothing references them.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: remove lua/custom/ and lua/kickstart/ after restructure"
```

---

## Self-Review

**Spec coverage:**
- ✅ Flatten `lua/custom/` → `lua/config/` + `lua/plugins/`
- ✅ One plugin per file in `lua/plugins/`
- ✅ `init.lua` is bootstrap-only
- ✅ `vim.diagnostic.config` moved to `options.lua`
- ✅ `renpy.lua` consolidated (3 responsibilities → 1 file, 1 config block)
- ✅ `nvim-base16` (enabled=false) dropped
- ✅ Kickstart dead files removed
- ✅ `custom/plugins/init.lua` empty stub removed (deleted with custom/)
- ✅ `matugen.lua` at `lua/config/matugen.lua`, not auto-loaded
- ✅ Plugin keymaps via `keys = {}` (spectre, telescope static, yazi, conform, neo-tree)
- ✅ LspAttach keymaps stay in `config` (lsp.lua, telescope.lua) — per spec exception
- ✅ `guess-indent` and `transparent` extracted from inline init.lua to their own files

**No placeholders found.**

**Type/name consistency:** All `require()` calls match the plugin names used in `dependencies`. `renpy-syntax` setup call matches the plugin's module name as in the original.
