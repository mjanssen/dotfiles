local formatter = require("formatter")
local utils = require("formatter.util")

local romeConfig = function()
	-- jsx-quote-style requires rome@12.1.3-nightly.4c8cf32
	return {
		exe = "rome",
		args = {
			"format",
			"--jsx-quote-style",
			"double",
			"--stdin-file-path",
			utils.escape_path(utils.get_current_buffer_file_path()),
		},
		stdin = true,
	}
end

local formatterFTs = {
	python = {
		function()
			return {
				exe = "black",
				args = { "-q", "-" },
				stdin = true,
			}
		end,
		function()
			return {
				exe = "ruff",
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
				stdin = true,
			}
		end,
	},
	rust = {
		function()
			return {
				exe = "rustfmt",
				args = { "--edition=2021", "--emit=stdout" },
				stdin = true,
			}
		end,
	},
	lua = {
		require("formatter.filetypes.lua").stylua,
	},
	["*"] = {
		require("formatter.filetypes.any").remove_trailing_whitespace,
	},
}

-- Give JS/TS files the same formatting
local jsFTs = {
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
}
for _, ft in ipairs(jsFTs) do
	formatterFTs[ft] = { romeConfig }
end

formatter.setup({
	logging = true,
	filetype = formatterFTs,
	log_level = vim.log.levels.WARN,
})
