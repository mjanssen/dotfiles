return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	init = function()
		-- Highlighting per-buffer
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(args.match)
				if lang and pcall(vim.treesitter.start, args.buf, lang) then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		-- Install missing parsers once, lazily
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			once = true,
			callback = function()
				local ensure_installed = {
					"javascript",
					"typescript",
					"tsx",
					"lua",
					"rust",
					"jsdoc",
					"python",
					"dockerfile",
					"toml",
				}
				local installed = require("nvim-treesitter.config").get_installed()
				local to_install = vim.iter(ensure_installed)
					:filter(function(p)
						return not vim.tbl_contains(installed, p)
					end)
					:totable()
				if #to_install > 0 then
					require("nvim-treesitter").install(to_install)
				end
			end,
		})
	end,
}
