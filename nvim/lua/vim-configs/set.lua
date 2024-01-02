local o = vim.opt

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

o.guicursor = ""

o.nu = true
o.relativenumber = true

o.autoindent = true
o.smartindent = false

o.expandtab = false
o.softtabstop = 4
o.shiftwidth = 4
o.tabstop = 4

o.wrap = false

o.swapfile = false
o.backup = false
o.undodir = os.getenv("HOME") .. "/.vim/undodir"
o.undofile = true

o.hlsearch = false
o.incsearch = true

o.termguicolors = true

o.scrolloff = 8
o.signcolumn = "yes"
o.isfname:append("@-@")

o.updatetime = 50

o.cursorline = true
