local plugin = {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
  dependecies = {
    "windwp/nvim-ts-autotag"
  }
}

function plugin.config()
	require("nvim-treesitter.configs").setup({
		ensure_installed = { "c", "lua", "vim","java", "javascript", "typescript", "html", "css", "json", "tsx", "markdown", "markdown_inline", "gitignore"},

		sync_install = false,
		auto_install = true,
    highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
			disable = { "text" },
		},
    autotag = {
      enable = true
    },
		indent = { enable = true },
	})
end

return plugin
