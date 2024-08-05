return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = function(_, opts)
		vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text
		local git_blame = require("gitblame")

		opts.sections = {
			lualine_c = {
				{ git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
			},
			lualine_x = {},
			-- lualine_y = { { "filename", path = 1 }, "filetype" },
		}

		opts.options = {
			theme = "dracula",
			icons_enabled = true,
		}
	end,
}
