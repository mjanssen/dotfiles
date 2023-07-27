local formatter = require("formatter")
local utils = require("formatter.util")

local romeConfig = function()
    -- jsx-quote-style requires rome@12.1.3-nightly.4c8cf32
	return {
		exe = "rome",
		args = { "format", "--jsx-quote-style", "double", "--stdin-file-path", utils.get_current_buffer_file_path() },
		stdin = false,
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
					"--fix",
					"-e",
					"-n",
					"-q",
					"--stdin-filename",
					"%",
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
	lua = { -- "formatter.filetypes.lua" defines default configurations for the
		-- "lua" filetype
		require("formatter.filetypes.lua").stylua,
	},
	-- Use the special "*" filetype for defining formatter configurations on
	-- any filetype
	["*"] = {
		-- "formatter.filetypes.any" defines default configurations for any
		-- filetype
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
