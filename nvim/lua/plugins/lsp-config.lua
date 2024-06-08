local function disableFmtProvider(client)
	client.server_capabilities.documentFormattingProvider = false
end

-- Functions to skip node modules when jumping to definition
local function filter(arr, fn)
	if type(arr) ~= "table" then
		return arr
	end

	local filtered = {}
	for k, v in pairs(arr) do
		if fn(v, k, arr) then
			table.insert(filtered, v)
		end
	end

	return filtered
end

-- Skip definition files
local function filterTypeDTS(value)
	return string.match(value.filename, "%.d.ts") == nil
end

-- Onlist filters out DTS files using the above functions
local function on_list(options)
	local items = options.items
	if #items > 1 then
		items = filter(items, filterTypeDTS)
	end

	vim.fn.setqflist({}, " ", { title = options.title, items = items, context = options.context })
	vim.api.nvim_command("cfirst")
end

return {
	-- Installs all lsps
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	-- Bridges gap between mason and nvim--lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"tsserver",
					"biome",
					"ruff_lsp",
					"pyright",
					"rust_analyzer",
					"tailwindcss",
				},
			})
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^4", -- Recommended
		ft = { "rust" },
	},
	-- Setup lsp keymaps
	{
		"neovim/nvim-lspconfig",
		opts = {
			setup = {
				rust_analyzer = function()
					return true
				end,
			},
		},
		config = function()
			local lspconfig = require("lspconfig")

			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = {
								"vim",
							},
						},
					},
				},
			})

			-- TS / JS
			lspconfig.tsserver.setup({
				on_attach = disableFmtProvider,
			})
			lspconfig.biome.setup({
				cmd = { "biome", "lsp-proxy" },
				root_dir = lspconfig.util.root_pattern("package.json", "node_modules", "biome.json"),
			})
			lspconfig.tailwindcss.setup({})

			-- Python
			lspconfig.ruff_lsp.setup({
				init_options = {
					settings = {
						args = {
							"--extend-select",
							"E",
							"--extend-select",
							"F",
							"--extend-select",
							"W",
							"--extend-select",
							"I",
							"--extend-select",
							"F401", -- unused imports
						},
					},
				},
			})
			lspconfig.pyright.setup({ -- Go To Definition capabilities
				settings = {
					pyright = {
						disableOrganizeImports = true,
					},
					python = {
						analysis = {
							ignore = { "*" },
						},
					},
				},
			})

			-- Gleam
			lspconfig.gleam.setup({})

			-- Golang
			lspconfig.gopls.setup({})

			-- Rust
			--
			-- others lsp settings. --
			vim.g.rustaceanvim = function()
				return {
					-- other rustacean settings. --
					server = {
						on_attach = function()
							-- Hide semantic highlights for functions
							vim.api.nvim_set_hl(0, "@lsp.type.function", {})
							-- Hide all semantic highlights
							for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
								vim.api.nvim_set_hl(0, group, {})
							end

							vim.keymap.set("n", "K", function()
								vim.cmd.RustLsp({ "hover", "actions" })
							end, { buffer = bufnr })
							-- other settings. --
						end,
					},
					default_settings = {
						-- rust-analyzer language server configuration
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
								loadOutDirsFromCheck = true,
								runBuildScripts = true,
							},
							-- Add clippy lints for Rust.
							checkOnSave = {
								allFeatures = true,
								command = "clippy",
								extraArgs = { "--no-deps" },
							},
							procMacro = {
								enable = true,
								ignored = {
									["async-trait"] = { "async_trait" },
									["napi-derive"] = { "napi" },
									["async-recursion"] = { "async_recursion" },
								},
							},
						},
					},
				}
			end

			-- lspconfig.rust_analyzer.setup({})

			-- Rust
			-- lspconfig.rust_analyzer.setup({
			-- 	assist = {
			-- 		importEnforceGranularity = true,
			-- 		importPrefix = "crate",
			-- 	},
			-- 	cargo = {
			-- 		allFeatures = true,
			-- 	},
			-- 	inlayHints = { locationLinks = false },
			-- 	diagnostics = {
			-- 		enable = true,
			-- 		experimental = {
			-- 			enable = true,
			-- 		},
			-- 	},
			-- })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					local opt = { buffer = ev.buf }

					vim.keymap.set("n", "gr", vim.lsp.buf.references, opt)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opt)
					vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opt)

					-- Strip out node_module suggestions
					vim.keymap.set("n", "gd", function()
						vim.lsp.buf.definition({ on_list = on_list })
					end, opt)

					vim.keymap.set("n", "K", vim.lsp.buf.hover, opt)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opt)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opt)
					vim.keymap.set({ "n", "v" }, "<C-space>", vim.lsp.buf.code_action, opt)
					vim.keymap.set("n", "<leader>ff", function()
						require("conform").format({ bufnr = ev.buf, lsp_fallback = true })
					end, opt)
				end,
			})
		end,
	},
}
