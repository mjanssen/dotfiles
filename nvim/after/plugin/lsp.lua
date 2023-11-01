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

local function on_list(options)
	local items = options.items
	if #items > 1 then
		items = filter(items, filterTypeDTS)
	end

	vim.fn.setqflist({}, " ", { title = options.title, items = items, context = options.context })
	vim.api.nvim_command("cfirst") -- or maybe you want 'copen' instead of 'cfirst'
end

-- keybindings
-- https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
local on_attach = function(event, bufnr)
	-- Inlay hints -- enable when stable
	-- local client = vim.lsp.get_client_by_id(event.data.client_id)
	-- if client.server_capabilities.inlayHintProvider then
		-- vim.lsp.inlay_hint(event.buf, true)
	-- end

	local opts = { buffer = event.buf, remap = false }

	-- Strip out node_module suggestions
	vim.keymap.set("n", "gd", function()
		vim.lsp.buf.definition({ on_list = on_list })
	end, opts)

	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

	vim.keymap.set("n", "<K>", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = on_attach,
})

require("mason").setup({
	ensure_installed = {
		"black",
	},
})

require("mason-lspconfig").setup({
	ensure_installed = {
		"ruff_lsp",
		"pylsp",
		"biome",
		"tsserver",
		"lua_ls",
		"rust_analyzer",
		"tailwindcss",
		"denols",
	},
})

local lspconfig = require("lspconfig")
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

local mason_lsp_default_handler = function(server_name)
	lspconfig[server_name].setup({
		capabilities = lsp_capabilities,
	})
end

require("mason-lspconfig").setup_handlers({
	mason_lsp_default_handler,
	["lua_ls"] = function()
		lspconfig.lua_ls.setup({
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
		})
	end,
	["tsserver"] = function()
		lspconfig.tsserver.setup({
			single_file_support = false,
			settings = {
				completions = {
					completeFunctionCalls = true,
				},
			},
		})
	end,
	["biome"] = function()
		lspconfig.biome.setup({
			cmd = { "biome", "lsp_proxy" },
		})
	end,
	["denols"] = function()
		lspconfig.denols.setup({
			root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
		})
	end,
})

lspconfig.biome.setup({})
lspconfig.astro.setup({})

lspconfig.ruff_lsp.setup({
	on_attach = on_attach,
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

-- Python
lspconfig.pylsp.setup({
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

vim.diagnostic.config({
	virtual_text = true,
	float = {
		format = function(diagnostic)
			return string.format("%s <%s>", diagnostic.message, diagnostic.source)
		end,
	},
})
