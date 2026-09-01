local function find_scene_file(gd_path)
    local dir = vim.fn.fnamemodify(gd_path, ":h")
    local scenes = vim.fn.glob(dir .. "/*.tscn", false, true)
    return scenes[1]
end

local function get_signal_methods(tscn_path)
    local methods = {}
    if not tscn_path or vim.fn.filereadable(tscn_path) == 0 then
        return methods
    end
    for line in io.lines(tscn_path) do
        local method = line:match('method="([%w_]+)"')
        if method then
            methods[method] = true
        end
    end
    return methods
end

local signal_lines_by_buf = {}

local function place_signal_signs(bufnr)
    local gd_path = vim.api.nvim_buf_get_name(bufnr)
    local methods = get_signal_methods(find_scene_file(gd_path))
    local lines = {}
    if not vim.tbl_isempty(methods) then
        for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
            local fname = line:match("^func%s+([%w_]+)%s*%(")
            if fname and methods[fname] then
                lines[i] = true
            end
        end
    end
    signal_lines_by_buf[bufnr] = lines
end

_G.godot_signal_icon = function()
    local icon = require("kind_icons").Event
    local blank = (" "):rep(vim.fn.strdisplaywidth(icon))
    local lines = signal_lines_by_buf[vim.api.nvim_get_current_buf()]
    if lines and lines[vim.v.lnum] then
        return icon
    end
    return blank
end

return {
    "neovim/nvim-lspconfig",
    ft = "gdscript",
    init = function()
        vim.filetype.add({ extension = { gd = "gdscript" } })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
            pattern = "*.gd",
            callback = function(args)
                place_signal_signs(args.buf)
            end,
        })

        vim.api.nvim_create_autocmd("BufDelete", {
            pattern = "*.gd",
            callback = function(args)
                signal_lines_by_buf[args.buf] = nil
            end,
        })
    end,
    config = function()
        require("lsp").setup({ "gdscript" })
    end,
}
