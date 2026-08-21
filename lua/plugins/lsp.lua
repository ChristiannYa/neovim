local lang_servers = {
    "cssls",
    "html",
    "jsonls",
    "vtsls", -- vue is already enabled in vtsls.lua
    "lua_ls",
    "tailwindcss"
}

return {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mason-org/mason.nvim",
    },
    opts = {
        ensure_installed = lang_servers,
        automatic_enable = {
            exclude = { "kotlin_lsp" },
        },
    },
    config = function(_, opts)
        require("mason-lspconfig").setup(opts)
        require("lsp").setup(lang_servers)
    end,
}
