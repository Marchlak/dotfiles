-- SQL language server bootstrap with local-only connection configuration.
local M = {}

local function sqls_cmd()
  local cmd = { "sqls" }
  local config_path = vim.env.SQLS_CONFIG

  if config_path and config_path ~= "" then
    table.insert(cmd, "-config")
    table.insert(cmd, config_path)
  end

  return cmd
end

function M.setup(capabilities)
  if vim.fn.executable("sqls") ~= 1 then
    return
  end

  vim.lsp.config("sqls", {
    cmd = sqls_cmd(),
    capabilities = capabilities,
    filetypes = { "sql", "mysql" },
    root_markers = { "config.yml", ".sqls.yml", ".git" },
    settings = {},
  })

  vim.lsp.enable("sqls")
end

return M
