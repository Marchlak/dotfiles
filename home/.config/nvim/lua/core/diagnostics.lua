local M = {}

local function current_line_message()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

  if #diagnostics == 0 then
    return ""
  end

  table.sort(diagnostics, function(a, b)
    return a.severity < b.severity
  end)

  local message = diagnostics[1].message:gsub("%s+", " ")
  if #message > 90 then
    message = message:sub(1, 87) .. "..."
  end

  local severity_icons = {
    [vim.diagnostic.severity.ERROR] = "E",
    [vim.diagnostic.severity.WARN] = "W",
    [vim.diagnostic.severity.INFO] = "I",
    [vim.diagnostic.severity.HINT] = "H",
  }

  return string.format("%s %s", severity_icons[diagnostics[1].severity] or "D", message)
end

function M.current_line_message()
  return current_line_message()
end

function M.setup()
  vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    severity_sort = true,
    update_in_insert = false,
    float = {
      border = "rounded",
      source = "if_many",
      focusable = false,
      scope = "line",
    },
  })
end

return M
