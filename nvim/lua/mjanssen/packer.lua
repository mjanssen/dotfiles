-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.0',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    use { 'catppuccin/nvim', as = 'catppuccin' }

    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'nvim-treesitter/nvim-treesitter-context'

    use 'theprimeagen/harpoon'
    use 'mbbill/undotree'

    -- Mason + LSP
    use {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    }

    -- Autocomplete
    use "L3MON4D3/LuaSnip"
    use({
        "hrsh7th/nvim-cmp",
        -- config = [[require('config.nvim-cmp')]],
        requires = {
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
        },
    })

    -- Formatter
    use "mhartington/formatter.nvim"

    -- Git Blame
    use 'f-person/git-blame.nvim'
    -- Git in nvim
    use 'tpope/vim-fugitive'
    use 'tpope/vim-commentary'

    use 'folke/zen-mode.nvim'

    use 'nvim-lualine/lualine.nvim'
end)
