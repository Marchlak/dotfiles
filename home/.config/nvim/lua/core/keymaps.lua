vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set

-- Editing
keymap("n", "<leader>aa", "ggVG", { desc = "Select entire buffer" })
keymap("n", "<leader>o", "o<Esc>", { desc = "Insert line below" })
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Diagnostics
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Populate diagnostics location list" })
keymap("n", "<leader>nb", vim.diagnostic.goto_next, { desc = "Jump to next diagnostic" })

-- Windows and buffers
keymap("n", "<leader><Tab>", "<cmd>b#<CR>", { desc = "Switch to previous buffer" })
keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
keymap("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
keymap("n", "<leader>wh", "<cmd>split<CR>", { desc = "Split window horizontally" })

-- Files and search
keymap("n", "<leader>pv", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find files" })
keymap("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Search text in project" })
keymap("n", "<C-p>", function()
  require("telescope.builtin").git_files()
end, { desc = "Find git files" })
keymap("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "List open buffers" })
keymap("n", "<leader>fr", function()
  require("telescope.builtin").resume()
end, { desc = "Resume last picker" })
keymap("n", "<leader>fd", function()
  require("telescope.builtin").diagnostics()
end, { desc = "Search diagnostics" })
keymap("n", "<leader>fu", function()
  require("telescope.builtin").grep_string()
end, { desc = "Search word under cursor" })

-- Habit breakers
keymap("n", "<left>", '<cmd>echo "Use h to move!!"<CR>', { desc = "Disable left arrow" })
keymap("n", "<right>", '<cmd>echo "Use l to move!!"<CR>', { desc = "Disable right arrow" })
keymap("n", "<up>", '<cmd>echo "Use k to move!!"<CR>', { desc = "Disable up arrow" })
keymap("n", "<down>", '<cmd>echo "Use j to move!!"<CR>', { desc = "Disable down arrow" })
