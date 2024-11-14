-- Telescope
return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local telescope = require("telescope")
        telescope.setup({
            defaults = {
                prompt_prefix = "❯ ",
                selection_caret = "❯ ",
                file_ignore_patterns = { "node_modules", ".git" },
            }
        })

        -- Key mappings
        vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
        vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
        vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "List open buffers" })
        vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help" })

        -- Zig-specific searches
        vim.keymap.set('n', '<leader>zf', '<cmd>Telescope find_files find_command=fd,--type,f,--extension,zig<cr>', { desc = 'Find Zig files' })
    end,
}
