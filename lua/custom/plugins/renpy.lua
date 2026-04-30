-- 1. Map .rpy files to the python filetype
vim.filetype.add {
  extension = {
    rpy = 'python',
  },
}

-- 2. Configure Pyright to recognize .rpy files
-- Assuming you use 'nvim-lspconfig'
vim.lsp.config('pyright', {
  filetypes = { 'python', 'rpy' }, -- Add rpy to supported types
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

return {
  {
    'inzoiniac/renpy-syntax.nvim',
    config = function() require('renpy-syntax').setup() end,
  },
}
