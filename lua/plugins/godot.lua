local function find_scene_file(gd_path)
    local dir = vim.fn.fnamemodify(gd_path, ":h")
    local scenes = vim.fn.glob(dir .. "/*.tscn", false, true)
    return scenes[1]
end

local function get_signal_connections(tscn_path)
    local connections = {}
    if not tscn_path or vim.fn.filereadable(tscn_path) == 0 then
        return connections
    end
    for line in io.lines(tscn_path) do
        if line:match("^%[connection ") then
            local method = line:match('method="([^"]+)"')
            if method then
                connections[method] = {
                    signal = line:match('signal="([^"]+)"'),
                    from = line:match('from="([^"]+)"'),
                    to = line:match('to="([^"]+)"'),
                }
            end
        end
    end
    return connections
end

local signal_data_by_buf = {}

local function place_signal_signs(bufnr)
    local gd_path = vim.api.nvim_buf_get_name(bufnr)
    local connections = get_signal_connections(find_scene_file(gd_path))
    local lines = {}
    if not vim.tbl_isempty(connections) then
        for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
            local fname = line:match("^func%s+([%w_]+)%s*%(")
            if fname and connections[fname] then
                lines[i] = fname -- store the method name, not just true
            end
        end
    end
    signal_data_by_buf[bufnr] = { lines = lines, connections = connections }
end

_G.godot_has_signals = function()
    local data = signal_data_by_buf[vim.api.nvim_get_current_buf()]
    return data ~= nil and next(data.lines) ~= nil
end

_G.godot_signal_icon = function()
    local icon = vim.trim(require("kind_icons").Signal)
    local data = signal_data_by_buf[vim.api.nvim_get_current_buf()]
    if data and data.lines[vim.v.lnum] then
        return icon
    end
    return " "
end

local function show_signal_info()
    local bufnr = vim.api.nvim_get_current_buf()
    local data = signal_data_by_buf[bufnr]
    if not data then
        return
    end
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local method = data.lines[lnum]
    if not method then
        vim.notify("Not on a signal handler line", vim.log.levels.INFO)
        return
    end
    local info = data.connections[method]
    vim.lsp.util.open_floating_preview({
        "Signal: " .. (info.signal or "?"),
        "From:   " .. (info.from or "?"),
        "To:     " .. (info.to or "?"),
        "Method: " .. method,
    }, "", { border = "rounded", focusable = false })
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
                signal_data_by_buf[args.buf] = nil
            end,
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "gdscript",
            callback = function(args)
                vim.keymap.set("n", "<leader>gds", show_signal_info, {
                    buffer = args.buf,
                    desc = "Show Godot signal connection info",
                })
            end,
        })

        vim.api.nvim_create_user_command("GodotSignalInfo", show_signal_info, {})
    end,
    config = function()
        require("lsp").setup({ "gdscript" })
    end,
}
