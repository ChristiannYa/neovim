require("bootstrap")
require("options")
require("keymaps")
require("diagnostics")

vim.filetype.add({ extension = { tscn = "tscn" } })
vim.api.nvim_create_autocmd("FileType", {
    pattern = "tscn",
    callback = function()
        require("godot.tscn").setup(vim.api.nvim_get_current_buf())
    end,
})

require("lazy").setup({
    { import = "plugins" },
    { import = "plugins.colorscheme" },
})

require("colorscheme")
