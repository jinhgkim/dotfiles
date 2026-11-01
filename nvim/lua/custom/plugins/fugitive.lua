-- Git commands inside Neovim (:Git commit, :Git rebase -i, git aliases, ...)
-- https://github.com/tpope/vim-fugitive

-- Its tags (e.g. v3.7) aren't full semver, so vim.pack can't match a version range; track master instead.
vim.pack.add {
  { src = 'https://github.com/tpope/vim-fugitive', version = 'master' },
}

vim.keymap.set('n', '<leader>gg', '<Cmd>Git<CR>', { desc = '[G]it status (fugitive)' })
