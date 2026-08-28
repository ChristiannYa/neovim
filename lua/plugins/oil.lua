return {
    "stevearc/oil.nvim",
    config = function()
        local constants = require("oil.constants")
        local FIELD_NAME = constants.FIELD_NAME
        local FIELD_TYPE = constants.FIELD_TYPE

        local devicons = require("nvim-web-devicons")
        local def = "󰉋 "

        local dir_icon_overrides = {
            src = { icon = def, hl = "OilDir" },
            bin = { icon = def, hl = "OilDir" },
            util = { icon = def, hl = "OilDir" },
            [".git"] = { icon = def, hl = "OilDir" },
        }

        require("oil.columns").register("icon", {
            render = function(entry, conf)
                local name = entry[FIELD_NAME]
                local ftype = entry[FIELD_TYPE]

                if ftype == "directory" then
                    local override = dir_icon_overrides[name]
                    if override then
                        return { override.icon, override.hl }
                    end
                    return { "󰉋 ", "OilDir" }
                end

                local icon, hl = devicons.get_icon(name, nil, { default = true })
                return { icon .. " ", hl }
            end,
            parse = function(line, conf)
                return line:match("^(%S+)%s+(.*)$")
            end,
        })

        require("oil").setup({
            columns = { "icon" },
        })
    end,
    dependencies = {
        {
            "nvim-tree/nvim-web-devicons",
            opts = {
                override_by_extension = {
                    ["gd"] = {
                        icon = "",
                        color = "#3984bf",
                        name = "Gdscript"
                    }
                },
            },
        },
    },
    lazy = false,
}
