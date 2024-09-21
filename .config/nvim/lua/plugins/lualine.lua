local comp = function() end
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto",
      disabled_filetypes = {
        globalstatus = vim.o.laststatus == 3,
        -- globalstatus = false,
        statusline = { "neo-tree", "dashboard", "alpha", "ministarter" },
        winbar = { "neo-tree", "dashboard", "alpha", "ministarter" },
      },
    },
    sections = {},
    -- winbar = {
    --   lualine_a = {
    --     {
    --       "buffers",
    --       symbols = {
    --         modified = " ●", -- Text to show when the buffer is modified
    --         alternate_file = "", -- Text to show to identify the alternate file
    --         directory = "", -- Text to show when the buffer is a directory
    --       },
    --     },
    --   },
    --   lualine_z = {
    --     function()
    --       -- get value of VIRTUAL_ENV variable if it exists
    --       local venv = vim.env.VIRTUAL_ENV
    --       if venv then
    --         -- return only the basename of the path
    --         venv = vim.fn.fnamemodify(venv, ":t")
    --         return string.format("  %s ", venv)
    --       end
    --     end,
    --   },
    -- },
    inactive_winbar = {},
    extensions = { "neo-tree", "lazy" },
  },
}
