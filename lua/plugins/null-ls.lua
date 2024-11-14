return {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
        local null_ls = require("null-ls")
        
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.clang_format,
                null_ls.builtins.formatting.black.with({
                    extra_args = { "--fast" },  -- Optional: use '--line-length 79' or other args as needed
                }),
            },
        })
    end,
}
