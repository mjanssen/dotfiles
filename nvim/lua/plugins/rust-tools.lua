return {
	"simrat39/rust-tools.nvim",
	opts = function(_, opts)
        local rt = require("rust-tools")

		opts.server = {
			on_attach = function(_, bufnr)
				-- Hover actions
				vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
				-- Code action groups
				vim.keymap.set("n", "<Leader>ca", rt.code_action_group.code_action_group, { buffer = bufnr })
			end,
		}
	end,
}
