return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			event_handlers = {
				{
					event = "before_git_status",
					handler = function(args)
						local ignored = vim.tbl_contains(args.status_args, "--untracked-files=no") and "--ignored=no"
							or "--ignored=matching"
						for i, a in ipairs(args.status_args) do
							if a == "--ignored=traditional" then
								args.status_args[i] = ignored
							end
						end
					end,
				},
			},
			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				use_libuv_file_watcher = true,
				filtered_items = {
					always_show = { ".gitignore", ".env", ".github", ".cargo" },
				},
			},
			buffers = {
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
			window = {
				mappings = {
					["<bs>"] = "",
				},
			},
		})
	end,
}
