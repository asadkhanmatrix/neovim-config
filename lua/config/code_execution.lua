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
        },
        project = {
            detect = function() return false end, -- Default no project detection for Python
        }
    },
    c = {
        spacing = { tabstop = 4, shiftwidth = 4 },
        commands = {
            compile = function(file, output)
                return string.format(
                    "time gcc -O2 -Wall -Wpedantic %s -o %s",
                    file,
                    output
                )
            end,
            execute = function(file)
                return "time " .. file
            end
        },
        project = {
            detect = function() return false end, -- Default no project detection
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
        },
        project = {
            detect = function() return false end, -- Default no project detection
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
        },
        project = {
            detect = function() 
                -- Check for Cargo.toml in the current or parent directories
                local cargo_file = vim.fn.findfile("Cargo.toml", ".;")
                return cargo_file ~= ""
            end,
            build = function()
                return "time cargo build"
            end,
            run = function()
                return "time cargo run"
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
        },
        project = {
            detect = function()
                -- Check for build.zig in the current or parent directories
                local build_file = vim.fn.findfile("build.zig", ".;")
                return build_file ~= ""
            end,
            build = function()
                return "time zig build"
            end,
            run = function()
                return "time zig build run"
            end
        }
    }
}

-- Helper functions
local function setup_editor_config(config)
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = config.spacing.tabstop
    vim.opt_local.shiftwidth = config.spacing.shiftwidth
end

local function create_terminal_command(cmd)
    return string.format("botright 20split | terminal %s", cmd)
end

-- Get the project root directory
local function get_project_root()
    -- Get the directory of the current file
    local current_dir = vim.fn.expand("%:p:h")
    return current_dir
end

-- Create language setup function
local function setup_language(lang_config)
    return function()
        -- Set up editor configuration
        setup_editor_config(lang_config)

        -- Check if we're in a project
        local is_project = lang_config.project and lang_config.project.detect()

        -- Set up compilation/build
        vim.keymap.set("n", "<leader>bs", function()
            vim.cmd("write")
            
            if vim.lsp.buf.format then
                vim.lsp.buf.format()
            end
            
            local compile_cmd
            if is_project and lang_config.project.build then
                -- Use project build command
                compile_cmd = lang_config.project.build()
            elseif lang_config.commands.compile then
                -- Use individual file compilation
                local file = vim.fn.expand("%:p")
                local output = vim.fn.expand("%:r")
                compile_cmd = lang_config.commands.compile(file, output)
            else
                vim.notify("No compilation/build command available", vim.log.levels.WARN)
                return
            end
            
            vim.cmd(create_terminal_command(compile_cmd))
        end, { noremap = true, silent = true })

        -- Set up execution/run
        vim.keymap.set("n", "<leader>ds", function()
            vim.cmd("write")
            
            local execute_cmd
            if is_project and lang_config.project.run then
                -- Use project run command
                execute_cmd = lang_config.project.run()
            else
                -- Use individual file execution
                local file = vim.fn.expand(lang_config.commands.compile and "%:p:r" or "%:p")
                execute_cmd = lang_config.commands.execute(file)
            end
            
            vim.cmd(create_terminal_command(execute_cmd))
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
