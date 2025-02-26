return {
    "jose-elias-alvarez/null-ls.nvim",
    event = "VeryLazy",
    config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                -- clang-format with style argument (e.g., 'LLVM', 'Google')
                null_ls.builtins.formatting.clang_format.with({
                    extra_args = { "--style=Google" },  -- Optional: Change to 'LLVM', 'Chromium', etc.
                }),

                -- black for Python, with additional arguments
                null_ls.builtins.formatting.black.with({
                    extra_args = { "--fast", "--line-length=79" },  -- Add or adjust args as needed
                }),
            },
        })
    end,
}
