return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.6",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local actions = require("telescope.actions")
    require("telescope").setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
      },
    mappings = {
      i = {
        -- use <cltr> + n to go to the next option
        ["<C-n>"] = actions.cycle_history_next,
        -- use <cltr> + p to go to the previous option
        ["<C-p>"] = actions.cycle_history_prev,
        -- use <cltr> + j to go to the next preview
        ["<C-j>"] = actions.move_selection_next,
        -- use <cltr> + k to go to the previous preview
        ["<C-k>"] = actions.move_selection_previous,
      },
    }
    })

    require("telescope").load_extension("ui-select")
  end,
}
