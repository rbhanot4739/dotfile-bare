-- local themes = require("telescope.themes")

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "debugloop/telescope-undo.nvim",
    {
      "danielfalk/smart-open.nvim",
      branch = "0.2.x",
      config = function()
        require("telescope").load_extension("smart_open")
      end,
      dependencies = {
        "kkharji/sqlite.lua",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      },
    },
  },
  opts = function(_, opts)
    local actions = require("telescope.actions")
    opts.defaults = {
      path_display = {
        "smart",
        -- shorten = { len = 3, exclude = { -3, -2, -1 } },
        -- "filename_first",
      },
      prompt_prefix = "🔍 ",
      file_ignore_patterns = { "static/", "docs/", "pages/" },
      -- preview = {
      --   filesize_limit = 0.1, -- MB
      -- },
      dynamic_preview_title = true,
      mappings = {
        n = {
          ["D"] = actions.delete_buffer,
        },
      },
    }
    opts.extensions = {
      undo = {
        side_by_side = true,
        layout_strategy = "vertical",
        layout_config = {
          preview_height = 0.8,
        },
      },
    }
    require("telescope").load_extension("undo")
    -- require("telescope").load_extension("harpoon")
    return opts
  end,
  keys = {
    { "<leader>su", "<cmd>Telescope undo<cr>", desc = "Search undo history" },
    -- custom keymaps to search in the git root(containing .git) and not lsp root
    {
      "<leader>sw",
      function()
        require("telescope.builtin").grep_string(
          -- themes.get_ivy({
          --   previewer = true,
          -- }),
          { cwd = require("utils").get_root_dir, additional_args = { "--follow" } }
        )
      end,
      mode = { "n", "v" },
      desc = "Grep word under cursor (Git Root)",
    },
    {
      "<leader>sg",
      function()
        require("telescope.builtin").live_grep({
          cwd = require("utils").get_root_dir,
          additional_args = { "--follow" },
          prompt_title = "Live Grep (Git Root)",
        })
      end,
      -- mode = { "n", "v" },
      desc = "Live grep (Git Root)",
    },
    { "<leader>sm", "<cmd>Telescope harpoon marks<cr>", desc = "Search Harpoon marks" },
    { "<leader>sM", "<cmd>Telescope marks<cr>", desc = "Search Vim marks" },
    -- { "<space><space>", "<cmd>Telescope buffers theme=dropdown<cr>", desc = "Search open buffers" },
    {
      "<space><space>",
      function()
        require("telescope").extensions.smart_open.smart_open({
          cwd_only = true,
          -- show_scores = true,
          match_algorithm = "fzf",
          open_buffer_indicators = { previous = "•", others = "∘" },
        })
      end,
      desc = "Search open buffers",
    },
    {
      "<leader>fr",
      function()
        require("telescope.builtin").oldfiles({
          cwd = require("utils").get_root_dir,
          prompt_title = "Recent Files (Git Root)",
        })
      end,
      desc = "Find recent files (Git Root)",
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
      function()
        require("telescope").extensions.yank_history.yank_history({})
      end,
      mode = { "i" },
      { desc = "Paste yank ring" },
    },
    { "zf", "<cmd>Telescope spell_suggest<cr>", desc = "Spell suggest" },
    { "<leader>/", "<cmd>Telescope search_history<cr>", desc = "Search history" },
    { "<leader>,", "<cmd>Telescope vim_options<cr>", desc = "Search Vim options" },
    -- {
    --   "<leader>FF",
    --   function()
    --     utils.recent_files_picker()
    --   end,
    -- },
  },
}
