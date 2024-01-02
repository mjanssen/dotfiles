return {
	"nvimtools/none-ls.nvim",
	opts = function(_, opts)
		-- none-ls is actually null-ls under-the-hood
		local nls = require("null-ls").builtins

		opts.sources = {
			-- TS / JS
			nls.formatting.biome.with({
				exe = "biome",
				args = {
					"check",
					"--apply-unsafe",
					"--jsx-quote-style=double",
					"--formatter-enabled=true",
					"--organize-imports-enabled=true",
					"--skip-errors",
					"$FILENAME",
				},
			}),
			-- Python
			nls.formatting.black.with({
				exe = "black",
				stdin = true,
				args = { "-q", "-" },
			}),
			nls.formatting.ruff.with({
				exe = "ruff",
				stdin = true,
				args = {
					-- attempt to automatically fix lint violations
					"--fix",
					-- exit with 0
					"-e",
					-- no-cache
					"-n",
					-- quiet
					"-q",
					"--stdin-filename",
					"%",
					-- push output into stdout
					"-",
				},
			}),
			-- Generics
			nls.formatting.stylua,
		}
	end,
}
