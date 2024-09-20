return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Top bar filename
			{ "j-hui/fidget.nvim", opts = {} },

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
				ruff = {
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
				},

				-- Disable formatting provider since we're using biome
				tsserver = {
					server_capabilities = {
						documentFormattingProvider = false,
					},
				},
				biome = {
					cmd = { "biome", "lsp-proxy" },
					root_dir = lspconfig.util.root_pattern("package.json", "node_modules", "biome.json"),
				},
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
				"ruff",
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
				formatters = {
					sqlfluff = {
						command = "sqlfluff",
						stdin = true,
						args = {
							"format",
							"--dialect",
							"redshift",
							"--config",
							"/Users/" .. (os.getenv("USER") or os.getenv("USERNAME")) .. "/.config/.sqlfluff",
							"-",
						},
					},
					ruff_organize_imports = {
						command = "ruff",
						args = {
							"check",
							"--force-exclude",
							"--select=I001",
							"--fix",
							"--exit-zero",
							"--stdin-filename",
							"$FILENAME",
							"-",
						},
						stdin = true,
						cwd = require("conform.util").root_file({
							"pyproject.toml",
							"ruff.toml",
							".ruff.toml",
						}),
					},
				},
				formatters_by_ft = {
					lua = { "stylua" },
					sql = { "sqlfluff" },
					python = { "ruff_format", "ruff_organize_imports" },
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
		end,
	},
}
