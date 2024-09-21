-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- local formatOpts = vim.api.nvim_create_augroup("FormatOpts", { clear = true })
-- vim.api.nvim_create_autocmd("BufEnter", {
--   group = formatOpts,
--   pattern = "*",
--   callback = function()
--     vim.opt.formatoptions:remove({ "c", "r", "o" })
--   end,
-- })
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "python" },
  callback = function()
    vim.b.autoformat = false
  end,
})
