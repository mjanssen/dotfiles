return {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			buffers = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
			},
			filesystem = {
				filtered_items = {
					always_show = {
						".gitignore",
						".env",
						".github",
						".cargo",
					},
				},
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
			},
			git_status = {
				symbols = {
					added = "✚",
					deleted = "✖",
					modified = "",
					renamed = "󰁕",
					untracked = "",
					ignored = "",
					unstaged = "󰄱",
					staged = "",
					conflict = "",
				},
				align = "right",
			},
		})
	end,
}
