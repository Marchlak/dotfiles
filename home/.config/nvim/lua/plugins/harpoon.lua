-- Quick file navigation and bookmarking.
local plugin = {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
}

function plugin.config()
  local harpoon = require("harpoon")
  harpoon:setup()

  vim.keymap.set("n", "<leader>as", function() harpoon:list():add() end, { desc = "[A]dd file to harpoon [S]tack" })
  vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Toggle harpoon quick menu" })

  vim.keymap.set("n", "<C-1>", function() harpoon:list():select(1) end, { desc = "Go to harpoon file 1" })
  vim.keymap.set("n", "<C-2>", function() harpoon:list():select(2) end, { desc = "Go to harpoon file 2" })
  vim.keymap.set("n", "<C-3>", function() harpoon:list():select(3) end, { desc = "Go to harpoon file 3" })
  vim.keymap.set("n", "<C-4>", function() harpoon:list():select(4) end, { desc = "Go to harpoon file 4" })

  vim.keymap.set("n", "<C-n>", function() harpoon:list():prev() end, { desc = "Go to previous harpoon file" })
  vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Go to next harpoon file" })
end

return plugin
