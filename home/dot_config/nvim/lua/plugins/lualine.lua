return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = function(_, opts)
		vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text from gitblame
		local git_blame = require("gitblame")

		opts.sections = {
			lualine_c = {
				{ git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
			},
			-- Hide icon stuff
			lualine_x = { "" },
		}

		opts.options = {
			theme = "dracula",
			icons_enabled = true,
		}
	end,
}
