local cmp = require('cmp')

local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = {
    -- select = false to not select first item upon pressing select
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<C-y>'] = cmp.mapping.confirm({ select = false }),

    -- Autocomplete suggestions
    ["<C-Space>"] = cmp.mapping.complete(),

    ['<Up>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<Down>'] = cmp.mapping.select_next_item(cmp_select),

    ['<C-p>'] = cmp.mapping(function()
        if cmp.visible() then
            cmp.select_prev_item(cmp_select)
        else
            cmp.complete()
        end
    end),
    ['<C-n>'] = cmp.mapping(function()
        if cmp.visible() then
            cmp.select_next_item(cmp_select)
        else
            cmp.complete()
        end
    end),
}

cmp.setup {
    -- Select first item in the list automatically
    completion = {
        completeopt = 'menu,menuone,noinsert'
    },
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp', keyword_length = 1 },
        { name = 'buffer',   keyword_length = 1 },
        { name = 'luasnip',  keyword_length = 1 },
    },
    mapping = cmp_mappings,
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    formatting = {
        fields = { 'abbr', 'menu', 'kind' },
        format = function(entry, item)
            local short_name = {
                nvim_lsp = 'LSP',
                nvim_lua = 'nvim'
            }

            local menu_name = short_name[entry.source.name] or entry.source.name

            item.menu = string.format('[%s]', menu_name)
            return item
        end,
    },
}
