-- Formatters and extra diagnostics exposed through the LSP client.
return {
	{
		"jay-babu/mason-null-ls.nvim",
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					"stylua",
					"prettier",
					"black",
					"isort",
				},
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.prettier.with({
            dynamic_command = function(_, done)
              done("prettier")
            end,
            cwd = nil,
          }),
          null_ls.builtins.formatting.black,
        },
			})
			vim.keymap.set("n", "<leader>rc", vim.lsp.buf.format, { desc = "[R]eformat [C]ode" })
		end,
	},
}
