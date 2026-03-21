-- Fuzzy finding, grep, and picker UI.
return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.6",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local actions = require("telescope.actions")
    local find_command

    if vim.fn.executable("fd") == 1 then
      find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" }
    elseif vim.fn.executable("fdfind") == 1 then
      find_command = { "fdfind", "--type", "f", "--hidden", "--follow", "--exclude", ".git" }
    end

    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = find_command,
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
      },
    })

    require("telescope").load_extension("ui-select")
  end,
}
