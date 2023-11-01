vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text
local git_blame = require("gitblame")

require("lualine").setup({
	sections = {
		lualine_c = {
			{ git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
		},
		lualine_x = {},
		lualine_y = { "filename" },
	},
	options = {
		icons_enabled = false,
		theme = "auto",
		component_separators = "|",
		section_separators = "",
	},
})
