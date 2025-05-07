local plugin = {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
        })
    end
}

return plugin
