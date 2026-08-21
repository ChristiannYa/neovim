return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    opts = {
        ensure_installed = {
            "vim",
            "vimdoc",
            "json",
            "markdown",
            "markdown_inline",
            "html",
            "css",
            "javascript",
            "typescript",
            "c",
            "vue",
            "lua",
            "cpp",
            "rust",
        },
        highlight = {
            enable = true,
        },
    },
    config = function(_, opts)
        local ts = require("nvim-treesitter")
        ts.setup(opts)
        ts.install(opts.ensure_installed)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = opts.ensure_installed,
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })
    end,
}

