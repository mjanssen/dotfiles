return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					preview = {
						-- ft_to_lang was removed in nvim 0.10+; disable ts highlighting in previewer
						treesitter = false,
					},
				},
			})
			telescope.load_extension("fzf")
		end,
		keys = {
			{
				"<C-p>",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find files",
			},
			{
				"<leader>pf",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find files",
			},
			{
				"<leader>pg",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>pb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>ph",
				function()
					require("telescope.builtin").help_tags()
				end,
				desc = "Help tags",
			},
			{
				"<leader>pr",
				function()
					require("telescope.builtin").oldfiles()
				end,
				desc = "Recent files",
			},
			{
				"<leader>pc",
				function()
					require("telescope.builtin").command_history()
				end,
				desc = "Command history",
			},
			{
				"<leader>pd",
				function()
					require("telescope.builtin").diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>ps",
				function()
					require("telescope.builtin").lsp_document_symbols()
				end,
				desc = "LSP symbols",
			},
			{
				"<leader>gf",
				function()
					require("telescope.builtin").git_files()
				end,
				desc = "Git files",
			},
			{
				"gI",
				function()
					require("telescope.builtin").lsp_implementations()
				end,
				desc = "Implementations",
			},
		},
	},
}
