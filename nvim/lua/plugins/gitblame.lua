return {
	"f-person/git-blame.nvim",
	opts = function(_, opts)
		opts.enabled = true
	end,
	config = function()
		if vim.config then
			vim.config.gitblame_display_virtual_text = 0
		end
	end,
}
