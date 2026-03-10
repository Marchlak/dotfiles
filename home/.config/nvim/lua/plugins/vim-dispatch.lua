return {
  "tpope/vim-dispatch",
  config = function ()
    vim.keymap.set("n", "<leader>bs", ':Dispatch browser-sync start --server --files "*"<CR>', {
      desc = "[B]rowser [S]ync start",
      silent = true,
    })
  end
}
