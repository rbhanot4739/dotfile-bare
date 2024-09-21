local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local themes = require("telescope.themes")

M.git_root = ""

-- get project git root if its a git repo else use cwd
local function get_project_root()
  if M.git_root ~= "" then
    return M.git_root
  end
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if handle == nil then
    M.git_root = vim.fn.getcwd() -- Return current working directory if not a git repository
    return M.git_root
  end
  local result = handle:read("*a")
  handle:close()
  if result == "" then
    M.git_root = vim.fn.getcwd() -- Return current working directory if not a git repository
  else
    M.git_root = result:gsub("%s+$", "")
  end

  print("Project root: " .. M.git_root)
  return M.git_root
end

M.get_root_dir = get_project_root()

-- Custom picker for combining oldfiles and find_files to get VsCode like file search

function M.recent_files_picker(opts, directory)
  opts = opts or {}
  directory = directory or M.get_root_dir

  local oldfiles = vim.tbl_filter(function(file)
    return vim.fn.fnamemodify(file, ":p:h"):find(directory, 1, true)
  end, vim.v.oldfiles)

  pickers
    .new(opts, {
      prompt_title = "Recent Files",
      finder = finders.new_table({
        results = vim.list_slice(oldfiles, 1, 15),
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry,
            ordinal = entry,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          if selection then
            actions.close(prompt_bufnr)
            vim.cmd(string.format(":e %s", selection.value))
          else
            actions.close(prompt_bufnr)
            require("telescope.builtin").find_files({
              prompt_title = "Find Files",
            })
          end
        end)
        return true
      end,
    })
    :find()
end

return M
