return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    opts.options = {
      theme = "auto",
      disabled_filetypes = {
        globalstatus = vim.o.laststatus == 3,
        statusline = { "neo-tree", "dashboard", "alpha", "ministarter" },
        winbar = { "neo-tree", "dashboard", "alpha", "ministarter" },
      },
    }
    opts.tabline = {
      lualine_a = {
        {
          "buffers",
          symbols = {
            modified = " ●", -- Text to show when the buffer is modified
            alternate_file = "", -- Text to show to identify the alternate file
            directory = "", -- Text to show when the buffer is a directory
          },
        },
      },
      lualine_y = {
        LazyVim.lualine.pretty_path(),
      },
      lualine_z = {
        function()
          -- get value of VIRTUAL_ENV variable if it exists
          local venv = vim.env.VIRTUAL_ENV
          if venv then
            -- return only the basename of the path
            venv = vim.fn.fnamemodify(venv, ":t")
            return string.format("  %s ", venv)
          else
            return ""
          end
        end,
      },
    }
    -- remove the file icon and pretty_path sections
    -- Note: when we remove 3rd section then 4th section becomes next 3rd so we again need to remmove the same again
    table.remove(opts.sections.lualine_c, 3)
    table.remove(opts.sections.lualine_c, 3)
    opts.inactive_winbar = {}
    opts.extensions = { "neo-tree", "lazy" }
    return opts
  end,
}