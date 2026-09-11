local M = {}

local function strip_tscn(bufnr, threshold)
    threshold = threshold or 300
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local out = {}
    local stripped_count = 0
    for _, line in ipairs(lines) do
        if #line > threshold then
            local prefix = line:match("^(.-%()") or line:sub(1, 50) .. "("
            table.insert(out, prefix .. "<omitted " .. #line .. " chars>)")
            stripped_count = stripped_count + 1
        else
            table.insert(out, line)
        end
    end
    return table.concat(out, "\n"), stripped_count
end

local function copy_stripped_tscn()
    local bufnr = vim.api.nvim_get_current_buf()
    local result, stripped_count = strip_tscn(bufnr)
    vim.fn.setreg("+", result)
    vim.notify(
        string.format("Copied to clipboard (%d long line%s stripped)", stripped_count, stripped_count == 1 and "" or "s"),
        vim.log.levels.INFO
    )
end

function M.setup(bufnr)
    vim.keymap.set("n", "<leader>ts", copy_stripped_tscn, {
        buffer = bufnr,
        desc = "Copy .tscn with long lines stripped",
    })
    vim.api.nvim_buf_create_user_command(bufnr, "TscnCopyStripped", copy_stripped_tscn, {})
end

return M
