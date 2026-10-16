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
        local action_state = require("telescope.actions.state")

        local function move_and_refresh(action)
            return function(prompt_bufnr)
                action(prompt_bufnr)
                local picker = action_state.get_current_picker(prompt_bufnr)
                -- force the status text (the "1 / 2" counter) to redraw
                pcall(function()
                    picker:get_status_updater(picker.prompt_win, picker.prompt_bufnr)()
                end)
            end
        end

        telescope.setup({
            defaults = {
                layout_strategy = "flex",
                layout_config = {
                    flex = {
                        flip_columns = 120, -- narrower than this → vertical
                    },
                    horizontal = {
                        width = 0.9,
                        height = 0.95,
                        preview_width = 0.6,
                        preview_cutoff = 1, -- never hide the preview
                    },
                    vertical = {
                        width = 0.9,
                        height = 0.95,
                        preview_height = 0.5,
                        preview_cutoff = 1, -- never hide the preview
                        prompt_position = "bottom",
                    },
                },
                get_status_text = function(self)
                    local total = self.manager and self.manager:num_results() or 0
                    if total == 0 then
                        return ""
                    end

                    local row = self:get_selection_row()
                    local index
                    if self.sorting_strategy == "ascending" then
                        index = row + 1
                    else
                        -- descending: best result sits at the bottom of the window
                        index = self.max_results - row
                    end

                    return string.format("%d / %d", index, total)
                end,
                mappings = {
                    i = {
                        ["<a-j>"] = move_and_refresh(actions.move_selection_next),
                        ["<a-k>"] = move_and_refresh(actions.move_selection_previous),
                        ["<Down>"] = move_and_refresh(actions.move_selection_next),
                        ["<Up>"] = move_and_refresh(actions.move_selection_previous),
                    },
                    n = {
                        ["j"] = move_and_refresh(actions.move_selection_next),
                        ["k"] = move_and_refresh(actions.move_selection_previous),
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
