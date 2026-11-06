-- Git commands inside Neovim (:Git commit, :Git rebase -i, git aliases, ...)
-- https://github.com/tpope/vim-fugitive

-- Its tags (e.g. v3.7) aren't full semver, so vim.pack can't match a version range; track master instead.
-- vim-rhubarb lets :GBrowse build GitHub URLs; it has no tags at all.
vim.pack.add {
  { src = 'https://github.com/tpope/vim-fugitive', version = 'master' },
  { src = 'https://github.com/tpope/vim-rhubarb', version = 'master' },
}

vim.keymap.set('n', '<leader>gg', '<Cmd>Git<CR>', { desc = '[G]it status (fugitive)' })

-- Open the upstream OIIO PR that last touched the line under the cursor.
vim.keymap.set('n', '<leader>go', function()
  local file = vim.fn.expand '%:p'
  local line = vim.fn.line '.'
  local dir = vim.fn.expand '%:p:h'
  local cmd = { 'git', '-C', dir, 'blame', '--porcelain', '-L', line .. ',' .. line }
  -- Skip bulk-reformat commits the same way gitsigns' blame popup does.
  local toplevel = vim.trim(vim.fn.system { 'git', '-C', dir, 'rev-parse', '--show-toplevel' })
  local ignore_file = toplevel .. '/.git-blame-ignore-revs'
  if vim.uv.fs_stat(ignore_file) then
    vim.list_extend(cmd, { '--ignore-revs-file', ignore_file })
  end
  vim.list_extend(cmd, { '--', file })
  local out = vim.fn.systemlist(cmd)
  local sha = out[1] and out[1]:match '^(%x+)'
  if not sha or sha:match '^0+$' then
    return vim.notify 'Line is not committed yet'
  end
  local url = vim.fn.system { 'gh', 'pr', 'list', '-R', 'AcademySoftwareFoundation/OpenImageIO', '--state', 'merged', '--search', sha, '--json', 'url', '--jq', '.[0].url' }
  url = url:gsub('%s+$', '')
  if url == '' then -- no PR found: fall back to the commit page
    url = 'https://github.com/AcademySoftwareFoundation/OpenImageIO/commit/' .. sha
  end
  vim.ui.open(url)
end, { desc = '[G]it [o]pen PR for line' })
