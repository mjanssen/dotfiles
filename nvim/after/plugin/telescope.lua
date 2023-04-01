local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', "<leader>pg", builtin.live_grep, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

-- Style telescope with the styling of catppuccin
local colors = require("catppuccin.palettes").get_palette()
local TelescopeColor = {
	TelescopeMatching = { fg = colors.flamingo },
	TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },

	TelescopePromptPrefix = { bg = colors.mantle },
	TelescopePromptNormal = { bg = colors.mantle },
	TelescopeResultsNormal = { bg = colors.mantle, fg = colors.surface0 },
	TelescopePreviewNormal = { bg = colors.mantle },
	TelescopePromptBorder = { bg = colors.mantle, fg = colors.surface0 },
	TelescopeResultsBorder = { bg = colors.mantle, fg = colors.surface0 },
	TelescopePreviewBorder = { bg = colors.mantle, fg = colors.surface0 },
	TelescopePromptTitle = { bg = colors.mantle, fg = colors.surface0 },
	TelescopePreviewTitle = { bg = colors.mantle, fg = colors.surface0 },
}

for hl, col in pairs(TelescopeColor) do
	vim.api.nvim_set_hl(0, hl, col)
end
