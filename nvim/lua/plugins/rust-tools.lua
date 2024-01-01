return {
	"simrat39/rust-tools.nvim",
	opts = function(_, opts)
        local rt = require("rust-tools")

		opts.server = {
			on_attach = function(_, bufnr)
				-- Hover actions
				vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
				-- Code action groups
				vim.keymap.set("n", "<Leader>c", rt.code_action_group.code_action_group, { buffer = bufnr })
			end,
		}
	end,
}
