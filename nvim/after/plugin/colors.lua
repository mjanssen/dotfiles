require('catppuccin').setup({
    -- hide background colors
    transparent_background = true
})

function ColorScheme(color)
	-- color = color or "rose-pine"
    color = color or "catppuccin-macchiato"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorScheme()
