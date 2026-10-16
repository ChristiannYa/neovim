return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup({ settings = { save_on_toggle = true } })

        local conf = require("telescope.config").values

        local MAIN = "main"
        local current = MAIN
        local state_file = vim.fn.stdpath("data") .. "/harpoon_groups.json"

        local function read_all()
            local f = io.open(state_file, "r")
            if not f then return {} end
            local ok, data = pcall(vim.json.decode, f:read("*a"))
            f:close()
            return (ok and type(data) == "table") and data or {}
        end

        local function save_custom(names)
            local all = read_all()
            all[vim.uv.cwd()] = names
            local f = io.open(state_file, "w")
            if f then
                f:write(vim.json.encode(all))
                f:close()
            end
        end

        local function custom_groups() return read_all()[vim.uv.cwd()] or {} end
        local function all_groups() return vim.list_extend({ MAIN }, custom_groups()) end

        local function list()
            if not vim.tbl_contains(all_groups(), current) then current = MAIN end
            return harpoon:list(current)
        end

        local title = "Harpoon (" .. current .. ") "

        local function open_telescope()
            local h_list = list()

            local function make_finder()
                local paths = {}
                for _, item in ipairs(h_list.items) do
                    table.insert(paths, item.value)
                end
                return require("telescope.finders").new_table({ results = paths })
            end

            require("telescope.pickers").new({}, {
                prompt_title = title,
                finder = make_finder(),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                    -- Remove the highlighted file from the current group
                    map({ "i", "n" }, "<C-d>", function()
                        local state = require("telescope.actions.state")
                        local picker = state.get_current_picker(prompt_bufnr)
                        local selection = state.get_selected_entry()
                        if not selection then return end
                        h_list:remove_at(selection.index)
                        picker:refresh(make_finder(), { reset_prompt = false })
                    end)
                    return true
                end,
            }):find()
        end

        vim.keymap.set("n", "<leader>ha", function()
            if vim.bo.filetype == "oil" then
                vim.notify("Harpoon: can't add an oil buffer", vim.log.levels.WARN)
                return
            end
            list():add()
        end, { desc = "Harpoon: add file" })

        -- Telescope picker for the current group
        vim.keymap.set("n", "<leader>hh", open_telescope,
            { desc = "Harpoon: current group (telescope)" })

        -- Harpoon's own menu: use this to reorder/edit entries
        vim.keymap.set("n", "<leader>hm", function()
            harpoon.ui:toggle_quick_menu(list(), { title = title })
        end, { desc = "Harpoon: current group (quick menu)" })

        -- Switch group
        vim.keymap.set("n", "<leader>hg", function()
            vim.ui.select(all_groups(), { prompt = "Harpoon group" }, function(choice)
                if choice then
                    current = choice
                    open_telescope()
                end
            end)
        end, { desc = "Harpoon: switch group" })

        -- New group
        vim.keymap.set("n", "<leader>hn", function()
            vim.ui.input({ prompt = "New group name: " }, function(name)
                name = name and vim.trim(name)
                if not name or name == "" then return end
                if vim.tbl_contains(all_groups(), name) then
                    vim.notify("Harpoon: group '" .. name .. "' already exists", vim.log.levels.WARN)
                    return
                end
                local names = custom_groups()
                table.insert(names, name)
                save_custom(names)
                current = name
            end)
        end, { desc = "Harpoon: new group" })

        -- Rename group (moves its files over)
        vim.keymap.set("n", "<leader>hr", function()
            local names = custom_groups()
            if #names == 0 then
                vim.notify("Harpoon: no custom groups to rename", vim.log.levels.INFO)
                return
            end
            vim.ui.select(names, { prompt = "Rename which group?" }, function(old_name)
                if not old_name then return end
                vim.ui.input({ prompt = "New name: ", default = old_name }, function(new_name)
                    new_name = new_name and vim.trim(new_name)
                    if not new_name or new_name == "" or new_name == old_name then return end
                    if vim.tbl_contains(all_groups(), new_name) then
                        vim.notify("Harpoon: group '" .. new_name .. "' already exists", vim.log.levels.WARN)
                        return
                    end
                    local old_list, new_list = harpoon:list(old_name), harpoon:list(new_name)
                    for _, item in ipairs(old_list.items) do new_list:add(item) end
                    old_list:clear()
                    for i, n in ipairs(names) do
                        if n == old_name then names[i] = new_name end
                    end
                    save_custom(names)
                    if current == old_name then current = new_name end
                end)
            end)
        end, { desc = "Harpoon: rename group" })

        -- Delete group (and clear its files)
        vim.keymap.set("n", "<leader>hd", function()
            local names = custom_groups()
            if #names == 0 then
                vim.notify("Harpoon: no custom groups to delete", vim.log.levels.INFO)
                return
            end
            vim.ui.select(names, { prompt = "Delete which group?" }, function(name)
                if not name then return end
                vim.ui.select({ "No", "Yes" }, { prompt = "Delete '" .. name .. "' and its files?" }, function(ok)
                    if ok ~= "Yes" then return end
                    harpoon:list(name):clear()
                    save_custom(vim.tbl_filter(function(n) return n ~= name end, names))
                    if current == name then current = MAIN end
                end)
            end)
        end, { desc = "Harpoon: delete group" })

        for i = 1, 5 do
            vim.keymap.set("n", "<leader>h" .. i, function() list():select(i) end,
                { desc = "Harpoon: file " .. i })
        end
    end,
}
