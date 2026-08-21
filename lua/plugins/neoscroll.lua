return {
    "karb94/neoscroll.nvim",
    opts = {
        hide_cursor = false,
    },
    config = function (_, opts)
        local neoscroll = require("neoscroll")
        neoscroll.setup(opts)

        local duration_def = 150
        local keymap = {
            ["<A-k>"] = function () neoscroll.ctrl_u({ duration = duration_def }) end;
            ["<A-j>"] = function () neoscroll.ctrl_d({ duration = duration_def }) end
        }

        local modes = { 'n' }

        for k, f in pairs(keymap) do
            vim.keymap.set(modes, k, f)
        end
    end
}

