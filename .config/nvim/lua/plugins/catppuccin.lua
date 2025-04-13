-- style
local plugin = {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
}

function plugin.config()
  require("catppuccin").setup()
  vim.cmd.colorscheme("catppuccin-mocha")
end

return plugin
