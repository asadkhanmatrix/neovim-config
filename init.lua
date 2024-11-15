-- init.lua
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- Core Options
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.autochdir = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Basic Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General mappings
map("n", "j", "gj", opts)
map("n", "k", "gk", opts)
map("n", "<Esc>", ":nohlsearch<CR>", opts)
map("n", "<leader>q", "ZZ", opts)
map("n", "<leader>ee", ":Explore<CR>:vertical resize 80<CR>", opts)

-- Open terminal
map("n", "<leader>t", function()
    vim.cmd("vnew | terminal ")
    vim.cmd("vertical resize 80")
end, opts)

-- Line movement
map({ "n", "i" }, "<A-S-k>", function() vim.cmd("move -2") end, opts)
map({ "n", "i" }, "<A-S-j>", function() vim.cmd("move +1") end, opts)

-- Word highlight
map("n", "<leader>z", function()
    local word = vim.fn.escape(vim.fn.expand("<cword>"), "\\")
    vim.fn.setreg("/", "\\V\\<" .. word .. "\\>")
    vim.opt.hlsearch = true
end, opts)

-- Insert mode shortcuts
map("i", "jk", "<Esc>", opts)
map("i", "{<CR>", "{<CR>}<Esc>O", opts)

-- Language Support
local group = vim.api.nvim_create_augroup("LanguageSupport", { clear = true })

-- Python support
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "python",
    callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4

        -- Python execution
        map("n", "<leader>ds", function()
            local file = vim.fn.expand("%:p")
            vim.cmd("write")
            vim.cmd("vnew | terminal time python3 " .. file)
            vim.cmd("vertical resize 80")
        end, opts)
    end,
})

-- C++ support
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "cpp",
    callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2

        local function compile()
            local file = vim.fn.expand("%:p:.")
            local output = vim.fn.expand("%:r")
            local compile_cmd = string.format(
                "vnew | terminal time g++ -std=c++23 -O2 -Wall -Wpedantic -fsanitize=address -fsanitize=undefined %s -o %s",
                file,
                output
            )
            vim.cmd("write")
            vim.cmd(compile_cmd)
            vim.cmd("vertical resize 80")
        end

        local function execute()
            local file = vim.fn.expand("%:p:r")
            vim.cmd("write")
            vim.cmd("vsplit | terminal " .. file)
        end

        map("n", "<leader>bs", compile, opts)
        map("n", "<leader>ds", execute, opts)
    end,
})

-- Rust support for individual files
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "rust",
    callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4

        local function compile()
            local file = vim.fn.expand("%:p")  -- Get full file path
            local output = vim.fn.expand("%:r")  -- Get base file name (without extension)
            local compile_cmd = string.format(
                "vnew | terminal time rustc %s -o %s",
                file,
                output
            )
            vim.cmd("write")  -- Save the file
            vim.cmd(compile_cmd)  -- Run rustc
            vim.cmd("vertical resize 80")  -- Adjust window size
        end

        local function execute()
            local file = vim.fn.expand("%:p:r")  -- Get base file name (without extension)
            vim.cmd("write")  -- Save the file
            vim.cmd("vsplit | terminal " .. file)  -- Run the compiled file
        end

        -- Mapping commands to keys
        map("n", "<leader>bs", compile, opts)  -- Compile with rustc
        map("n", "<leader>ds", execute, opts)  -- Run the compiled file
    end,
})

-- Zig support for individual files
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "zig",
    callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4

        local function compile()
            local file = vim.fn.expand("%:p")  -- Get full file path
            local compile_cmd = string.format(
                "vnew | terminal time zig build-exe %s -O ReleaseSafe",
                file
            )
            vim.cmd("write")  -- Save the file
            vim.cmd(compile_cmd)  -- Compile the file
            vim.cmd("vertical resize 80")  -- Adjust window size
        end

        local function execute()
            local file = vim.fn.expand("%:p:r")  -- Get base file name (without extension)
            vim.cmd("write")  -- Save the file
            vim.cmd("vsplit | terminal " .. file)  -- Run the compiled file
        end

        -- Mapping commands to keys
        map("n", "<leader>bs", compile, opts)  -- Compile with zig
        map("n", "<leader>ds", execute, opts)  -- Run the compiled file
    end,
})

-- Autosave
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = group,
    pattern = "*",
    command = "silent! write",
})

if vim.g.neovide then
    vim.o.guifont = "JetBrainsMono Nerd Font:h11"

    vim.opt.linespace = 0

    vim.g.neovide_scale_factor = 1.0

    --padding
    vim.g.neovide_padding_top = 0
    vim.g.neovide_padding_bottom = 0
    vim.g.neovide_padding_right = 0
    vim.g.neovide_padding_left = 0

    vim.g.neovide_window_blurred = true

    vim.g.neovide_cursor_antialiasing = true
end

-- Load plugin manager and configurations
require("config.lazy")
