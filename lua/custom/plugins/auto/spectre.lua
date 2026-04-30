return {
  'nvim-pack/nvim-spectre',
  event = 'VeryLazy',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function(_, opts)
    require('spectre').setup(opts)

    -- Toggle Spectre
    vim.keymap.set('n', '<leader>P', '<cmd>lua require("spectre").toggle()<CR>', {
      desc = 'Toggle Spectre',
    })

    -- Search current word (Normal mode)
    vim.keymap.set('n', '<leader>pw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
      desc = 'Search current word',
    })

    -- Search current word (Visual mode)
    vim.keymap.set('v', '<leader>pw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
      desc = 'Search current word',
    })

    -- Search on current file
    vim.keymap.set('n', '<leader>pp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
      desc = 'Search on current file',
    })
  end,
}
