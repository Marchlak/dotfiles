vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.smartindent = true
vim.opt.breakindent = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.termguicolors = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

local python_hosts = {
  vim.fn.expand("~/.local/share/pipx/venvs/pynvim/bin/python"),
  vim.fn.exepath("python3"),
}

for _, python3_host in ipairs(python_hosts) do
  if python3_host ~= "" and vim.fn.executable(python3_host) == 1 then
    vim.fn.system({ python3_host, "-c", "import pynvim" })
    if vim.v.shell_error == 0 then
      vim.g.python3_host_prog = python3_host
      break
    end
  end
end

local node_host = vim.fn.exepath("neovim-node-host")
if node_host ~= "" then
  vim.g.node_host_prog = node_host
end

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.updatetime = 100

vim.opt.conceallevel = 0
vim.opt.timeoutlen = 1500

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
