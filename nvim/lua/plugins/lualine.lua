return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    opts = function(_, opts)
        opts.options = {
            theme = "dracula",
            icons_enabled = true,
        }
    end,
}
