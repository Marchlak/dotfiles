vim.g.mapleader = " "
vim.g.maplocalleader = " "

--vim.api.nvim_set_keymap('n', '<leader>pv', ':Ex<CR>', { noremap = true, silent = true }) -- netrw

vim.api.nvim_set_keymap('n', '<leader>aa', 'ggVG', { noremap = true, silent = true }) -- select all


vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, silent = true }) --- # diagnostic
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { noremap = true, silent = true }) --- # diagnostic

vim.api.nvim_set_keymap('n', '<leader>o', 'o<Esc>', { noremap = true, silent = true }) -- space
vim.api.nvim_set_keymap('n', '<leader><Tab>', ':b#<CR>', { noremap = true, silent = true }) --previousbuffer

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc="no highlight" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc="Exit terminal" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Easily split windows
vim.keymap.set("n", "<leader>wv", ":vsplit<cr>", { desc = "[W]indow Split [V]ertical" })
vim.keymap.set("n", "<leader>wh", ":split<cr>", { desc = "[W]indow Split [H]orizontal" })



vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
