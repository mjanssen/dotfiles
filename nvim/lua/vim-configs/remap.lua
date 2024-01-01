vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- keep cursor in the middle of screen when jumping up/down
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep cursor in the middle during search jumps
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- keep copied items in buffer when pasting with leader
vim.keymap.set("x", "<leader>p", '"_dP')

-- manage error bleeding
vim.keymap.set("n", "<leader>es", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>en", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>ep", vim.diagnostic.goto_prev)

-- allow leader y to yank into system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- quickfix list
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- replace selected word throughout document
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- format shortcut using formatter.nvim
-- vim.keymap.set("n", "<leader>ff", "<cmd>:Format<CR>")

-- copy file in filetree
vim.keymap.set("n", "<leader>cad", "<cmd>:!cp '%:p' '%:p:h/%:t:r-copy.%:e'<CR>")
