return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("nvim-treesitter-textobjects").setup({
            select = {
                lookahead = true,   -- jump forward to next textobject if cursor isn't inside one
            },
            move = {
                set_jumps = true
            }
        })

        -- Visual + operator-pending mode mappings
        local select = require("nvim-treesitter-textobjects.select")

        vim.keymap.set({ "x", "o" }, "aa", function ()
           select.select_textobject("@parameter.outer", "textobjects")
        end, { desc = "Select outer parameter" })

        vim.keymap.set({ "x", "o" }, "ia", function ()
           select.select_textobject("@parameter.inner", "textobjects")
        end, { desc = "Select inner parameter" })

        vim.keymap.set({ "x", "o" }, "af", function()
            select.select_textobject("@function.outer", "textobjects")
        end, { desc = "Select outer function" })

        vim.keymap.set({ "x", "o" }, "if", function()
            select.select_textobject("@function.inner", "textobjects")
        end, { desc = "Select inner function" })

        vim.keymap.set({ "x", "o" }, "ac", function()
            select.select_textobject("@class.outer", "textobjects")
        end, { desc = "Select outer class" })

        vim.keymap.set({ "x", "o" }, "ic", function()
            select.select_textobject("@class.inner", "textobjects")
        end, { desc = "Select inner class" })

        vim.keymap.set({ "x", "o" }, "ab", function()
            select.select_textobject("@call.outer", "textobjects")
        end, { desc = "Select outer call" })

        vim.keymap.set({ "x", "o" }, "ib", function()
            select.select_textobject("@call.inner", "textobjects")
        end, { desc = "Select inner call" })
    end,
}

