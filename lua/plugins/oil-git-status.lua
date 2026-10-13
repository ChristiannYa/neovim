return {
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    opts = {
        show_ignored = true,
        symbols = {
            index = {
                [" "] = "·"
            },
            working_tree = {
                [" "] = "·"
            },
        },
    },
    config = function(_, opts)
        require("oil-git-status").setup(opts)

        local function refresh_oil_git()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf):find("^oil:") then
                    -- only refresh buffers whose directory is inside a git repo
                    local dir = require("oil").get_current_dir(buf)
                    if dir and vim.fs.root(dir, ".git") then
                        require("oil-git-status").refresh_buffer(buf)
                    end
                end
            end
        end

        vim.api.nvim_create_autocmd({ "FocusGained", "ShellCmdPost", "BufEnter" }, {
            callback = refresh_oil_git,
        })

        -- fired from other files (e.g. toggleterm) when git may have changed
        vim.api.nvim_create_autocmd("User", {
            pattern = "RefreshOilGit",
            callback = refresh_oil_git,
        })

        vim.keymap.set("n", "<leader>gR", refresh_oil_git, { desc = "Refresh oil git status" })
    end,
}
