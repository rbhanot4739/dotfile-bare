return {
  "rmagatti/auto-session",
  lazy = false,
  opts = {
    allowed_dirs = { "~/.config/nvim", "~/development/work/**/" },
    suppressed_dirs = { "~/", "~/Downloads", "/" },
    bypass_save_filetypes = { "alpha", "dashboard" },
    -- log_level = "debug",
  },
}
