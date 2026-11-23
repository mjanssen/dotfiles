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
		"SmiteshP/nvim-navic",
		config = function()
			local navic = require("nvim-navic")
			navic.setup({ lsp = { auto_attach = true }, highlight = true })

			local function escape(s)
				return (s:gsub("%%", "%%%%"))
			end

			function _G.winbar()
				local winid = vim.g.statusline_winid
				local buf = vim.api.nvim_win_get_buf(winid)
				local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":~:.")
				if vim.bo[buf].modified then
					path = path .. " ●"
				end

				local symbols, symbols_width = {}, 0
				for _, item in ipairs(navic.get_data(buf) or {}) do
					table.insert(
						symbols,
						"%#NavicSeparator# > %#NavicIcons" .. item.type .. "#" .. item.icon .. "%#NavicText#" .. escape(item.name)
					)
					symbols_width = symbols_width + 3 + vim.fn.strdisplaywidth(item.icon .. item.name)
				end

				local available = vim.api.nvim_win_get_width(winid) - symbols_width - 2
				if vim.fn.strdisplaywidth(path) > available and available > 3 then
					path = "..." .. vim.fn.strcharpart(path, vim.fn.strchars(path) - (available - 3))
				end

				return " %#WinBar#" .. escape(path) .. table.concat(symbols)
			end

			vim.api.nvim_create_autocmd({ "BufWinEnter", "BufFilePost" }, {
				callback = function(args)
					local win = vim.api.nvim_get_current_win()
					if vim.api.nvim_win_get_config(win).relative ~= "" then
						return
					end
					local is_file = vim.bo[args.buf].buftype == "" and vim.api.nvim_buf_get_name(args.buf) ~= ""
					vim.wo[win].winbar = is_file and "%!v:lua.winbar()" or ""
				end,
			})
		end,
	},
}
