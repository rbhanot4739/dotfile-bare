return {
  "coffebar/neovim-project",
  opts = {
    projects = { -- define project roots
      "~/development/work/multiproducts/*",
    },
    session_manager_opts = {
      autosave_ignore_dirs = {
        vim.fn.expand("~"), -- don't create a session for $HOME/
        "/tmp",
        "~/",
      },
      autosave_ignore_filetypes = {
        -- All buffers of these file types will be closed before the session is saved
        "ccc-ui",
        "gitcommit",
        "gitrebase",
        "alpha",
        "dashboard",
      },
    },
    picker = {
      type = "telescope", -- or "fzf-lua"
    },
    last_session_on_startup = false,
  },
  init = function()
    -- enable saving the state of plugins in the session
    vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
  end,
  dependencies = {
    { "Shatur/neovim-session-manager", opts = {} },
  },
  lazy = false,
  priority = 100,
  keys = {
    {
      "<leader>qS",
      "<cmd>NeovimProjectDiscover<cr>",
      desc = "Restore Session",
    },
    {
      "<leader>qs",
      "<cmd>NeovimProjectHistory<cr>",
      desc = "Session: Recent Projects",
    },
    {
      "<leader>ql",
      "<cmd>NeovimProjectLoadRecent<cr>",
      desc = "Session: Load last session",
    },
  },
}
