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
        local configs = require("lspconfig.configs")

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
                "--header-insertion-decorators",
                "--all-scopes-completion",
                "--pch-storage=memory",
                "--log=error",
                "--j=8",
                "--compile-commands-dir=build",
                "--offset-encoding=utf-16",
                "--enable-config",
                "--query-driver=/usr/bin/**/clang-*,/usr/bin/**/g++-*,/usr/bin/**/gcc-*,/usr/local/bin/g++-*",
            },
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
            root_dir = function(fname)
                -- local util = require('lspconfig.util') -- util is already defined above
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
                clangdFileStatus = true,
                usePlaceholders = true,
                completeUnimported = true,
                semanticHighlighting = true,
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
                    "-I/usr/include",
                    "-I/usr/local/include",
                    "-I" .. vim.fn.expand("$HOME") .. "/.local/include",
                }
            },
        })

        -- Python configuration (Original pyright - consider commenting out if replacing with pyrefly)
        -- lspconfig.pyright.setup({
        --     capabilities = capabilities,
        --     root_dir = function(fname)
        --         return util.root_pattern(
        --             "pyproject.toml",
        --             "setup.py",
        --             "setup.cfg",
        --             "requirements.txt",
        --             ".git"
        --         )(fname) or util.find_git_ancestor(fname) or vim.fn.getcwd()
        --     end,
        -- })

        -- Pyrefly Configuration
        if not configs.pyrefly then
          configs.pyrefly = {
            default_config = {
              -- Option 1: If pyrefly is on PATH and you don't use/need uv
              cmd = { "pyrefly", "lsp" },
              -- Option 2: If you installed pyrefly via uv or want to run it with uv
              -- cmd = { "uv", "run", "pyrefly", "lsp" },
              filetypes = { "python" },
              root_dir = function(fname)
                -- This root_dir is from the pyrefly lspconfig example
                return lspconfig.util.find_git_ancestor(fname) or vim.loop.os_homedir()
                -- Alternatively, you could use a more Python-specific root_dir like pyright's:
                -- return util.root_pattern(
                --   "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "pyrefly.toml", ".git"
                -- )(fname) or util.find_git_ancestor(fname) or vim.fn.getcwd()
              end,
              settings = {}, -- Add any pyrefly specific settings here if needed
            },
          }
        end

        lspconfig.pyrefly.setup({
            capabilities = capabilities, -- Important: pass your defined capabilities
            -- You can add specific settings here that override or complement the default_config
            -- For example, the on_exit from the standalone example:
            on_exit = function(code, _, _)
                vim.notify("Closing Pyrefly LSP exited with code: " .. code, vim.log.levels.INFO)
            end,
            -- Add any specific on_attach for pyrefly if needed
            -- on_attach = function(client, bufnr)
            --   -- Pyrefly specific on_attach logic
            -- end,
        })
        -- END: Pyrefly Configuration


        -- Rust configuration
        lspconfig.rust_analyzer.setup({
            capabilities = capabilities,
            settings = {
                ["rust-analyzer"] = {
                    cargo = {
                        allFeatures = true,
                        loadOutDirsFromCheck = true,
                        runBuildScripts = true,
                    },
                    diagnostics = {
                        enable = true,
                        experimental = { enable = true },
                        disabled = {"unresolved-proc-macro"},
                    },
                    completion = {
                        addCallArgumentSnippets = true,
                        addCallParenthesis = true,
                        addFunctionSnippets = true,
                        postfix = { enable = true },
                        autoimport = { enable = true },
                        privateEditable = { enable = true },
                    },
                    checkOnSave = true,
                    hover = {
                        actions = {
                            enable = true,
                            debug = true,
                            gotoTypeDef = true,
                            implementations = true,
                            run = true,
                        },
                        documentation = { enable = true, keywords = true },
                    },
                    inlayHints = {
                        bindingModeHints = { enable = true },
                        chainingHints = { enable = true },
                        closingBraceHints = { enable = true, minLines = 25 },
                        closureReturnTypeHints = { enable = "always" },
                        discriminantHints = { enable = "always" },
                        expressionAdjustmentHints = { enable = "always" },
                        lifetimeElisionHints = { enable = "always", useParameterNames = true },
                        parameterHints = { enable = true },
                        typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
                    },
                    procMacro = { enable = true },
                    lens = {
                        enable = true,
                        debug = true,
                        implementations = true,
                        run = true,
                        methodReferences = true,
                        references = true,
                    },
                    imports = {
                        granularity = { group = "module" },
                        prefix = "self",
                        enforce = true,
                    },
                    assist = {
                        emitMustUse = true,
                        expressionFillDefault = "default",
                    },
                },
            },
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
            on_attach = function(client, bufnr)
                if client.server_capabilities.inlayHintProvider then
                    vim.lsp.inlay_hint.enable(true)
                end
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
            cmd = {"zls"},
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
                if client.server_capabilities.documentFormattingProvider then
                    vim.api.nvim_buf_create_user_command(bufnr, "Format",
                        function() vim.lsp.buf.format({ async = true }) end,
                        { desc = "Format current buffer with LSP" }
                    )
                end
                if client.server_capabilities.inlayHintProvider then
                    vim.lsp.inlay_hint.enable(false)
                end
            end,
        })

        vim.api.nvim_create_user_command('InlayHintsToggle', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end, {})

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
        -- Removed bufnr from global keymap as it's not available here
        vim.keymap.set('n', '<leader>ld', vim.diagnostic.setloclist, { noremap = true, silent = true, desc = "LSP Diagnostic setloclist" })


        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover, {
                border = "rounded",
            }
        )

        -- Note: The autocmd for CursorHold should be defined using on_attach for buffer-local behavior
        -- or carefully if kept global. Here, it's global, so bufnr is not available.
        -- It might be better to move this into individual on_attach functions or a general on_attach.
        vim.api.nvim_create_autocmd("CursorHold", {
            -- buffer = bufnr, -- bufnr is not defined in this global scope
            group = vim.api.nvim_create_augroup("LspFloatDiagnostic", { clear = true }), -- Use an augroup
            callback = function()
                local current_buf = vim.api.nvim_get_current_buf()
                if not vim.lsp.buf_is_attached(current_buf) then return end -- Only if LSP is attached

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

        vim.diagnostic.config({
            signs = {
                severity = {
                    min = vim.diagnostic.severity.HINT,
                },
                text = {
                    [vim.diagnostic.severity.ERROR] = "󰅚",
                    [vim.diagnostic.severity.WARN]  = "󰀪",
                    [vim.diagnostic.severity.INFO]  = "I",
                    [vim.diagnostic.severity.HINT]  = "󰌶",
                }
            },
        })
    end,
}
