return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			{ "j-hui/fidget.nvim", opts = {} },
			{ "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },

			-- Autoformatting
			"stevearc/conform.nvim",

			-- Schema information
			"b0o/SchemaStore.nvim",
		},
		config = function()
			local capabilities = nil
			if pcall(require, "cmp_nvim_lsp") then
				capabilities = require("cmp_nvim_lsp").default_capabilities()
			end

			local lspconfig = require("lspconfig")

			local servers = {
				bashls = true,
				gopls = {
					settings = {
						gopls = {
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
						},
					},
					server_capabilities = {
						semanticTokensProvider = vim.NIL,
					},
				},
				rust_analyzer = true,
				pyright = {
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
				},

				-- Disable formatting provider since we're using biome
				tsserver = {
					server_capabilities = {
						documentFormattingProvider = false,
					},
				},
				biome = true,
				tailwindcss = true,

				jsonls = {
					settings = {
						json = {
							schemas = require("schemastore").json.schemas(),
							validate = { enable = true },
						},
					},
				},
			}

			local servers_to_install = vim.tbl_filter(function(key)
				local t = servers[key]
				if type(t) == "table" then
					return not t.manual_install
				else
					return t
				end
			end, vim.tbl_keys(servers))

			require("mason").setup()
			local ensure_installed = {
				"stylua",
				"lua_ls",
				"delve",
				"tailwindcss-language-server",
			}

			vim.list_extend(ensure_installed, servers_to_install)
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for name, config in pairs(servers) do
				if config == true then
					config = {}
				end
				config = vim.tbl_deep_extend("force", {}, {
					capabilities = capabilities,
				}, config)

				lspconfig[name].setup(config)
			end

			local disable_semantic_tokens = {
				lua = true,
			}

			-- local navic = require("nvim-navic")

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

					local settings = servers[client.name]
					if type(settings) ~= "table" then
						settings = {}
					end

					-- if client.server_capabilities.documentSymbolProvider then
					-- 	navic.attach(client, bufnr)
					-- end

					local builtin = require("telescope.builtin")

					vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
					vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = 0 })
					vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = 0 })
					vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = 0 })
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })

					vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, { buffer = 0 })
					vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, { buffer = 0 })

					local filetype = vim.bo[bufnr].filetype
					if disable_semantic_tokens[filetype] then
						client.server_capabilities.semanticTokensProvider = nil
					end

					-- Override server capabilities
					if settings.server_capabilities then
						for k, v in pairs(settings.server_capabilities) do
							if v == vim.NIL then
								---@diagnostic disable-next-line: cast-local-type
								v = nil
							end

							client.server_capabilities[k] = v
						end
					end
				end,
			})

			-- Autoformatting Setup with Conform
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
				},
			})

			-- Format on save
			vim.api.nvim_create_autocmd("BufWritePre", {
				callback = function(args)
					require("conform").format({
						bufnr = args.buf,
						lsp_fallback = true,
						quiet = true,
					})
				end,
			})

			-- Floating LSP help lines
			require("lsp_lines").setup()
			vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
			-- local lspconfig = require("lspconfig")

			-- local function disableFmtProvider(client, bufnr)
			-- 	if client.server_capabilities.documentSymbolProvider then
			-- 		navic.attach(client, bufnr)
			-- 	end

			-- 	-- Let Conform handle formatting
			-- 	client.server_capabilities.documentFormattingProvider = false
			-- end

			-- lspconfig.lua_ls.setup({
			-- 	settings = {
			-- 		Lua = {
			-- 			diagnostics = {
			-- 				globals = {
			-- 					"vim",
			-- 				},
			-- 			},
			-- 		},
			-- 	},
			-- })

			-- -- TS / JS
			-- lspconfig.tsserver.setup({
			-- 	on_attach = disableFmtProvider,
			-- })
			-- lspconfig.biome.setup({
			-- 	cmd = { "biome", "lsp-proxy" },
			-- 	root_dir = lspconfig.util.root_pattern("package.json", "node_modules", "biome.json"),
			-- })
			-- lspconfig.tailwindcss.setup({})

			-- -- Python
			-- lspconfig.ruff_lsp.setup({
			-- 	init_options = {
			-- 		settings = {
			-- 			args = {
			-- 				"--extend-select",
			-- 				"E",
			-- 				"--extend-select",
			-- 				"F",
			-- 				"--extend-select",
			-- 				"W",
			-- 				"--extend-select",
			-- 				"I",
			-- 				"--extend-select",
			-- 				"F401", -- unused imports
			-- 			},
			-- 		},
			-- 	},
			-- })

			-- lspconfig.pyright.setup({
			-- 	settings = {
			-- 		pyright = {
			-- 			disableOrganizeImports = true,
			-- 		},
			-- 		python = {
			-- 			analysis = {
			-- 				ignore = { "*" },
			-- 			},
			-- 		},
			-- 	},
			-- })

			-- -- Golang
			-- lspconfig.gopls.setup({})

			-- -- Rust
			-- lspconfig.rust_analyzer.setup({
			-- 	on_attach = function(client, bufnr)
			-- 		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			-- 	end,
			-- 	settings = {
			-- 		["rust-analyzer"] = {
			-- 			imports = {
			-- 				granularity = {
			-- 					group = "module",
			-- 				},
			-- 				prefix = "self",
			-- 			},
			-- 			cargo = {
			-- 				buildScripts = {
			-- 					enable = true,
			-- 				},
			-- 			},
			-- 			procMacro = {
			-- 				enable = true,
			-- 			},
			-- 		},
			-- 	},
			-- })

			-- vim.api.nvim_create_autocmd("LspAttach", {
			-- 	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			-- 	callback = function(ev)
			-- 		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

			-- 		local opt = { buffer = ev.buf }

			-- 		vim.keymap.set("n", "gr", vim.lsp.buf.references, opt)
			-- 		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opt)
			-- 		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opt)

			-- 		-- Strip out node_module suggestions
			-- 		vim.keymap.set("n", "gd", function()
			-- 			vim.lsp.buf.definition({ on_list = on_list })
			-- 		end, opt)

			-- 		vim.keymap.set("n", "K", vim.lsp.buf.hover, opt)
			-- 		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opt)
			-- 		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opt)
			-- 		vim.keymap.set({ "n", "v" }, "<C-space>", vim.lsp.buf.code_action, opt)
			-- 		vim.keymap.set("n", "<leader>ff", function()
			-- 			require("conform").format({ bufnr = ev.buf, lsp_fallback = true })
			-- 		end, opt)
			-- 	end,
			-- })

			-- -- borders around hover window
			-- local _border = "rounded"

			-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			-- 	border = _border,
			-- })

			-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
			-- 	border = _border,
			-- })

			-- vim.diagnostic.config({
			-- 	float = { border = _border },
			-- })
		end,
	},
}
