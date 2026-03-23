-- Non-intrusive keymap discovery for leader groups.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local which_key = require("which-key")

    which_key.setup({
      delay = 300,
      preset = "modern",
      notify = false,
    })

    which_key.add({
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Goto / LSP" },
      { "<leader>j", group = "Java" },
      { "<leader>w", group = "Window" },
      { "<leader>r", group = "Refactor / format" },
      { "<leader>n", group = "Diagnostics" },
      { "<leader>b", group = "Browser / build" },
      { "<leader>a", group = "Add / select" },
      { "<leader>t", group = "Tree" },
      { "<leader>s", group = "Split" },
      { "<leader>k", group = "Docs" },
    })
  end,
}
