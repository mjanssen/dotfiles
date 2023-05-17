local null_ls = require("null-ls");

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.ruff,
        null_ls.builtins.formatting.ruff,
        null_ls.builtins.formatting.rome
    },
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end

        -- Disable diagnostics for helm files
        if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
            vim.diagnostic.disable(bufnr)
        end
    end,
})
