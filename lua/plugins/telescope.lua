return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                mappings = {
                    i = {
                        ["<a-j>"] = "move_selection_next",
                        ["<a-k>"] = "move_selection_previous",
                    },
                    n = {
                        ["<a-o>"] = actions.select_horizontal,
                        ["<a-v>"] = actions.select_vertical,
                    },
                },
            },
        })

        telescope.load_extension("fzf")

        local builtin = require("telescope.builtin")

        vim.keymap.set("n", "<leader>ff", builtin.find_files, {
            desc = "find files",
        })

        vim.keymap.set("n", "<leader>fg", function()
            builtin.live_grep({
                additional_args = { "--fixed-strings" },
                path_display = { "tail" },
            })
        end, {
            desc = "search text in project (literal)",
        })

        vim.keymap.set("n", "<leader>fh", function()
            builtin.oldfiles({ only_cwd = true })
        end, {
            desc = "list open files history (cwd)",
        })

        vim.keymap.set("n", "<leader>fb", builtin.buffers, {
            desc = "find open buffers",
        })

        -- vim.keymap.set("n", "<leader>fh", builtin.help_tags, {
        --     desc = "search help docs"
        -- })
    end,
}
