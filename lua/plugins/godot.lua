return {
    "neovim/nvim-lspconfig",
    ft = "gdscript",
    init = function()
        vim.filetype.add({ extension = { gd = "gdscript" } })
    end,
    config = function()
        require("lsp").setup({ "gdscript" })
    end,
}
