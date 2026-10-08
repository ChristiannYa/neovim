local group = vim.api.nvim_create_augroup("YankWithFilename", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
        local ev = vim.v.event

        -- only real linewise yanks into the default/clipboard registers
        if ev.operator ~= "y" or ev.regtype ~= "V" then return end
        local reg = ev.regname or ""
        if reg ~= "" and reg ~= "+" and reg ~= "*" then return end

        -- skip special buffers (oil, terminals, help, etc.)
        if vim.bo.buftype ~= "" then return end

        local name = vim.fn.expand("%:.") -- path relative to cwd
        if name == "" then return end

        -- narrow string|string[] to string[]
        local lines = ev.regcontents
        if type(lines) == "string" then lines = { lines } end

        -- cheap check first, then a full comparison against the buffer
        if #lines ~= vim.api.nvim_buf_line_count(0) then return end
        local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        if not vim.deep_equal(lines, buf_lines) then return end

        local wrapped = name .. "\n\n" .. table.concat(lines, "\n")

        pcall(vim.fn.setreg, "+", wrapped, "v")
    end,
})
