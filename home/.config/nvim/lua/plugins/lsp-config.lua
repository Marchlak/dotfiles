local servers = {
  "lua_ls",                -- Lua
  "jdtls",                 -- Java
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
          vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover, opts)
          vim.keymap.set({ "n", "v" }, "<leader>ga", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>cR", vim.lsp.buf.rename, { desc = "[C]ode [R]ename" })
          vim.keymap.set("n", "<leader>cr", require("telescope.builtin").lsp_references, { desc = "[C]ode Goto [R]eferences" })
        end,
      })
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    dependencies = {
      "mfussenegger/nvim-dap",
    }
  },
}
