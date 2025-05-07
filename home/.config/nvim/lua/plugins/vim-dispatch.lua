return {
  "tpope/vim-dispatch",
  config = function ()
    vim.api.nvim_set_keymap('n', '<leader>bs', ':Dispatch browser-sync start --server --files "*"<CR>', { noremap = true, silent = true })
  end
}

