-- lua/plugins/lsp.lua
return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local lspconfig = require("lspconfig")
        local util = require("lspconfig.util")

        -- Enable debug logging for LSP
        vim.lsp.set_log_level("warn")

        -- LSP setups
        lspconfig.clangd.setup({
            capabilities = capabilities,
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
                "--suggest-missing-includes",
                "--compile-commands-dir=build",  -- Explicitly point to build directory
                "--query-driver=/usr/bin/c++",   -- Match your compiler
            },
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
            root_dir = function(fname)
                return util.root_pattern(
                    "compile_commands.json",
                    "compile_flags.txt",
                    "CMakeLists.txt",
                    ".git",
                    "build"
                )(fname) or util.find_git_ancestor(fname) or vim.fn.getcwd()
            end,
            init_options = {
                compilationDatabasePath = "build",
                fallbackFlags = {
                    "-I/usr/include",
                    "-I/usr/local/include",
                    "-I" .. vim.fn.expand("$HOME") .. "/.local/include",
                }
            },
            on_init = function(client, _)
                client.notify("workspace/didChangeConfiguration", {
                    settings = {
                        compilationDatabasePath = "build"
                    }
                })
            end,
        })

        lspconfig.pyright.setup({
            capabilities = capabilities,
            root_dir = function(fname)
                return util.root_pattern(
                    "pyproject.toml",
                    "setup.py",
                    "setup.cfg",
                    "requirements.txt",
                    ".git"
                )(fname) or util.find_git_ancestor(fname) or vim.fn.getcwd()
            end,
        })

        -- Rust configuration
        lspconfig.rust_analyzer.setup({
            capabilities = capabilities,
            settings = {
                ["rust-analyzer"] = {
                    diagnostics = {
                        enable = true,
                    },
                    checkOnSave = {
                        command = "clippy",
                    },
                    cargo = {
                        allFeatures = true,
                    },
                    procMacro = {
                        enable = true,
                    },
                },
            },
        })

        -- Zig configuration
        lspconfig.zls.setup({
            capabilities = capabilities,
            cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/zls") },
            filetypes = { "zig" },
            root_dir = function(fname)
                return util.root_pattern(
                    "build.zig",
                    "build.zig.zon",
                    ".git"
                )(fname) or vim.fn.expand("%:p:h")
            end,
            settings = {
                zls = {
                    enable_inlay_hints = true,
                    inlay_hints_show_variable_type_hints = true,
                    inlay_hints_show_parameter_name = true,
                    semantic_tokens = true,
                    enable_snippets = true,
                    warn_style = true,
                    highlight_global_var_declarations = true,
                    operator_completions = true,
                    include_at_in_builtins = true,
                },
            },
            on_attach = function(client, bufnr)
                -- Enable document formatting if supported
                if client.server_capabilities.documentFormattingProvider then
                    vim.api.nvim_buf_create_user_command(bufnr, "Format",
                        function() vim.lsp.buf.format({ async = true }) end,
                        { desc = "Format current buffer with LSP" }
                    )
                end

                -- Disable inlay hints by default
                if client.server_capabilities.inlayHintProvider then
                    vim.lsp.inlay_hint.enable(false)
                end
            end,
        })

        -- Add these commands to toggle inlay hints
        vim.api.nvim_create_user_command('InlayHintsToggle', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, {})

        -- Global LSP keymaps
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder" })
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder" })
        vim.keymap.set("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, { desc = "List workspace folders" })
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Type definition" })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
        vim.keymap.set("n", "<leader>cf", function() require("telescope.builtin").lsp_code_actions() end,
            { desc = "Code action (Telescope)" })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
        vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
        end, { desc = "Format code" })


        -- Add border to hover windows
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover, {
                border = "rounded",
            }
        )

        -- Show diagnostics in a floating window on cursor hold
        vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            callback = function()
                local opts = {
                    focusable = false,
                    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                    border = "rounded",
                    source = "always",
                    prefix = " ",
                    scope = "cursor",
                }
                vim.diagnostic.open_float(nil, opts)
            end
        })

        -- Diagnostic configuration
        vim.diagnostic.config({
            signs = {
                severity = {
                    min = vim.diagnostic.severity.HINT, -- Set minimum severity level for signs
                },
                values = {
                    { name = "DiagnosticSignError", text = "E" },
                    { name = "DiagnosticSignWarn",  text = "W" },
                    { name = "DiagnosticSignInfo",  text = "I" },
                    { name = "DiagnosticSignHint",  text = "H" },
                },
            },
        })

        -- Sign configuration
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
    end,
}
