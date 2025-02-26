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
        vim.lsp.set_log_level("error")

        -- LSP setups
        lspconfig.clangd.setup({
            capabilities = capabilities,
            cmd = {
                "C:\\Program Files\\LLVM\\bin\\clangd.exe",  -- Full path to clangd executable
                "--background-index",           -- Build index in background for faster searching
                "--clang-tidy",                -- Enable clang-tidy diagnostics
                "--header-insertion=iwyu",      -- Include what you use for headers
                "--completion-style=detailed",  -- Detailed completion items
                "--function-arg-placeholders",  -- Include function argument placeholders
                "--fallback-style=llvm",       -- LLVM coding style as fallback
                "--header-insertion-decorators",-- Decorators for headers
                "--all-scopes-completion",     -- Show completion items from all reachable scopes
                "--pch-storage=memory",        -- Store PCH in memory for faster processing
                "--log=error",                 -- Only show errors in logs
                "--j=8",                       -- Number of parallel processing threads
                "--compile-commands-dir=build", -- Look for compile_commands.json
                "--offset-encoding=utf-16",    -- Fix for null-ls
                "--enable-config",             -- Read from clangd config file
                --"--query-driver=C:/msys64/mingw64/bin/g++.exe",
                --"--query-driver=D:/MinGW/bin/g++.exe,D:/MinGW/bin/gcc.exe,C:/Program Files/LLVM/bin/clang++.exe", -- Updated driver paths
                --"--query-driver=C:/Program Files/Microsoft Visual Studio/2022/Professional/VC/Tools/MSVC/14.42.34433/bin/Hostx64/x64/cl.exe",
            },
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
            root_dir = function(fname)
                local util = require('lspconfig.util')
                return util.root_pattern(
                    "compile_commands.json",
                    "compile_flags.txt",
                    "CMakeLists.txt",
                    ".git",
                    ".clangd",
                    ".clang-format",
                    ".clang-tidy"
                )(fname) or util.find_git_ancestor(fname) or vim.fn.getcwd()
            end,
            init_options = {
                -- Clangd initialization options
                clangdFileStatus = true,
                usePlaceholders = true,
                completeUnimported = true,
                semanticHighlighting = true,
                -- Clang-tidy configuration
                clangTidy = {
                    checks = {
                        "*",
                        "-fuchsia-*",
                        "-google-*",
                        "-zircon-*",
                        "-abseil-*",
                        "-modernize-use-trailing-return-type",
                        "-llvm-*",
                    },
                    checkOptions = {
                        ["bugprone-argument-comment.StrictMode"] = true,
                        ["bugprone-assert-side-effect.AssertMacros"] = "assert,NSAssert,NSCAssert",
                        ["modernize-use-nullptr.NullMacros"] = "NULL",
                    },
                },
                fallbackFlags = {
                    "-std=c++23",
                    "-xc++",
                    "-Wall",
                    "-Wextra",
                    "-Wpedantic",
                    "-Wno-unused-parameter",
                    -- MinGW Include Paths
                    -- "-ID:/MinGW/include/c++/13.2.0/",
                    -- "-ID:/MinGW/include/c++/13.2.0/x86_64-w64-mingw32/",
                    -- "-ID:/MinGW/include/c++/13.2.0/backward/",
                    -- "-ID:/MinGW/lib/gcc/x86_64-w64-mingw32/13.2.0/include/",
                    -- "-ID:/MinGW/lib/gcc/x86_64-w64-mingw32/13.2.0/include-fixed/",
                    -- "-ID:/MinGW/x86_64-w64-mingw32/include",
                    -- MSVC Include Paths
                    "-IC:/Program Files/Microsoft Visual Studio/2022/Professional/VC/Tools/MSVC/14.42.34433/include",
                    "-IC:/Program Files/Microsoft Visual Studio/2022/Professional/VC/Tools/MSVC/14.42.34433/ATLMFC/include",
                    "-IC:/Program Files/Microsoft Visual Studio/2022/Professional/VC/Auxiliary/VS/include",
                    "-IC:/Program Files (x86)/Windows Kits/10/include/10.0.22621.0/ucrt",
                    "-IC:/Program Files (x86)/Windows Kits/10//include/10.0.22621.0//um",
                    "-IC:/Program Files (x86)/Windows Kits/10//include/10.0.22621.0//shared",
                    "-IC:/Program Files (x86)/Windows Kits/10//include/10.0.22621.0//winrt",
                    "-IC:/Program Files (x86)/Windows Kits/10//include/10.0.22621.0//cppwinrt",
                    "-IC:/Program Files (x86)/Windows Kits/NETFXSDK/4.8/include/um",
                    -- MSYS Include Paths
                    -- "-IC:/msys64/mingw64/include/c++/14.2.0/",
                    -- "-IC:/msys64/mingw64/include/c++/14.2.0/x86_64-w64-mingw32/",
                    -- "-IC:/msys64/mingw64/include/c++/14.2.0/backward/",
                    -- "-IC:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include/",
                    -- "-IC:/msys64/mingw64/include/",
                    -- "-IC:/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/14.2.0/include-fixed",
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
                    -- Enable all features in Cargo.toml
                    cargo = {
                        allFeatures = true,
                        loadOutDirsFromCheck = true,
                        runBuildScripts = true,
                    },
                    -- Detailed diagnostics
                    diagnostics = {
                        enable = true,
                        experimental = {
                            enable = true,
                        },
                        disabled = {"unresolved-proc-macro"},
                    },
                    -- Enhanced code completion
                    completion = {
                        addCallArgumentSnippets = true,
                        addCallParenthesis = true,
                        addFunctionSnippets = true,
                        postfix = {
                            enable = true,
                        },
                        autoimport = {
                            enable = true,
                        },
                        privateEditable = {
                            enable = true,
                        },
                    },
                    -- Better code analysis
                    checkOnSave = {
                        command = "clippy",
                        extraArgs = {"--all-features", "--all-targets"},
                    },
                    -- Improved hover actions
                    hover = {
                        actions = {
                            enable = true,
                            debug = true,
                            gotoTypeDef = true,
                            implementations = true,
                            run = true,
                        },
                        documentation = {
                            enable = true,
                            keywords = true,
                        },
                    },
                    -- Helpful inline hints
                    inlayHints = {
                        bindingModeHints = {
                            enable = true,
                        },
                        chainingHints = {
                            enable = true,
                        },
                        closingBraceHints = {
                            enable = true,
                            minLines = 25,
                        },
                        closureReturnTypeHints = {
                            enable = "always",
                        },
                        discriminantHints = {
                            enable = "always",
                        },
                        expressionAdjustmentHints = {
                            enable = "always",
                        },
                        lifetimeElisionHints = {
                            enable = "always",
                            useParameterNames = true,
                        },
                        parameterHints = {
                            enable = true,
                        },
                        typeHints = {
                            enable = true,
                            hideClosureInitialization = false,
                            hideNamedConstructor = false,
                        },
                    },
                    -- Enable procedure macros
                    procMacro = {
                        enable = true,
                        ignored = {},
                    },
                    -- Lens features (code actions)
                    lens = {
                        enable = true,
                        debug = true,
                        implementations = true,
                        run = true,
                        methodReferences = true,
                        references = true,
                    },
                    -- Improved imports organization
                    imports = {
                        granularity = {
                            group = "module",
                        },
                        prefix = "self",
                        enforce = true,
                    },
                    -- Better code actions
                    assist = {
                        emitMustUse = true,
                        expressionFillDefault = true,
                    },
                },
            },
            -- LSP Handlers
            handlers = {
                ["textDocument/publishDiagnostics"] = vim.lsp.with(
                    vim.lsp.diagnostic.on_publish_diagnostics, {
                        virtual_text = true,
                        signs = true,
                        update_in_insert = true,
                        underline = true,
                    }
                ),
            },
            -- On Attach
            on_attach = function(client, bufnr)
                -- Enable inlay hints by default
                if client.server_capabilities.inlayHintProvider then
                    vim.lsp.inlay_hint.enable(true)
                end

                -- Enable document formatting if supported
                if client.server_capabilities.documentFormattingProvider then
                    vim.api.nvim_buf_create_user_command(bufnr, "Format",
                        function() vim.lsp.buf.format({ async = true }) end,
                        { desc = "Format current buffer with LSP" }
                    )
                end
            end,
        })

        -- Zig configuration
        lspconfig.zls.setup({
            capabilities = capabilities,
            cmd = { "zls" },
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
        vim.keymap.set("n", "<leader>th", ":ClangdSwitchSourceHeader<CR>", { noremap = true, silent = true, desc = "Switch between source and header file" })
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
        vim.keymap.set("n", "<leader>fc", function()
            vim.lsp.buf.format({ async = true })
        end, { desc = "Format code" })
        vim.keymap.set('n', '<leader>ld', vim.diagnostic.setloclist, { noremap = true, silent = true, buffer = bufnr })

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
