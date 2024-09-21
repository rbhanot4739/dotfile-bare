local utils = require("utils")
local project_root = utils.get_root_dir

return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local actions = require("telescope.actions")
    opts.defaults = {
      path_display = {
        shorten = { len = 3, exclude = { -3, -2, -1 } },
        "filename_first",
      },
      prompt_prefix = "🔍 ",
      file_ignore_patterns = { "static/" },
      -- preview = {
      --   filesize_limit = 0.1, -- MB
      -- },
    }
    opts.extensions = {}
    return opts
  end,
  keys = {
    -- custom keymaps to search in the project root(containing .git) and not lsp root
    {
      "<leader>sw",
      function()
        require("telescope.builtin").grep_string({ cwd = project_root })
      end,
      mode = { "n", "v" },
      desc = "Grep word under cursor (Root Dir)",
    },
    {
      "<leader>sg",
      function()
        -- require("telescope.builtin").live_grep({ cwd = project_root })
        require("telescope.builtin").live_grep({ cwd = project_root, prompt_title = "Live Grep (Root dir)" })
      end,
      -- mode = { "n", "v" },
      desc = "Live grep (Root Dir)",
    },
    {
      "<leader>fr",
      function()
        require("telescope.builtin").oldfiles({ cwd = project_root, prompt_title = "Recent Files (Root)" })
      end,
      desc = "Find recent files (root)",
    },
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({ cwd = project_root, prompt_title = "Find Files (Root)" })
      end,
      desc = "Find files (root)",
    },

    -- git
    {
      "<leader>gbb",
      function()
        require("telescope.builtin").git_branches({
          show_remote_tracking_branches = false,
          prompt_title = "Git branches (local)",
        })
      end,
      desc = "Git Branches (Local)",
    },
    {
      "<leader>gbB",
      function()
        require("telescope.builtin").git_branches({ prompt_title = "Git branches (All)" })
      end,
      desc = "Git Branches (All)",
    },
    { "<leader>gc", "<cmd>Telescope git_bcommits<cr>", desc = "List commits impacting current buffer" },
    { "<leader>gC", "<cmd>Telescope git_commits<cr>", desc = "List all commits" },

    { "<leader>sc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    -- telescope picker for files in current file's parent directory
    {
      "<leader>fC",
      [[<cmd>lua require("telescope.builtin").find_files({cwd=vim.fn.expand("%:p:h")})<cr>]],
      desc = "Find files in current files parent directory",
    },
    {
      "<C-r>",
      "<cmd>Telescope registers<cr>",
      mode = { "i" },
      { desc = "paste regiseter content" },
    },
    { "zf", "<cmd>Telescope spell_suggest<cr>", desc = "Spell suggest" },
    { "<leader>/", "<cmd>Telescope search_history<cr>", desc = "Search history" },
    { "<leader>,", "<cmd>Telescope vim_options<cr>", desc = "Search Vim options" },
    {
      "<leader>FF",
      function()
        utils.recent_files_picker()
      end,
    },
  },
}
