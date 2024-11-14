-- lua/plugins/init.lua
return {
    -- Color scheme
    { "bluz71/vim-nightfly-colors", name = "nightfly", lazy = false, priority = 1000, config = function() vim.cmd([[colorscheme nightfly]]) end, },
    --{ "folke/tokyonight.nvim", lazy = false, priority = 1000, config = function() vim.cmd([[colorscheme tokyonight]]) end, },

    -- LSP Support
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
    },

    -- Mason for LSP installation
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        config = function()
            require("mason").setup()
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "clangd",
                    "pyright",
                    "rust_analyzer",
                    "zls",
                },
                automatic_installation = true,
            })
        end,
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "cpp", "python", "lua", "vim", "rust", "zig" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- Git integration
    {
        "tpope/vim-fugitive",
        config = function()
            -- Example Neovim Lua configuration for Fugitive key mappings
            vim.api.nvim_set_keymap('n', '<Leader>gs', ':G status<CR>', { noremap = true, silent = true })  -- Git status
            vim.api.nvim_set_keymap('n', '<Leader>gd', ':G diff<CR>', { noremap = true, silent = true })    -- Git diff
            vim.api.nvim_set_keymap('n', '<Leader>gc', ':G commit<CR>', { noremap = true, silent = true })  -- Git commit
            vim.api.nvim_set_keymap('n', '<Leader>gp', ':G push<CR>', { noremap = true, silent = true })    -- Git push
            vim.api.nvim_set_keymap('n', '<Leader>gl', ':G log<CR>', { noremap = true, silent = true })    -- Git log
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    prompt_prefix = "❯ ",
                    selection_caret = "❯ ",
                }
            })
        end,
    },

    -- C++ Project Handling
    {
        "p00f/clangd_extensions.nvim",
        lazy = true,
        config = function()
            require("cmake-tools").setup()
        end,
    },

    {
        "Civitasv/cmake-tools.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("cmake-tools").setup({})
        end,
    },

    {
        "jose-elias-alvarez/null-ls.nvim",
    }
}
