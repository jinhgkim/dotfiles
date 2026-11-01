-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

require('neo-tree').setup {
  filesystem = {
    -- refresh the tree when files change outside Neovim (e.g. Claude Code edits)
    use_libuv_file_watcher = true,
    filtered_items = {
      visible = true,
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}
