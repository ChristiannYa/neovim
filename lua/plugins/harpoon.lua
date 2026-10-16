return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup({
            settings = {
                save_on_toggle = true
            }
        })

        local conf = require("telescope.config").values
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local themes = require("telescope.themes")

        local MAIN = "main"
        local STATE_FILE = vim.fn.stdpath("data") .. "/harpoon_groups.json"

        local function notify(msg, level)
            vim.notify("Harpoon: " .. msg, level or vim.log.levels.INFO)
        end

        ---------------------------------------------------------------------
        -- Persistence: { [cwd] = { "group1", "group2", ... } }
        -- Cached in memory; the cache is dropped before every write so we
        -- merge with whatever another nvim instance may have saved.
        ---------------------------------------------------------------------
        local cache = nil

        local function load()
            if cache then return cache end
            cache = {}
            local f = io.open(STATE_FILE, "r")
            if f then
                local ok, data = pcall(vim.json.decode, f:read("*a"))
                f:close()
                if ok and type(data) == "table" then cache = data end
            end
            return cache
        end


        -------------------------------------------
        -- Groups for the current working directory
        -------------------------------------------
        local groups = {}

        function groups.custom()
            return vim.list_slice(load()[vim.uv.cwd()] or {}) -- copy; callers may mutate
        end

        function groups.all()
            return vim.list_extend({ MAIN }, groups.custom())
        end

        function groups.has(name)
            return vim.tbl_contains(groups.all(), name)
        end

        local function set_custom(names)
            cache = nil -- re-read from disk so we don't clobber other instances
            local data = load()
            data[vim.uv.cwd()] = names

            -- Write to a temp file, then rename, so a crash can't truncate the state
            local tmp = STATE_FILE .. ".tmp"
            local f = io.open(tmp, "w")
            if not f then
                notify("could not write " .. tmp, vim.log.levels.WARN)
                return
            end
            f:write(vim.json.encode(data))
            f:close()
            local ok, err = vim.uv.fs_rename(tmp, STATE_FILE)
            if not ok then notify("could not save groups: " .. tostring(err), vim.log.levels.WARN) end
        end

        function groups.add(name)
            local names = groups.custom()
            table.insert(names, name)
            set_custom(names)
        end

        function groups.remove(name)
            set_custom(vim.tbl_filter(function(n) return n ~= name end, groups.custom()))
        end

        function groups.rename(old, new)
            set_custom(vim.tbl_map(function(n) return n == old and new or n end, groups.custom()))
        end

        ----------------
        -- Current group
        ----------------
        local current = MAIN

        local function list()
            if not groups.has(current) then current = MAIN end
            return harpoon:list(current)
        end

        local function title()
            return "Harpoon (" .. current .. ")"
        end

        -- Groups belong to a directory, so start over when it changes
        vim.api.nvim_create_autocmd("DirChanged", {
            callback = function() current = MAIN end,
        })

        ----------------
        -- Input helpers
        ----------------
        -- Trim raw input; return nil (and warn if relevant) when unusable
        local function valid_new_name(raw)
            local name = raw and vim.trim(raw)
            if not name or name == "" then return nil end
            if groups.has(name) then
                notify("group '" .. name .. "' already exists", vim.log.levels.WARN)
                return nil
            end
            return name
        end

        -- Pick one of the custom groups, or tell the user there are none
        local function select_custom(prompt, empty_msg, on_choice)
            local names = groups.custom()
            if #names == 0 then
                notify(empty_msg)
                return
            end
            vim.ui.select(names, { prompt = prompt }, function(choice)
                if choice then on_choice(choice) end
            end)
        end

        local function open_telescope()
            local h_list = list()

            local function make_finder()
                local entries = {}
                for i = 1, h_list:length() do
                    local item = h_list.items[i]
                    if item then table.insert(entries, { value = item.value, idx = i }) end
                end
                return finders.new_table({
                    results = entries,
                    entry_maker = function(e)
                        return {
                            value = e.value,
                            display = e.value,
                            ordinal = e.value,
                            path = e.value,
                            filename = e.value,
                            idx = e.idx, -- harpoon's real slot
                        }
                    end,
                })
            end

            pickers.new({}, {
                prompt_title = title(),
                finder = make_finder(),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                    -- Remove the highlighted file from the current group
                    map({ "i", "n" }, "<C-d>", function()
                        local picker = action_state.get_current_picker(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        if not selection then return end
                        h_list:remove_at(selection.idx)
                        picker:refresh(make_finder(), { reset_prompt = false })
                    end)
                    return true
                end,
            }):find()
        end

        vim.keymap.set("n", "<leader>ha", function()
                if vim.bo.filetype == "oil" then
                    notify("can't add an oil buffer", vim.log.levels.WARN)
                    return
                end
                if vim.api.nvim_buf_get_name(0) == "" then
                    notify("can't add an unnamed buffer", vim.log.levels.WARN)
                    return
                end

                local h_list = list() -- list() first so `current` is validated
                local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
                if h_list:get_by_value(file) then
                    notify(file .. " is already in " .. current)
                    return
                end
                h_list:add()
                notify("added " .. file .. " to " .. current)
            end,
            { desc = "Harpoon: add file" }
        )

        vim.keymap.set("n", "<leader>hh", open_telescope, {
            desc = "Harpoon: current group (telescope)" }
        )

        -- Harpoon's own menu: use this to reorder/edit entries
        vim.keymap.set("n", "<leader>hm", function()
            harpoon.ui:toggle_quick_menu(list(), { title = title() })
        end, { desc = "Harpoon: current group (quick menu)" })

        vim.keymap.set("n", "<leader>hg", function()
            local names = groups.all()
            -- Start with the current group highlighted (index() is 0-based, -1 if absent)
            local default_index = math.max(1, vim.fn.index(names, current) + 1)

            pickers.new(themes.get_dropdown({ previewer = false }), {
                prompt_title = "Harpoon groups",
                finder = finders.new_table({ results = names }),
                sorter = conf.generic_sorter({}),
                default_selection_index = default_index,
                attach_mappings = function(prompt_bufnr)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        if selection then
                            current = selection[1]
                            open_telescope()
                        end
                    end)
                    return true
                end,
            }):find()
        end, { desc = "Harpoon: switch group" })

        vim.keymap.set("n", "<leader>hn", function()
            vim.ui.input({ prompt = "New group name: " }, function(raw)
                local name = valid_new_name(raw)
                if not name then return end
                groups.add(name)
                current = name
                notify("switched to new group '" .. name .. "'")
            end)
        end, { desc = "Harpoon: new group" })

        vim.keymap.set("n", "<leader>hr", function()
            select_custom("Rename which group?", "no custom groups to rename", function(old)
                vim.ui.input({ prompt = "New name: ", default = old }, function(raw)
                    if raw and vim.trim(raw) == old then return end -- unchanged
                    local new = valid_new_name(raw)
                    if not new then return end

                    local old_list, new_list = harpoon:list(old), harpoon:list(new)
                    for i = 1, old_list:length() do
                        local item = old_list.items[i]
                        if item then new_list:add(item) end
                    end
                    old_list:clear()

                    groups.rename(old, new)
                    if current == old then current = new end
                end)
            end)
        end, { desc = "Harpoon: rename group" })

        vim.keymap.set("n", "<leader>hd", function()
            select_custom("Delete which group?", "no custom groups to delete", function(name)
                vim.ui.select({ "No", "Yes" }, {
                    prompt = "Delete '" .. name .. "' and its files?",
                }, function(answer)
                    if answer ~= "Yes" then return end
                    harpoon:list(name):clear()
                    groups.remove(name)
                    if current == name then current = MAIN end
                end)
            end)
        end, { desc = "Harpoon: delete group" })


        vim.keymap.set("n", "<leader>h1", function()
            list():select(1)
        end, { desc = "Harpoon: file 1" })

        vim.keymap.set("n", "<leader>h2", function()
            list():select(2)
        end, { desc = "Harpoon: file 2" })

        vim.keymap.set("n", "<leader>h3", function()
            list():select(3)
        end, { desc = "Harpoon: file 3" })

        vim.keymap.set("n", "<leader>h4", function()
            list():select(4)
        end, { desc = "Harpoon: file 4" })

        vim.keymap.set("n", "<leader>h5", function()
            list():select(5)
        end, { desc = "Harpoon: file 5" })
    end,
}
