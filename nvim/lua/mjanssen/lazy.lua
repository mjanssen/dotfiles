local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
 		"--filter=blob:none",
 		"https://github.com/folke/lazy.nvim.git",
 		"--branch=stable", -- latest stable release
 		lazypath,
 	})
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
    {
		"nvim-telescope/telescope.nvim",
		version = "0.1.4",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Themes
	{ "catppuccin/nvim", name = "catppuccin" },
	{ "rose-pine/neovim", name = "rose-pine" },
	"navarasu/onedark.nvim",
	"rebelot/kanagawa.nvim",

	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"nvim-treesitter/playground",

	"nvim-lualine/lualine.nvim",

	-- Mason & LSP
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",

    -- Rust
    "simrat39/rust-tools.nvim",

	-- Autocomplete
	"L3MON4D3/LuaSnip",
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
		},
	},

	-- Formatter
	"mhartington/formatter.nvim",

	-- Git
	"f-person/git-blame.nvim",
	"tpope/vim-fugitive",

	-- Utils
	"tpope/vim-commentary",
	"folke/zen-mode.nvim",
	"theprimeagen/harpoon",
	"mbbill/undotree",
}

local opts = {}

require("lazy").setup(plugins, ops)
