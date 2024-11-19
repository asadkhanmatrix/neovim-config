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
map("n", "<leader>ee", ":Explore<CR>", opts)

-- Open terminal
map("n", "<leader>t", function()
    vim.cmd("vnew | terminal ")
    vim.cmd("vertical resize 60")
end, opts)

-- Line movement
map("n", "<A-S-k>", function() vim.cmd("move -2") end, opts)
map("n", "<A-S-j>", function() vim.cmd("move +1") end, opts)

-- Line insertion
map("i", "<A-S-k>", "<esc>O", opts)
map("i", "<A-S-j>", "<esc>o", opts)

-- Word highlight
map("n", "<leader>z", function()
    local word = vim.fn.escape(vim.fn.expand("<cword>"), "\\")
    vim.fn.setreg("/", "\\V\\<" .. word .. "\\>")
    vim.opt.hlsearch = true
end, opts)

-- Insert mode shortcuts
map("i", "jk", "<Esc>", opts)
map("i", "{<CR>", "{<CR>}<Esc>O", opts)

-- Autosave
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = group,
    pattern = "*",
    command = "silent! write",
})

if vim.g.neovide then
    vim.o.guifont = "JetBrainsMono Nerd Font:h12"

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

-- Diagnostic related
map("n", "<leader>dn", function() vim.diagnostic.goto_next() end, {  noremap = true, silent = true, desc = "Goto next diagnostic" })
map("n", "<leader>dp", function() vim.diagnostic.goto_prev() end, {  noremap = true, silent = true, desc = "Goto prev diagnostic" })

-- Load plugin manager and configurations
require("config.code_execution")
require("config.lazy")
