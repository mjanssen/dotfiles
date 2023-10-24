require("gitblame").setup({
	enabled = true,
})

if vim.config then
	vim.config.gitblame_display_virtual_text = 0
end
