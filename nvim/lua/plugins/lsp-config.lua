local function disableFmtProvider(client)
	client.server_capabilities.documentFormattingProvider = false
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
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"tsserver",
					"biome",
					"ruff_lsp",
					"pylsp",
					"rust_analyzer",
					"tailwindcss",
				},
			})
		end,
	},
	-- Setup lsp keymaps
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local lspconfig = require("lspconfig")

			lspconfig.lua_ls.setup({
				capabilities,
			})

			-- TS / JS
			lspconfig.tsserver.setup({
				capabilities,
				on_attach = disableFmtProvider,
			})
			lspconfig.biome.setup({
				capabilities,
				cmd = { "biome", "lsp-proxy" },
				root_dir = lspconfig.util.root_pattern("package.json", "node_modules", "biome.json"),
			})

			-- Python
			lspconfig.ruff_lsp.setup({
				capabilities,
				init_options = {
					settings = {
						args = {
							"--extend-select",
							"E",
							"--extend-select",
							"F",
							"--extend-select",
							"W",
						},
					},
				},
			})
			lspconfig.pylsp.setup({
				capabilities,
				settings = {
					pylsp = {
						plugins = {
							plugins = {
								pycodestyle = {
									enabled = false,
								},
								flake8 = {
									enabled = false,
								},
							},
						},
					},
				},
			})

			-- Rust
			lspconfig.rust_analyzer.setup({
				capabilities,
				assist = {
					importEnforceGranularity = true,
					importPrefix = "crate",
				},
				cargo = {
					allFeatures = true,
				},
				inlayHints = { locationLinks = false },
				diagnostics = {
					enable = true,
					experimental = {
						enable = true,
					},
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					local opt = { buffer = ev.buf }

					vim.keymap.set("n", "gr", vim.lsp.buf.references, opt)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opt)
					vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opt)

					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opt)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opt)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opt)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opt)
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opt)
					vim.keymap.set("n", "<leader>ff", function()
						vim.lsp.buf.format({ async = true })
					end, opt)
				end,
			})
		end,
	},
}
