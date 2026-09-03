local function find_project_root(start_path)
    local dir = vim.fn.fnamemodify(start_path, ":h")
    while dir ~= "/" and dir ~= "" do
        if vim.fn.filereadable(dir .. "/project.godot") == 1 then
            return dir
        end
        dir = vim.fn.fnamemodify(dir, ":h")
    end
    return nil
end

local function find_scenes_referencing(gd_path, project_root)
    if vim.fn.executable("rg") == 0 then
        return {}
    end
    local rel = gd_path:sub(#project_root + 2)
    local res_path = "res://" .. rel

    local cmd = {
        "rg", "--files-with-matches", "--fixed-strings",
        'path="' .. res_path .. '"',
        project_root,
        "--glob", "*.tscn",
    }
    local ok, result = pcall(vim.fn.systemlist, cmd)
    if not ok or vim.v.shell_error ~= 0 then
        return {}
    end
    return result
end

local function find_scene_file(gd_path)
    local dir = vim.fn.fnamemodify(gd_path, ":h")
    local scenes = vim.fn.glob(dir .. "/*.tscn", false, true)
    return scenes[1]
end

local function get_signal_connections(scene_paths)
    local connections = {}
    for _, tscn_path in ipairs(scene_paths) do
        if vim.fn.filereadable(tscn_path) == 1 then
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
        end
    end
    return connections
end

local function get_declared_signals(buf_lines)
    local declared = {}
    for _, line in ipairs(buf_lines) do
        local sname = line:match("^signal%s+([%w_]+)")
        if sname then
            declared[sname] = true
        end
    end
    return declared
end

local signal_data_by_buf = {}
local hl_ns = vim.api.nvim_create_namespace("godot_signal_hl")

local function place_signal_signs(bufnr)
    local gd_path = vim.api.nvim_buf_get_name(bufnr)
    local project_root = find_project_root(gd_path)
    local connections = {}
    if project_root then
        connections = get_signal_connections(find_scenes_referencing(gd_path, project_root))
    end

    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local declared_signals = get_declared_signals(buf_lines)
    local lines = {}

    vim.api.nvim_buf_clear_namespace(bufnr, hl_ns, 0, -1)

    -- names to paint everywhere they appear: connected handler methods + declared signals
    local highlight_names = {}
    for method in pairs(connections) do
        highlight_names[method] = true
    end
    for sname in pairs(declared_signals) do
        highlight_names[sname] = true
    end

    if not vim.tbl_isempty(highlight_names) then
        for i, line in ipairs(buf_lines) do
            local fname = line:match("^func%s+([%w_]+)%s*%(")
            if fname and connections[fname] then
                lines[i] = fname -- gutter icon still only cares about handler methods
            end

            for name in pairs(highlight_names) do
                local pattern = "%f[%w_]" .. name .. "%f[%W]"
                local search_start = 1
                while true do
                    local s, e = line:find(pattern, search_start)
                    if not s then
                        break
                    end
                    vim.api.nvim_buf_set_extmark(bufnr, hl_ns, i - 1, s - 1, {
                        end_col = e,
                        hl_group = "GodotSignalName",
                    })
                    search_start = e + 1
                end
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

_G.godot_is_signal_handler = function(label)
    local data = signal_data_by_buf[vim.api.nvim_get_current_buf()]
    return data ~= nil and data.connections[label] ~= nil
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
