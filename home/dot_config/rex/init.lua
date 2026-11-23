-- Migrated from ~/.config/tmux/tmux.conf (prefix ctrl+a)
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>r", "client.config.reload")

-- tmux `bind -r` bindings: a plain sequence, plus repeat mode (ctrl+a ctrl+r; enter or escape leaves)
rex.mode("repeat", { exclusive = true })
rex.bind("ctrl+a>ctrl+r", "client.mode.enter", { name = "repeat" })
rex.bind("repeat/enter", "client.mode.exit")
rex.bind("repeat/escape", "client.mode.exit")

rex.bind("ctrl+a>k", "pane.focus", { direction = "up" })
rex.bind("repeat/k", "pane.focus", { direction = "up" })
rex.bind("ctrl+a>j", "pane.focus", { direction = "down" })
rex.bind("repeat/j", "pane.focus", { direction = "down" })
rex.bind("ctrl+a>h", "pane.focus", { direction = "left" })
rex.bind("repeat/h", "pane.focus", { direction = "left" })
rex.bind("ctrl+a>l", "pane.focus", { direction = "right" })
rex.bind("repeat/l", "pane.focus", { direction = "right" })

rex.bind("ctrl+a>ctrl+u", "pane.resize", { amount = 10, direction = "left" })
rex.bind("repeat/ctrl+u", "pane.resize", { amount = 10, direction = "left" })
rex.bind("ctrl+a>ctrl+p", "pane.resize", { amount = 10, direction = "right" })
rex.bind("repeat/ctrl+p", "pane.resize", { amount = 10, direction = "right" })
rex.bind("ctrl+a>ctrl+i", "pane.resize", { amount = 10, direction = "up" })
rex.bind("repeat/ctrl+i", "pane.resize", { amount = 10, direction = "up" })
rex.bind("ctrl+a>ctrl+o", "pane.resize", { amount = 10, direction = "down" })
rex.bind("repeat/ctrl+o", "pane.resize", { amount = 10, direction = "down" })

-- tmux `ctrl+a f` sessionizer: fzf over project dirs in a floating pane, then switch to/create that session
rex.action({
	name = "sessionizer",
	title = "Open Project Session…",
	run = function(ctx, args)
		local _, err = rex.session.new_layer({
			bounds = { 0.15, 0.15, 0.7, 0.7 },
			focus = true,
			layout = rex.layout.block({
				flavor = "com.superlogical.terminal.shell",
				options = { command = { os.getenv("HOME") .. "/.config/rex/rex-sessionizer.sh" } },
			}),
		})
		if err ~= nil then
			error(err, 0)
		end
	end,
})
rex.bind("ctrl+a>f", "sessionizer")

-- tmux splits: % side by side, " stacked (cmd+d / shift+cmd+d defaults stay)
rex.bind("ctrl+a>shift+5", "pane.split", { direction = "right" })
rex.bind("ctrl+a>shift+'", "pane.split", { direction = "down" })

-- tmux `ctrl+a N`: live CPU/RAM view of nvim sessions and language servers
rex.action({
	name = "nvim_sessions",
	title = "Neovim Sessions (CPU/RAM)…",
	run = function(ctx, args)
		local _, err = rex.session.new_layer({
			bounds = { 0.05, 0.1, 0.9, 0.8 },
			focus = true,
			layout = rex.layout.block({
				flavor = "com.superlogical.terminal.shell",
				options = { command = { os.getenv("HOME") .. "/.local/bin/nvim-sessions" } },
			}),
		})
		if err ~= nil then
			error(err, 0)
		end
	end,
})
rex.bind("ctrl+a>shift+n", "nvim_sessions")

-- tmux `ctrl+a [`: keyboard copy mode (v/V/ctrl+v select, y or enter yank, q/esc leave). Needs the Bleeding Edge channel for now.
rex.bind("ctrl+a>[BracketLeft]", "pane.copy_mode.enter")
