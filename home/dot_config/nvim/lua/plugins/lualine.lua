return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = function(_, opts)
		vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text from gitblame
		local git_blame = require("gitblame")

		local last_blame_text = ""
		local last_blame_time = 0
		local throttle_ms = 1000

		local function throttled_blame_text()
			local now = vim.loop.now()
			if now - last_blame_time > throttle_ms then
				last_blame_time = now
				last_blame_text = git_blame.get_current_blame_text() or ""
			end
			return last_blame_text
		end

		opts.sections = {
			lualine_c = {
				{ throttled_blame_text, cond = git_blame.is_blame_text_available },
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
