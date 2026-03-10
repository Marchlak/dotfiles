vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>aa", "ggVG", { desc = "Select all" })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Populate diagnostics location list" })
vim.keymap.set("n", "<leader>nb", vim.diagnostic.goto_next, { desc = "[N]ext [B]ug" })

vim.keymap.set("n", "<leader>o", "o<Esc>", { desc = "Insert line below" })
vim.keymap.set("n", "<leader><Tab>", "<cmd>b#<CR>", { desc = "Switch to previous buffer" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "[W]indow Split [V]ertical" })
vim.keymap.set("n", "<leader>wh", "<cmd>split<CR>", { desc = "[W]indow Split [H]orizontal" })

vim.keymap.set("n", "<leader>pv", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "[F]inder Find files" })

vim.keymap.set("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "[F]inder Live grep" })

vim.keymap.set("n", "<C-p>", function()
  require("telescope.builtin").git_files()
end, { desc = "Find git files" })

vim.keymap.set("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "[F]inder [B]uffers" })

vim.keymap.set("n", "<leader>fr", function()
  require("telescope.builtin").resume()
end, { desc = "[F]inder [R]esume" })

vim.keymap.set("n", "<leader>fd", function()
  require("telescope.builtin").diagnostics()
end, { desc = "[F]inder [D]iagnostics" })

vim.keymap.set("n", "<leader>fu", function()
  require("telescope.builtin").grep_string()
end, { desc = "[F]inder grep string under cursor" })

vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>', { desc = "Disable left arrow" })
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>', { desc = "Disable right arrow" })
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>', { desc = "Disable up arrow" })
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>', { desc = "Disable down arrow" })
