return {
    'numToStr/Comment.nvim',
    config = function()
        local api = require('Comment.api')

        require('Comment').setup({
            toggler = {
                line = 'gcc',
                block = 'gbc',
            },
        })

        -- Custom keymaps for explicit comment and uncomment
        -- Normal mode
        vim.keymap.set('n', '+', function()
            -- Get the current line and check if it's commented
            local line = vim.api.nvim_get_current_line()
            local comment_string = vim.bo.commentstring:gsub('%%s.*', '')
            local is_commented = line:match('^%s*' .. vim.pesc(comment_string))

            if not is_commented then
                api.comment.linewise.current()
            end
        end, { desc = 'Comment line' })

        vim.keymap.set('n', '-', function()
            -- Get the current line and check if it's commented
            local line = vim.api.nvim_get_current_line()
            local comment_string = vim.bo.commentstring:gsub('%%s.*', '')
            local is_commented = line:match('^%s*' .. vim.pesc(comment_string))

            if is_commented then
                api.comment.linewise.current()
            end
        end, { desc = 'Uncomment line' })

        -- Visual mode
        vim.keymap.set('v', '+', function()
            local mode = vim.fn.mode()
            if mode == 'V' then
                api.comment.linewise(vim.fn.line("'<"), vim.fn.line("'>"))
            end
        end, { desc = 'Comment lines' })

        vim.keymap.set('v', '-', function()
            local mode = vim.fn.mode()
            if mode == 'V' then
                api.uncomment.linewise(vim.fn.line("'<"), vim.fn.line("'>"))
            end
        end, { desc = 'Uncomment lines' })
    end,
    lazy = false,
}
