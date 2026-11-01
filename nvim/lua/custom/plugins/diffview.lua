-- Review all changed files side by side (maintained fork of diffview.nvim)
-- https://github.com/dlyongemallo/diffview-plus.nvim

-- Its tags (e.g. v0.39) aren't full semver, so vim.pack can't match a version range; track main instead.
vim.pack.add {
  { src = 'https://github.com/dlyongemallo/diffview-plus.nvim', version = 'main' },
}

require('diffview').setup {}

vim.keymap.set('n', '<leader>gd', '<Cmd>DiffviewToggle<CR>', { desc = '[G]it [D]iff view (toggle)' })
vim.keymap.set('n', '<leader>gh', '<Cmd>DiffviewFileHistory %<CR>', { desc = '[G]it file [H]istory' })
