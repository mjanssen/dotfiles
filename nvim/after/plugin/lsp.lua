local lsp = require('lsp-zero')
local lspconfig = require('lspconfig')

lsp.preset('recommended')

lsp.ensure_installed({
    'pylsp',
    'rome',
    'tsserver',
    'lua_ls',
    'rust_analyzer',
    'tailwindcss',
    'denols'
})

-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})

lsp.configure('tsserver', {
    on_attach = lsp.on_attach,
    root_dir = lspconfig.util.root_pattern("package.json"),
    single_file_support = false
})

lsp.configure('rome', {
    on_attach = lsp.on_attach,
    cmd = { "rome", "lsp-proxy" }
})

lsp.configure('denols', {
    on_attach = lsp.on_attach,
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

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
  return string.match(value.filename, '%.d.ts') == nil
end

local function on_list(options)
  local items = options.items
  if #items > 1 then
    items = filter(items, filterTypeDTS)
  end

  vim.fn.setqflist({}, ' ', { title = options.title, items = items, context = options.context })
  vim.api.nvim_command('cfirst') -- or maybe you want 'copen' instead of 'cfirst'
end

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition{on_list=on_list} end, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end)

lspconfig.rome.setup {}

-- Python
lspconfig.pylsp.setup{
    settings = {
        pylsp = {
            plugins = {
                ruff = {
                    enabled = true,
                    extendSelect = { -- for reference, see https://beta.ruff.rs/docs/rules/#error-e
                        "I",         -- isort
                        "E",         -- pycodestyle Error
                        "W",         -- pycodestyle Warning
                    },
                    format = {
                        "I",
                    },
                    lineLength = 88,
                    exclude = { "./alembic" }
                }
            }
        }
    }
}

lsp.setup()

vim.diagnostic.config({
    virtual_text = true,
})
