vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set

local function telescope_builtin(name)
  return function()
    require("telescope.builtin")[name]()
  end
end

local function goto_line()
  vim.ui.input({ prompt = "Go to line: " }, function(input)
    local line = tonumber(input)
    if line then
      vim.api.nvim_win_set_cursor(0, { line, 0 })
    end
  end)
end

local function open_diagnostics_list()
  vim.diagnostic.setloclist()
  vim.cmd("lopen")
end

-- Editing
keymap("n", "<leader>aa", "ggVG", { desc = "Select entire buffer" })
keymap("n", "<leader>o", "o<Esc>", { desc = "Insert line below" })
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap("n", "<leader>gc", "<cmd>CommentToggle<CR>", { desc = "Toggle line comment" })
keymap("x", "<leader>gc", "<cmd>'<,'>CommentToggle<CR>", { desc = "Toggle selection comment" })

-- Diagnostics
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Populate diagnostics location list" })
keymap("n", "<leader>nb", vim.diagnostic.goto_next, { desc = "Jump to next diagnostic" })
keymap("n", "<leader>np", vim.diagnostic.goto_prev, { desc = "Jump to previous diagnostic" })
keymap("n", "<leader>nl", open_diagnostics_list, { desc = "Open diagnostics location list" })

-- Windows and buffers
keymap("n", "<leader><Tab>", "<cmd>b#<CR>", { desc = "Switch to previous buffer" })
keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
keymap("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
keymap("n", "<leader>wh", "<cmd>split<CR>", { desc = "Split window horizontally" })
keymap("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
keymap("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split window horizontally" })
keymap("n", "<leader>h", "<cmd>hide<CR>", { desc = "Hide current window" })

-- Files and search
keymap("n", "<leader>pv", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap("n", "<leader>ff", telescope_builtin("find_files"), { desc = "Find files" })
keymap("n", "<leader>fg", telescope_builtin("live_grep"), { desc = "Search text in project" })
keymap("n", "<C-p>", telescope_builtin("git_files"), { desc = "Find git files" })
keymap("n", "<leader>fb", telescope_builtin("buffers"), { desc = "List open buffers" })
keymap("n", "<leader>fr", telescope_builtin("resume"), { desc = "Resume last picker" })
keymap("n", "<leader>fd", telescope_builtin("diagnostics"), { desc = "Search diagnostics" })
keymap("n", "<leader>fu", telescope_builtin("grep_string"), { desc = "Search word under cursor" })
keymap("n", "<leader>gl", goto_line, { desc = "Go to line" })
keymap("n", "<leader>tt", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap("n", "<leader>tf", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal current file in explorer" })
keymap("n", "<leader>tc", "<cmd>NvimTreeClose<CR>", { desc = "Close file explorer" })
keymap("n", "<leader>tr", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
keymap("n", "<leader>tp", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })

-- Habit breakers
keymap("n", "<left>", '<cmd>echo "Use h to move!!"<CR>', { desc = "Disable left arrow" })
keymap("n", "<right>", '<cmd>echo "Use l to move!!"<CR>', { desc = "Disable right arrow" })
keymap("n", "<up>", '<cmd>echo "Use k to move!!"<CR>', { desc = "Disable up arrow" })
keymap("n", "<down>", '<cmd>echo "Use j to move!!"<CR>', { desc = "Disable down arrow" })
