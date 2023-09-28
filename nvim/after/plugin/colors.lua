require("catppuccin").setup({
	flavour = "frappe", -- latte, frappe, macchiato, mocha
	transparent_background = true,
	term_colors = false,
	integrations = {
		cmp = true,
		treesitter = true,
		harpoon = true,
		mason = true,
		telescope = false, -- colors are overwritten in telescope config
		native_lsp = {
			enabled = true,
			inlay_hints = {
				background = true,
			},
		},
		-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
	},
})

vim.cmd.colorscheme("catppuccin")

-- function ColorScheme(color)
-- 	-- color = color or "rose-pine"
-- 	color = color or "catppuccin-macchiato"
-- 	vim.cmd.colorscheme(color)

-- 	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- 	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- end

-- ColorScheme()

-- require("rose-pine").setup({
-- 	--- @usage 'auto'|'main'|'moon'|'dawn'
-- 	variant = "moon",
-- 	--- @usage 'main'|'moon'|'dawn'
-- 	dark_variant = "moon",
-- 	bold_vert_split = false,
-- 	dim_nc_background = false,
-- 	disable_background = true,
-- 	disable_float_background = true,
-- 	disable_italics = false,

-- 	--- @usage string hex value or named color from rosepinetheme.com/palette
-- 	groups = {
-- 		panel = "surface",
-- 		panel_nc = "base",
-- 		border = "highlight_med",
-- 		comment = "muted",
-- 		link = "iris",
-- 		punctuation = "subtle",

-- 		error = "love",
-- 		hint = "iris",
-- 		info = "foam",
-- 		warn = "gold",

-- 		field = {
-- 			lua = "love",
-- 		},

-- 		headings = {
-- 			h1 = "iris",
-- 			h2 = "foam",
-- 			h3 = "rose",
-- 			h4 = "gold",
-- 			h5 = "pine",
-- 			h6 = "foam",
-- 		},
-- 		-- or set all headings at once
-- 		-- headings = 'subtle'
-- 	},

-- 	-- Change specific vim highlight groups
-- 	-- https://github.com/rose-pine/neovim/wiki/Recipes
-- 	highlight_groups = {
-- 		ColorColumn = { bg = "rose" },
-- 		["@include.tsx"] = { fg = "pine" },

-- 		["@tag.tsx"] = { fg = "pine" },
-- 		["@constructor.tsx"] = { fg = "iris" },

-- 		["@variable.tsx"] = { fg = "foam" },

-- 		-- Blend colours against the "base" background
-- 		CursorLine = { bg = "foam", blend = 10 },
-- 		StatusLine = { fg = "iris", bg = "iris", blend = 10 },

-- 		-- By default each group adds to the existing config.
-- 		-- If you only want to set what is written in this config exactly,
-- 		-- you can set the inherit option:
-- 		Search = { bg = "gold", inherit = false },
-- 	},
-- })

-- -- Set colorscheme after options
-- vim.cmd("colorscheme rose-pine")
