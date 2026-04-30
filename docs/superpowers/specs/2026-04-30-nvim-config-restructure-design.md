# Neovim Config Restructure — Design Spec
_2026-04-30_

## Goal

Reorganize a kickstart-derived Neovim config into a clean, flat structure where every file has exactly one purpose, plugin installation is uniform, and all kickstart scaffolding noise is removed.

---

## Directory Structure

```
~/.config/nvim/
├── init.lua
└── lua/
    ├── config/
    │   ├── options.lua
    │   ├── keymaps.lua
    │   └── autocommands.lua
    └── plugins/
        ├── blink.lua
        ├── conform.lua
        ├── flutter.lua
        ├── gitsigns.lua
        ├── guess-indent.lua
        ├── lsp.lua
        ├── mini.lua
        ├── neo-tree.lua
        ├── renpy.lua
        ├── snacks.lua
        ├── spectre.lua
        ├── telescope.lua
        ├── todo-comments.lua
        ├── tokyonight.lua
        ├── transparent.lua
        ├── treesitter.lua
        ├── which-key.lua
        └── yazi.lua
```

---

## File Responsibilities

### `init.lua`
- Set `vim.g.mapleader` and `vim.g.maplocalleader` (must happen before lazy loads)
- `require 'config.options'`
- `require 'config.keymaps'`
- `require 'config.autocommands'`
- Bootstrap lazy.nvim (clone if missing, prepend to rtp)
- Call `require('lazy').setup({ { import = 'plugins' } }, { ui = { ... } })`

Nothing else. No plugin specs inline.

### `lua/config/options.lua`
- All `vim.o` / `vim.opt` / `vim.g` settings
- `vim.g.have_nerd_font` global
- `vim.diagnostic.config(...)` (moved here from keymaps.lua — it is editor config, not a keymap)

### `lua/config/keymaps.lua`
- Global keymaps only: window navigation, search clear, arrow key guards, terminal escape, cd shortcuts
- No plugin-specific keymaps
- No `vim.diagnostic.config`

### `lua/config/autocommands.lua`
- All `vim.api.nvim_create_autocmd` calls that are not tied to a specific plugin

### `lua/plugins/*.lua` — Plugin Convention

Every plugin file:
- Returns a single `LazySpec` (one plugin, or a single-element table)
- Plugin keymaps defined via `keys = {}` in the spec (not `vim.keymap.set` inside `config`)
- Use `opts = {}` when no custom logic is needed
- Use `config = function()` only when setup requires logic beyond a simple options table

---

## Migration Details

### Flattening
- `lua/custom/` namespace removed; files move to `lua/config/` or `lua/plugins/`
- `lua/custom/plugins/auto/` subdirectory removed; all files move up to `lua/plugins/`
- `lua/kickstart/` directory removed entirely

### neo-tree
- Moves from `lua/kickstart/plugins/neo-tree.lua` to `lua/plugins/neo-tree.lua`
- The `require 'kickstart.plugins.neo-tree'` inline spec in init.lua becomes part of the `{ import = 'plugins' }` import

### renpy.lua
Currently does three things: `vim.filetype.add`, `vim.lsp.config('pyright', ...)`, and returns a plugin spec.

After: the filetype mapping and LSP override move into the plugin spec's `config` function. The file returns one plugin spec for `inzoiniac/renpy-syntax.nvim` with all renpy-related setup inside it.

### Removed/dropped
- `lua/custom/plugins/init.lua` — empty stub, no purpose
- `nvim-base16` plugin entry — `enabled = false` with no config; just deleted
- All kickstart tutorial comments stripped from plugin files
- `lua/kickstart/plugins/autopairs.lua`, `debug.lua`, `gitsigns.lua`, `indent_line.lua`, `lint.lua` — all inactive, deleted

### matugen
- `lua/custom/matugen.lua` moves to `lua/config/matugen.lua`
- Not auto-loaded (user uncomments when needed), same as current behavior

---

## Keymap Convention Summary

| Type | Location |
|------|----------|
| Plugin-specific keymaps | `keys = {}` inside the plugin's spec file |
| Global/editor keymaps | `lua/config/keymaps.lua` |
| LSP buffer keymaps | Inside `lsp.lua` config function (LspAttach autocmd) — these are buffer-local and dynamic |
| Telescope LSP keymaps | Inside `telescope.lua` config function (LspAttach autocmd) — same reason |

LSP and Telescope buffer-local keymaps stay in their `config` functions because they are set dynamically per-buffer on `LspAttach`, not statically — `keys = {}` does not support this pattern.

---

## Invariants

- Leader key is set in `init.lua` before any `require`
- `lua/config/options.lua` is sourced before lazy loads plugins
- Every `lua/plugins/*.lua` file is auto-discovered via `{ import = 'plugins' }`
- No plugin spec lives in `init.lua`
- No global keymap lives inside a plugin file
