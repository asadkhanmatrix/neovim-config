return {
    -- Markdown support and preview
    {
        "preservim/vim-markdown",
        dependencies = {
            "godlygeek/tabular"  -- Required for table formatting
        },
        ft = { "markdown" },
        config = function()
            -- Disable folding
            vim.g.vim_markdown_folding_disabled = 1
            -- Enable conceal for prettier display
            vim.g.vim_markdown_conceal = 1
            -- Enable math expressions
            vim.g.vim_markdown_math = 1
            -- Enable YAML frontmatter
            vim.g.vim_markdown_frontmatter = 1
            -- Auto format tables
            vim.g.vim_markdown_auto_insert_bullets = 1
            -- Enable TOC window auto-fit
            vim.g.vim_markdown_toc_autofit = 1
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        config = function()
            vim.g.mkdp_auto_start = 0
            vim.g.mkdp_auto_close = 1
            vim.g.mkdp_refresh_slow = 0
            vim.g.mkdp_command_for_global = 0
            vim.g.mkdp_open_to_the_world = 0
            vim.g.mkdp_browser = ''  -- Use default browser
            vim.g.mkdp_echo_preview_url = 1
            vim.g.mkdp_page_title = '「${name}」'
            -- Custom CSS for preview
            vim.g.mkdp_markdown_css = ''
            vim.g.mkdp_highlight_css = ''
            -- Preview port
            vim.g.mkdp_port = ''
            -- Preview page title format
            vim.g.mkdp_page_title = '「${name}」'
        end,
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Markdown Preview" },
            { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", desc = "Markdown Preview Stop" },
            { "<leader>mt", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview Toggle" },
        }
    },
}
