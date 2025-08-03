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
			{
				"mrcjkb/rustaceanvim",
				version = "^6",
			},
		},
		config = function()
			local capabilities = nil
			if pcall(require, "cmp_nvim_lsp") then
				capabilities = require("cmp_nvim_lsp").default_capabilities()
			end

			local lspconfig = require("lspconfig")

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

				-- rust_analyzer = {
				-- 	settings = {
				-- 		-- Enable all features for monorepo support
				-- 		cargo = {
				-- 			buildScripts = {
				-- 				enable = true,
				-- 			},
				-- 			-- Load all targets (important for monorepos)
				-- 			allTargets = true,
				-- 			-- Use workspace root
				-- 			loadOutDirsFromCheck = true,
				-- 			-- Enable features for all crates
				-- 			features = "all",
				-- 		},
				-- 		-- Enhanced diagnostics
				-- 		diagnostics = {
				-- 			enable = true,
				-- 			enableExperimental = true,
				-- 			-- Show diagnostics for disabled code
				-- 			disabled = {},
				-- 		},
				-- 		-- Improved checking
				-- 		check = {
				-- 			command = "clippy",
				-- 			allTargets = true,
				-- 			features = "all",
				-- 			extraArgs = { "--all", "--", "-W", "clippy::all" },
				-- 		},
				-- 		-- Better proc macro support
				-- 		procMacro = {
				-- 			enable = true,
				-- 			ignored = {},
				-- 		},
				-- 		-- Workspace symbol search
				-- 		workspace = {
				-- 			symbol = {
				-- 				search = {
				-- 					scope = "workspace_and_dependencies",
				-- 				},
				-- 			},
				-- 		},
				-- 		-- Import resolution
				-- 		imports = {
				-- 			granularity = {
				-- 				group = "module",
				-- 			},
				-- 			prefix = "self",
				-- 		},
				-- 		-- Lens settings
				-- 		lens = {
				-- 			enable = true,
				-- 			run = {
				-- 				enable = true,
				-- 			},
				-- 			debug = {
				-- 				enable = true,
				-- 			},
				-- 			implementations = {
				-- 				enable = true,
				-- 			},
				-- 			references = {
				-- 				adt = {
				-- 					enable = true,
				-- 				},
				-- 				enumVariant = {
				-- 					enable = true,
				-- 				},
				-- 				method = {
				-- 					enable = true,
				-- 				},
				-- 				trait = {
				-- 					enable = true,
				-- 				},
				-- 			},
				-- 		},
				-- 		-- Hover actions
				-- 		hover = {
				-- 			actions = {
				-- 				enable = true,
				-- 			},
				-- 		},
				-- 	},
				-- 	-- Ensure proper root directory detection for monorepos
				-- 	root_dir = function(fname)
				-- 		local cargo_crate_dir = lspconfig.util.root_pattern("Cargo.toml")(fname)
				-- 		local cargo_workspace_dir =
				-- 			lspconfig.util.root_pattern("Cargo.lock", "rust-project.json")(fname)
				-- 		return cargo_workspace_dir or cargo_crate_dir
				-- 	end,
				-- 	-- Add environment variables if needed
				-- 	cmd = {
				-- 		"rust-analyzer",
				-- 	},
				-- 	-- Set initialization options
				-- 	init_options = {
				-- 		lspMux = nil,
				-- 	},
				-- },

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
				ts_ls = {
					server_capabilities = {
						documentFormattingProvider = false,
					},
				},

				prettierd = {
					root_dir = lspconfig.util.root_pattern("package.json", "node_modules", ".prettierrc.json"),
				},

				biome = {
					cmd = { "biome", "lsp-proxy" },
					root_dir = lspconfig.util.root_pattern("package.json", "node_modules", "biome.json"),
					workspace_required = true,
				},

				tailwindcss = true,
				astro = true,
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
				"tailwindcss-language-server",
				"yamlls",
				"astro",
				"terraformls",
				"stylua",
				"bashls",
				"html",
				"ruff",
				"rust-analyzer",
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
					json = { "biome-check" },
					javascript = { "biome-check" },
					javascriptreact = { "biome-check" },
					typescript = { "biome-check" },
					typescriptreact = { "biome-check" },
					astro = { "prettierd" },
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
