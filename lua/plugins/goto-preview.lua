return {
    "rmagatti/goto-preview",
    dependencies = { "rmagatti/logger.nvim" },
    event = "BufEnter",
    opts = {
        references = {
            provider = "telescope",
            telescope = { hide_preview = false },
        },
    },
    keys = {
        {
            "gpd",
            function()
                require("goto-preview").goto_preview_definition()
            end,
            desc = "Preview definition"
        },
        {
            "gpt",
            function()
                require("goto-preview").goto_preview_type_definition()
            end,
            desc = "Preview type definition"
        },
        {
            "gpi",
            function()
                require("goto-preview").goto_preview_implementation()
            end,
            desc = "Preview implementation"
        },
        {
            "gpr",
            function()
                require("goto-preview").goto_preview_references()
            end,
            desc = "Preview references"
        },
        {
            "gpq",
            function()
                require("goto-preview").close_all_win()
            end,
            desc = "Close all previews"
        },
    },
}
