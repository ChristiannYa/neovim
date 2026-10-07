local group = vim.api.nvim_create_augroup("YankWithFilename", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
        local ev = vim.v.event

        -- only real yanks, into the default/clipboard registers
        if ev.operator ~= "y" then return end
        local reg = ev.regname or ""
        if reg ~= "" and reg ~= "+" and reg ~= "*" then return end

        -- skip special buffers (oil, terminals, help, etc.)
        if vim.bo.buftype ~= "" then return end

        local name = vim.fn.expand("%:.") -- path relative to cwd
        if name == "" then return end

        -- narrow string|string[] to string[]
        local lines = ev.regcontents
        if type(lines) == "string" then lines = { lines } end

        local wrapped = name .. "\n\n" .. table.concat(lines, "\n")

        -- pcall so a missing clipboard provider doesn't throw errors
        pcall(vim.fn.setreg, "+", wrapped, "v")
    end,
})
