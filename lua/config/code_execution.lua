-- Language Support Configuration
local group = vim.api.nvim_create_augroup("LanguageSupport", { clear = true })

-- Common configuration for languages
local language_configs = {
    python = {
        spacing = { tabstop = 4, shiftwidth = 4 },
        commands = {
            compile = nil,  -- Python doesn't need compilation
            execute = function(file)
                return string.format("time python3 %s", file)
            end
        }
    },
    c = {
        spacing = { tabstop = 2, shiftwidth = 2 },
        commands = {
            compile = function(file, output)
                return string.format(
                    "time gcc -O2 -Wall -Wpedantic -fsanitize=undefined %s -o %s",
                    file,
                    output
                )
            end,
            execute = function(file)
                return "time " .. file
            end
        }
    },
    cpp = {
        spacing = { tabstop = 2, shiftwidth = 2 },
        commands = {
            compile = function(file, output)
                return string.format(
                    "time g++ -std=c++23 -O2 -Wall -Wpedantic -fsanitize=undefined %s -o %s",
                    file,
                    output
                )
            end,
            execute = function(file)
                return "time " .. file
            end
        }
    },
    rust = {
        spacing = { tabstop = 4, shiftwidth = 4 },
        commands = {
            compile = function(file, output)
                return string.format("time rustc %s -o %s", file, output)
            end,
            execute = function(file)
                return "time " .. file
            end
        }
    },
    zig = {
        spacing = { tabstop = 4, shiftwidth = 4 },
        commands = {
            compile = function(file)
                return string.format("time zig build-exe %s", file)
            end,
            execute = function(file)
                return "time " .. file
            end
        }
    }
}

-- Helper functions
local function setup_window_split()
    vim.cmd("vertical resize 60")
end

local function setup_editor_config(config)
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = config.spacing.tabstop
    vim.opt_local.shiftwidth = config.spacing.shiftwidth
end

local function create_terminal_command(cmd)
    return string.format("botright 15split | terminal %s", cmd)
end

-- Create language setup function
local function setup_language(lang_config)
    return function()
        -- Set up editor configuration
        setup_editor_config(lang_config)

        -- Set up compilation if available
        if lang_config.commands.compile then
            vim.keymap.set("n", "<leader>bs", function()
                local file = vim.fn.expand("%:p")
                local output = vim.fn.expand("%:r")

                vim.cmd("write")
                if vim.lsp.buf.format then
                    vim.lsp.buf.format()
                end

                local compile_cmd = lang_config.commands.compile(file, output)
                vim.cmd(create_terminal_command(compile_cmd))
                setup_window_split()
            end, { noremap = true, silent = true })
        end

        -- Set up execution
        vim.keymap.set("n", "<leader>ds", function()
            local file = vim.fn.expand(lang_config.commands.compile and "%:p:r" or "%:p")

            vim.cmd("write")
            local execute_cmd = lang_config.commands.execute(file)
            vim.cmd(create_terminal_command(execute_cmd))
            setup_window_split()
        end, { noremap = true, silent = true })
    end
end

-- Register autocmds for each language
for lang, config in pairs(language_configs) do
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = lang,
        callback = setup_language(config)
    })
end
