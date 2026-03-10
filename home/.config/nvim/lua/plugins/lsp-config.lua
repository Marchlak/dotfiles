local servers = {
  "lua_ls",                -- Lua
  "clangd",                -- C++
  "html",                  -- HTML
  "cssls",                 -- CSS
  "tailwindcss",           -- Tailwind
  "kotlin_language_server", -- Kotlin
  "lemminx",               -- XML
  "jsonls",                -- JSON
  "bashls",                -- Bash
  "pylsp",                 -- Python
  "ts_ls",                 -- TypeScript
}

return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      -- ensure the java debug adapter is installed
      require("mason-nvim-dap").setup({
        ensure_installed = { "java-debug-adapter", "java-test" },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup_handlers({
        function(server)
          lspconfig[server].setup({ capabilities = capabilities })
        end,
        ["pylsp"] = function()
          lspconfig.pylsp.setup({
            capabilities = capabilities,
            settings = {
              pylsp = {
                plugins = {
                  pycodestyle = {
                    maxLineLength = 160,
                  },
                },
              },
            },
          })
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "<leader>gy", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "LSP declaration" }))
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "LSP definition" }))
          vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "LSP implementation" }))
          vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP hover" }))
          vim.keymap.set({ "n", "v" }, "<leader>ga", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP code action" }))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "[R]e[n]ame symbol" }))
          vim.keymap.set("n", "<leader>gr", require("telescope.builtin").lsp_references, vim.tbl_extend("force", opts, { desc = "[G]oto [R]eferences" }))
        end,
      })
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    ft = "java",
    config = function()
      require("config.jdtls").setup_jdtls()
    end,
  },
}
