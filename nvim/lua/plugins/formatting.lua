return {
	"stevearc/conform.nvim",
	opts = function(_, opts)
		opts.formatters = {
			formatters = {
				sqlfluff = {
					command = "sqlfluff",
					args = { "format", "--dialect", "postgres", "-" },
					stdin = true,
				},
			},
		}

		opts.formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "biome" },
			typescript = { "biome" },
			typescriptreact = { "biome" },
			sql = { "sqlfluff" },
			python = { "ruff_format", "isort" },
		}
	end,
}
