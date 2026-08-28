vim.api.nvim_create_autocmd("FileType", {
    pattern = { "netrw", "oil" },
    callback = function()
        vim.keymap.set("n", "<leader>k", "<CR>", {
            buffer = true,
            remap = true,
            desc = "Select file/dir under selection",
        })
        vim.keymap.set("n", "<leader>j", "-", {
            buffer = true,
            remap = true,
            desc = "Go up one directory",
        })
    end,
})
vim.keymap.set("n", "<leader>j", ":Ex<CR>", {
    desc = "Go back to file explorer",
})
vim.keymap.set("n", "<leader>j", ":Oil<CR>", {
    desc = "Go back to file explorer",
})

vim.keymap.set("n", "<leader>r", ":restart!<CR>", {
    desc = "Restart neovim",
})
vim.keymap.set("n", "<leader>qq", ":q<CR>", {
    desc = "Exit neovim",
})
vim.keymap.set("n", "<leader>qf", ":q!<CR>", {
    desc = "Force exit neovim",
})

vim.keymap.set("n", "<leader>w", ":w<CR>", {
    desc = "Save file",
})
vim.keymap.set("n", "<leader>spo", ":split<CR>", {
    desc = "Split file: horizontal",
})
vim.keymap.set("n", "<leader>spv", ":vsplit<CR>", {
    desc = "Split file: vertical",
})

vim.keymap.set("n", "<leader>bj", ":bprevious<CR>", {
    desc = "Go to previous buffer",
})
vim.keymap.set("n", "<leader>bk", ":bnext<CR>", {
    desc = "Go to next buffer",
})

vim.keymap.set("n", "<A-=>", "<C-w>5+", {
    desc = "Increase window height",
})
vim.keymap.set("n", "<A-->", "<C-w>5-", {
    desc = "Decrease window height",
})
vim.keymap.set("n", "<A-.>", "<C-w>5>", {
    desc = "Increase window width",
})
vim.keymap.set("n", "<A-,>", "<C-w>5<", {
    desc = "Decrease window width",
})

vim.keymap.set("n", "gdd", function()
    vim.lsp.buf.definition()
end, { desc = "Go to definition (default)" })
vim.keymap.set("n", "gdo", function()
    vim.cmd("split")
    vim.lsp.buf.definition()
end, { desc = "Go to definition (horizontal)" })
vim.keymap.set("n", "gdv", function()
    vim.cmd("vsplit")
    vim.lsp.buf.definition()
end, { desc = "Go to definition (vertical)" })
vim.keymap.set("n", "gdr", function()
    vim.lsp.buf.references()
end, { desc = "Go to definition references" })

vim.keymap.set("n", "ca", vim.lsp.buf.code_action, {
	desc = "Code action",
})

vim.keymap.set("n", "<leader>dr", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true, desc = "Rename definition" })
vim.keymap.set("n", "<leader>srr", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], {
    desc = "Rename string under cursor",
})
vim.keymap.set("n", "<leader>src", "*``cgn", {
    desc = "Change (rename) next occurrence of word under cursor (dot-repeatable)",
})
vim.keymap.set("x", "<leader>src", [["sy/\V<C-r>=escape(@s, '/\')<CR><CR>Ncgn]], {
    desc = "Change (rename) next occurrence of visual selection (dot-repeatable)",
})

vim.keymap.set("i", "ii", "<Esc>", {
    desc = "Exit insert mode",
})
vim.keymap.set("t", "ii", "<C-\\><C-n>", {
    desc = "Exit terminal mode to normal mode",
})

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", {
    desc = "Translate selection down",
})
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", {
    desc = "Translate selection up",
})

vim.keymap.set("v", "x", '"_d', {
    desc = "Delete without yank",
})

vim.keymap.set("v", "<", "<gv", { silent = true })
vim.keymap.set("v", ">", ">gv", { silent = true })

vim.keymap.set({ "x", "o" }, "il", ":<C-u>normal! ^vg_<CR>", {
    desc = "Inner line (no leading/trailing whitespace)",
    silent = true,
})
