local plugin = {
  'nvim-lualine/lualine.nvim',
  requires = { 'nvim-tree/nvim-web-devicons', opt = true }
}

function plugin.config()
  require("lualine").setup({})
end

return plugin
