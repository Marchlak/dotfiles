-- LSP, toolchain management, and language server keymaps.
local servers = {
  "lua_ls",                -- Lua
  "clangd",                -- C++
  "html",                  -- HTML
  "cssls",                 -- CSS
  "tailwindcss",           -- Tailwind
  "gradle_ls",             -- Gradle (Groovy)
  "groovyls",              -- Groovy
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
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = false,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local telescope_builtin = require("telescope.builtin")

      local function set_location_list(list)
        if not list or vim.tbl_isempty(list.items or {}) then
          vim.notify("No usages found", vim.log.levels.INFO)
          return
        end

        vim.fn.setloclist(0, {}, " ", {
          title = list.title,
          items = list.items,
        })
        vim.cmd("lopen")
      end

      local function list_references()
        vim.lsp.buf.references(nil, { on_list = set_location_list })
      end

      for _, server in ipairs(servers) do
        local config = {
          capabilities = capabilities,
        }

        if server == "pylsp" then
          config.settings = {
            pylsp = {
              plugins = {
                pycodestyle = {
                  maxLineLength = 160,
                },
              },
            },
          }
        end

        if server == "gradle_ls" then
          config.filetypes = { "groovy" }
          config.root_markers = {
            "settings.gradle",
            "settings.gradle.kts",
            "build.gradle",
            "build.gradle.kts",
            ".git",
          }
          config.init_options = {
            settings = {
              gradleWrapperEnabled = true,
            },
          }
        end

        if server == "groovyls" then
          config.filetypes = { "groovy" }
          config.root_markers = {
            "settings.gradle",
            "build.gradle",
            "Jenkinsfile",
            ".git",
          }
        end

        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end

      require("lang.sqls").setup(capabilities)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "<leader>gy", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "LSP declaration" }))
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "LSP definition" }))
          vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "LSP implementation" }))
          vim.keymap.set("n", "<leader>gD", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "LSP type definition" }))
          vim.keymap.set("n", "<leader>kk", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP hover" }))
          vim.keymap.set({ "n", "v" }, "<leader>ga", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP code action" }))
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
          vim.keymap.set({ "n", "v" }, "<leader>re", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
          vim.keymap.set("n", "<leader>gr", telescope_builtin.lsp_references, vim.tbl_extend("force", opts, { desc = "Show references" }))
          vim.keymap.set("n", "<leader>u", list_references, vim.tbl_extend("force", opts, { desc = "Find usages in location list" }))
          vim.keymap.set("n", "<leader>p", telescope_builtin.lsp_references, vim.tbl_extend("force", opts, { desc = "Show usages" }))
          vim.keymap.set("n", "<leader>fs", telescope_builtin.lsp_document_symbols, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
          vim.keymap.set("n", "<leader>fc", telescope_builtin.lsp_dynamic_workspace_symbols, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))
        end,
      })
    end,
  },
}
