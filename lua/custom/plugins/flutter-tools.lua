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

    -- Command for Dev
    vim.api.nvim_create_user_command(
      'FlutterRunDev',
      function()
        require('flutter-tools.commands').run {
          args = { '--flavor', 'dev' },
        }
      end,
      {}
    )

    -- Command for Prod
    vim.api.nvim_create_user_command(
      'FlutterRunProd',
      function()
        require('flutter-tools.commands').run {
          args = { '--flavor', 'prod' },
        }
      end,
      {}
    )
  end,
}
