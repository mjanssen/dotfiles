return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",

			-- Autoformatting
			{
				"stevearc/conform.nvim",
				event = { "BufWritePre" },
				cmd = { "ConformInfo" },
				opts = function()
					local util = require("conform.util")
					return {
						default_format_opts = {
							lsp_format = "fallback",
						},
						formatters = {
							["biome-check"] = {
								-- Require working directory to be found
								require_cwd = true,
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
								cwd = util.root_file({
									"pyproject.toml",
									"ruff.toml",
									".ruff.toml",
								}),
							},
						},
						format_on_save = {
							timeout_ms = 5000,
							lsp_fallback = true,
						},
						formatters_by_ft = {
							lua = { "stylua" },
							sql = { "sqlfluff" },
							python = { "ruff_format", "ruff_organize_imports" },
							json = { "biome-check" },
							-- TS/JS files
							javascript = { "biome-check" },
							javascriptreact = { "biome-check" },
							typescript = { "biome-check" },
							typescriptreact = { "biome-check" },
						},
					}
				end,
			},

			-- Schema information
			"b0o/SchemaStore.nvim",
			{
				-- This plugin requires rust-analyzer to be installed. Rustup is the way to go here:
				-- > rustup component add rust-analyzer
				-- From the author:
				-- "I strongly recommend against using rust-analyzer managed by mason.nvim, as version mismatches between
				-- rust-analyzer and your project toolchain can and most likely will lead to subtle issues."
				"mrcjkb/rustaceanvim",
				version = "^6",
				lazy = false,
				init = function()
					vim.g.rustaceanvim = {
						server = {
							default_settings = {
								["rust-analyzer"] = {
									-- Disable cache priming to save RAM
									cachePriming = {
										enable = false,
									},
									-- Don't eagerly load all feature flags
									cargo = {
										allFeatures = false,
										buildScripts = { enable = true }, -- proc macros
									},
									-- The boolean toggle
									checkOnSave = true,
									-- The actual command configuration
									check = {
										command = "clippy",
										workspace = false,
									},

									files = {
										excludeDirs = { "target", "node_modules", ".git", "dist" },
									},
								},
							},
						},
					}
				end,
			},
		},
		config = function()
			local capabilities = nil
			if pcall(require, "cmp_nvim_lsp") then
				capabilities = require("cmp_nvim_lsp").default_capabilities()
			end

			-- Force utf-16 across all servers. Biome can't negotiates utf-8 by default which causes conflicts
			capabilities = capabilities or vim.lsp.protocol.make_client_capabilities()
			capabilities.general = capabilities.general or {}
			capabilities.general.positionEncodings = { "utf-16" }

			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
			local servers = {
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

				-- Python LSP
				ty = {
					settings = {},
				},

				ts_ls = {
					init_options = {
						maxTsServerMemory = 8192,
					},
					-- always try the path imports, rather than relative paths
					settings = {
						typescript = {
							preferences = {
								importModuleSpecifier = "absolute",
								importModuleSpecifierEnding = "minimal",
							},
						},
						javascript = {
							preferences = {
								importModuleSpecifier = "absolute",
								importModuleSpecifierEnding = "minimal",
							},
						},
					},
					-- Disable formatting provider since we're using biome
					server_capabilities = {
						documentFormattingProvider = false,
					},
				},

				biome = {
					cmd = { "biome", "lsp-proxy" },
					root_markers = { "biome.json", "biome.jsonc" },
					workspace_required = true,
					offset_encoding = "utf-16",
				},

				tailwindcss = true,
			}

			local servers_to_install = vim.tbl_filter(function(key)
				local t = servers[key]
				if type(t) == "table" then
					return not t.manual_install
				else
					return t
				end
			end, vim.tbl_keys(servers))

			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			local ensure_installed = {
				"stylua",
				"bashls",
				"html",
				"ruff",
			}

			vim.list_extend(ensure_installed, servers_to_install)
			require("mason-lspconfig").setup({ ensure_installed = ensure_installed })

			for name, config in pairs(servers) do
				if config == true then
					config = {}
				end
				config = vim.tbl_deep_extend("force", {}, {
					capabilities = capabilities,
					offset_encoding = "utf-16",
				}, config)

				vim.lsp.config(name, config)
			end

			local disable_semantic_tokens = {
				lua = true,
			}

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

					local settings = servers[client.name]
					if type(settings) ~= "table" then
						settings = {}
					end

					vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
					vim.keymap.set("n", "gr", function()
						require("telescope.builtin").lsp_references()
					end, { buffer = bufnr })

					vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = bufnr })
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr })
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })

					vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, { buffer = bufnr })
					vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, { buffer = bufnr })

					local filetype = vim.bo[bufnr].filetype
					if disable_semantic_tokens[filetype] then
						client.server_capabilities.semanticTokensProvider = nil
					end

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
		end,
	},
}
