require("config.keymaps")
require("config.lazy")
require("config.vim-options")
require("config.autocmd")


local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
lspconfig.pyright.setup{
  capabilities = capabilities
}






