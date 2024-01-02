return {
	priority = 1000,
	"rebelot/kanagawa.nvim",
	config = function()
		require("kanagawa").setup({
			compile = false,
			undercurl = true,
			commentStyle = { italic = true },
			functionStyle = {},
			keywordStyle = { italic = true },
			statementStyle = { bold = true },
			typeStyle = {},
			transparent = false,
			dimInactive = false,
			terminalColors = false,
			colors = {
				palette = {},
				theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
			},
			background = {
				dark = "wave",
				light = "lotus",
			},
		})

		vim.cmd.colorscheme("kanagawa")
	end,
}
