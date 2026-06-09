-- SPDX-FileCopyrightText: Tim Sutton
-- SPDX-License-Identifier: MIT
--
-- Project-specific Neovim configuration for InfrastructureMapper.
-- Loaded automatically when Neovim is launched from the repo root and
-- the global config has 'exrc' enabled (vim.o.exrc = true).
--
-- Conventions:
--   * 4-space indent for SQL and Python (matches black + sqlfluff).
--   * 2-space indent for YAML, Markdown, Nix.
--   * Line length is informational only — sqlfluff/black/markdownlint
--     decide what actually breaks CI, see .sqlfluff / pyproject style /
--     .markdownlint.yaml.

vim.o.fileformat = 'unix'
vim.o.fileencoding = 'utf-8'
vim.o.expandtab = true
vim.o.smartindent = true

-- Filetype-specific indent and behaviour.
local ft_group = vim.api.nvim_create_augroup('InfrastructureMapperFiletypes', { clear = true })

local function set_indent(filetypes, width)
  vim.api.nvim_create_autocmd('FileType', {
    group = ft_group,
    pattern = filetypes,
    callback = function()
      vim.bo.tabstop = width
      vim.bo.shiftwidth = width
      vim.bo.softtabstop = width
      vim.bo.expandtab = true
    end,
  })
end

set_indent({ 'sql', 'python' }, 4)
set_indent({ 'yaml', 'markdown', 'nix', 'json' }, 2)
set_indent({ 'sh', 'bash' }, 4)

-- Set colorcolumn as a visual hint at 100; we don't hard-wrap.
vim.api.nvim_create_autocmd('FileType', {
  group = ft_group,
  pattern = { 'sql', 'python', 'sh', 'bash', 'lua' },
  callback = function()
    vim.wo.colorcolumn = '100'
  end,
})

-- Quick filetype detections for files we author.
vim.filetype.add({
  filename = {
    ['VERSION'] = 'conf',
    ['cspell.config.yaml'] = 'yaml',
    ['.markdownlint.yaml'] = 'yaml',
  },
  pattern = {
    ['sql/migrations/.*/v.*%.sql'] = 'sql',
    ['sql/migrations/.*/UNRELEASED%.sql'] = 'sql',
  },
})

-- Auto-trim trailing whitespace on save for our authored file types.
-- (Pre-commit will fix it anyway; this avoids the dirty-diff round-trip.)
vim.api.nvim_create_autocmd('BufWritePre', {
  group = ft_group,
  pattern = { '*.sql', '*.py', '*.sh', '*.md', '*.yaml', '*.yml', '*.nix' },
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[silent! %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- Print a tiny welcome banner so the project bindings are discoverable.
vim.schedule(function()
  if vim.fn.argc() == 0 then
    vim.api.nvim_echo({
      { '[InfrastructureMapper] ', 'Title' },
      { 'Project bindings live under ', 'Normal' },
      { '<leader>p', 'Keyword' },
      { '. See ', 'Normal' },
      { '.exrc', 'String' },
      { ' or ', 'Normal' },
      { ':help which-key', 'String' },
      { '.', 'Normal' },
    }, false, {})
  end
end)
