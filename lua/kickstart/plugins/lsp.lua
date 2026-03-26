return {
  -- main lsp configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    -- automatically install lsps and related tools to stdpath for neovim
    -- mason must be loaded before its dependents so we need to set it up here.
    -- note: `opts = {}` is the same as calling `require('mason').setup({})`
    {
      'mason-org/mason.nvim',
      ---@module 'mason.settings'
      ---@type masonsettings
      ---@diagnostic disable-next-line: missing-fields
      opts = {},
    },
    -- maps lsp server names between nvim-lspconfig and mason package names.
    'mason-org/mason-lspconfig.nvim',
    'whoissethdaniel/mason-tool-installer.nvim',

    -- useful status updates for lsp.
    { 'j-hui/fidget.nvim', opts = {} },

    -- allows extra capabilities provided by blink.cmp
    'saghen/blink.cmp',
  },
  config = function()
    -- brief aside: **what is lsp?**
    --
    -- lsp is an initialism you've probably heard, but might not understand what it is.
    --
    -- lsp stands for language server protocol. it's a protocol that helps editors
    -- and language tooling communicate in a standardized fashion.
    --
    -- in general, you have a "server" which is some tool built to understand a particular
    -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). these language servers
    -- (sometimes called lsp servers, but that's kind of like atm machine) are standalone
    -- processes that communicate with some "client" - in this case, neovim!
    --
    -- lsp provides neovim with features like:
    --  - go to definition
    --  - find references
    --  - autocompletion
    --  - symbol search
    --  - and more!
    --
    -- thus, language servers are external tools that must be installed separately from
    -- neovim. this is where `mason` and related plugins come into play.
    --
    -- if you're wondering about lsp vs treesitter, you can check out the wonderfully
    -- and elegantly composed help section, `:help lsp-vs-treesitter`

    --  this function gets run when an lsp attaches to a particular buffer.
    --    that is to say, every time a new file is opened that is associated with
    --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
    --    function will be executed to configure the current buffer
    vim.api.nvim_create_autocmd('lspattach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- note: remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself.
        --
        -- in this case, we create a function that lets us more easily define mappings specific
        -- for lsp related items. it sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'lsp: ' .. desc })
        end

        -- rename the variable under your cursor.
        --  most language servers support renaming across files, etc.
        map('grn', vim.lsp.buf.rename, '[r]e[n]ame')

        -- execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your lsp for this to activate.
        map('gra', vim.lsp.buf.code_action, '[g]oto code [a]ction', { 'n', 'x' })

        -- warn: this is not goto definition, this is goto declaration.
        --  for example, in c this would take you to the header.
        map('grd', vim.lsp.buf.declaration, '[g]oto [d]eclaration')

        -- the following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    see `:help cursorhold` for information about when this is executed
        --
        -- when you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method('textdocument/documenthighlight', event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'cursorhold', 'cursorholdi' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'cursormoved', 'cursormovedi' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('lspdetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- the following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- this may be unwanted, since they displace some of your code
        if client and client:supports_method('textdocument/inlayhint', event.buf) then
          map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[t]oggle inlay [h]ints')
        end
      end,
    })

    -- enable the following language servers
    --  feel free to add/remove any lsps that you want here. they will automatically be installed.
    --  see `:help lsp-config` for information about keys and how to configure
    ---@type table<string, vim.lsp.config>
    local servers = {
      -- clangd = {},
      -- gopls = {},
      -- pyright = {},
      -- rust_analyzer = {},
      --
      -- some languages (like typescript) have entire language plugins that can be useful:
      --    https://github.com/pmizio/typescript-tools.nvim
      --
      -- but for many setups, the lsp (`ts_ls`) will work just fine
      -- ts_ls = {},

      stylua = {}, -- used to format lua code

      -- special lua config, as recommended by neovim help docs
      lua_ls = {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
          end

          client.config.settings.lua = vim.tbl_deep_extend('force', client.config.settings.lua, {
            runtime = {
              version = 'luajit',
              path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            workspace = {
              checkthirdparty = false,
              -- note: this is a lot slower and will cause issues when working on your own configuration.
              --  see https://github.com/neovim/nvim-lspconfig/issues/3189
              library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                '${3rd}/luv/library',
                '${3rd}/busted/library',
              }),
            },
          })
        end,
        settings = {
          lua = {},
        },
      },
    }

    -- ensure the servers and tools above are installed
    --
    -- to check the current status of installed tools and/or manually install
    -- other tools, you can run
    --    :mason
    --
    -- you can press `g?` for help in this menu.
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      -- you can add other tools here that you want mason to install
    })

    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    for name, server in pairs(servers) do
      vim.lsp.config(name, server)
      vim.lsp.enable(name)
    end
  end,
}
