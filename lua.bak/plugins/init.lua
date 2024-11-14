return {
    -- the colorscheme should be available when starting Neovim
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyonight]])
        end,
    },
--[=====[
    -- Mason plugin to manage LSPs
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },

    -- mason-lspconfig to link Mason with nvim-lspconfig
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "clangd", "pyright" }, -- Add other LSPs as needed
            })
        end,
    },
--]=====]
    -- nvim-lspconfig (LSP support)
    {
        "neovim/nvim-lspconfig",
        config = function()
            -- Example setup for C++ LSP (clangd)
            require('lspconfig').clangd.setup{}
            -- Example setup for Python LSP (pyright)
            require('lspconfig').pyright.setup{}
        end,
    },

    -- nvim-treesitter (Syntax highlighting and code parsing)
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { "cpp", "python" }, -- Add other languages as needed
                highlight = { enable = true },
            }
        end,
    },

    -- coc.nvim (for intelligent completion)
    {
        "neoclide/coc.nvim",
        branch = "release",
        config = function()
            -- Set up the Python and C/C++ completions for coc.nvim
            -- vim.cmd([[CocInstall coc-pyright coc-clangd]])
        end,
    },

    -- ale (Asynchronous Lint Engine)
    {
        "dense-analysis/ale",
        config = function()
            -- Example for enabling ALE linters for C/C++ and Python
            vim.g.ale_linters = {
                python = {'flake8', 'pylint'},
                cpp = {'clang', 'gcc'},
            }
        end,
    },

    -- vim-fugitive (Git integration)
    {
        "tpope/vim-fugitive",
    },

    -- telescope.nvim (File search)
    {
        "nvim-telescope/telescope.nvim",
        requires = {"nvim-lua/plenary.nvim"},
        config = function()
            require('telescope').setup {
                defaults = {
                    prompt_prefix = "> ",
                    selection_caret = "> ",
                }
            }
        end,
    },
}
