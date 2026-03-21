-- File explorer sidebar.
return {
  "nvim-tree/nvim-tree.lua",
  config = function()
      require("nvim-tree").setup(
      {
        hijack_netrw = true,
        auto_reload_on_write = true,
      }
    )
  end
}
