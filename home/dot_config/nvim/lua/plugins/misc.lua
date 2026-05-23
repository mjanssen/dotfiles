return {
	{
		"tpope/vim-commentary",
	},
	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
		end,
	},
	{
		"b0o/incline.nvim",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local helpers = require("incline.helpers")
			local navic = require("nvim-navic")
			local devicons = require("nvim-web-devicons")

			require("incline").setup({
				window = {
					-- width = "fill",
					padding = { left = 1, right = 1 },
					margin = {
						horizontal = 1,
						vertical = { top = 1, bottom = 0 },
					},
					placement = {
						horizontal = "right",
						vertical = "top",
					},
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if filename == "" then
						filename = "[No Name]"
					end
					local ft_icon, ft_color = devicons.get_icon_color(filename)
					local modified = vim.bo[props.buf].modified
					local res = {
						ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) }
							or "",
						" ",
						{ filename, gui = modified and "bold,italic" or "bold" },
					}
					if props.focused then
						for _, item in ipairs(navic.get_data(props.buf) or {}) do
							table.insert(res, {
								{ " > ", group = "NavicSeparator" },
								{ item.icon, group = "NavicIcons" .. item.type },
								{ item.name, group = "NavicText" },
							})
						end
					end
					table.insert(res, " ")
					return res
				end,
			})
		end,
		-- Optional: Lazy load Incline
		event = "VeryLazy",
	},
}
