-- Keep the chezmoi source copy of lazy-lock.json in step with the live one.
--
-- The source file carries chezmoi's `create_` attribute, which means chezmoi
-- seeds it on a fresh machine and then never writes to it again. That is what
-- stops `chezmoi apply` from overwriting the lockfile with a stale pin set, but
-- it also means chezmoi will never pick up lazy.nvim's updates on its own:
-- `chezmoi re-add` is a no-op on a create_ file, and `chezmoi add` would
-- silently strip the prefix and undo the protection. So copy the file directly.
--
-- The destination comes from `chezmoi source-path`, which resolves the create_
-- prefix for us, so renaming or re-attributing the source file cannot break
-- this. Everything is async: nothing here blocks startup or the Lazy UI.

local lockfile = vim.fs.joinpath(vim.fn.stdpath("config"), "lazy-lock.json")

local function sync_lockfile()
	if vim.fn.executable("chezmoi") ~= 1 or vim.uv.fs_stat(lockfile) == nil then
		return
	end

	vim.system({ "chezmoi", "source-path", lockfile }, { text = true, timeout = 10000 }, function(res)
		-- Non-zero means the file is not managed by chezmoi on this machine,
		-- which is a perfectly normal state. Stay quiet.
		if res.code ~= 0 then
			return
		end

		local dest = vim.trim(res.stdout or "")
		if dest == "" then
			return
		end

		vim.schedule(function()
			local ok, err = vim.uv.fs_copyfile(lockfile, dest)
			if ok then
				vim.notify(
					"lazy-lock.json -> chezmoi source (" .. vim.fs.basename(dest) .. ")",
					vim.log.levels.INFO
				)
			else
				vim.notify("chezmoi lockfile sync failed: " .. tostring(err), vim.log.levels.ERROR)
			end
		end)
	end)
end

-- lazy.nvim rewrites the lockfile after any operation that changes what is
-- installed. It fires these User events once the operation has finished.
vim.api.nvim_create_autocmd("User", {
	pattern = { "LazyInstall", "LazyUpdate", "LazySync", "LazyClean", "LazyRestore" },
	callback = function()
		-- Let lazy.nvim finish writing the file before reading it.
		vim.defer_fn(sync_lockfile, 500)
	end,
})

-- For the times the lockfile drifts for some other reason.
vim.api.nvim_create_user_command("ChezmoiSyncLock", sync_lockfile, {
	desc = "Copy lazy-lock.json into the chezmoi source directory",
})

return { sync = sync_lockfile }
