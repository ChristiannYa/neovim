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
}
