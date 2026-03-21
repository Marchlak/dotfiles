-- Fast line and block commenting.
return {
  "terrortylor/nvim-comment",
  config = function()
    require("nvim_comment").setup()
  end,
}
