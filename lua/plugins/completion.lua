local kind_icons = require("kind_icons")

local rust_builtin_types = {
    bool = true,
    char = true,
    str = true,
    i8 = true,
    i16 = true,
    i32 = true,
    i64 = true,
    i128 = true,
    isize = true,
    u8 = true,
    u16 = true,
    u32 = true,
    u64 = true,
    u128 = true,
    usize = true,
    f16 = true,
    f32 = true,
    f64 = true,
    f128 = true,
}

local rust_override_variants = {
    ["Self"] = true,
    ["self"] = true,
    ["&self"] = true,
    ["mut self"] = true,
    ["&mut self"] = true,
}

local function resolve_kind_hl(ctx)
    if ctx.kind == "Function" and ctx.label:match("!%s*[%(%{%[]") then
        return "BlinkCmpKindMacro"
    end
    if ctx.kind == "Struct" and rust_builtin_types[ctx.label] then
        return "BlinkCmpKindBuiltinType"
    end
    if ctx.kind == "Variable" and rust_override_variants[ctx.label] then
        return "BlinkCmpKindBuiltinType"
    end
    if ctx.kind == "Value" and rust_override_variants[ctx.label] then
        return "BlinkCmpKindBuiltinType"
    end
    return "BlinkCmpKind" .. ctx.kind
end

local function is_blanket_impl(item)
    local detail = item.labelDetails and item.labelDetails.detail
    if detail and (detail:match("^%(?as ") or detail:match("^%(?use ")) then
        return true
    end
    return item.label:match("%(as ") ~= nil or item.label:match("%(use ") ~= nil
end

local LSP_KIND = {
    Variable = 6,
    Method = 2,
    Function = 3,
    Field = 5,
    EnumMember = 20,
    Snippet = 15,
}

local function item_bucket(item)
    if item.kind == LSP_KIND.Snippet then
        return 4
    end
    if item.kind == LSP_KIND.Variable then
        return 0
    end
    if item.kind == LSP_KIND.Field or item.kind == LSP_KIND.EnumMember then
        return 1
    end
    if is_blanket_impl(item) then
        return 3
    end
    return 2 -- your own methods/functions
end

return {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
        keymap = {
            preset = "none",
            ["<Tab>"] = { "select_and_accept", "fallback" },
            ["<A-j>"] = { "select_next", "fallback" },
            ["<A-k>"] = { "select_prev", "fallback" },
            ["<A-Tab>"] = { "hide", "fallback" },
        },
        appearance = {
            kind_icons = require("kind_icons"),
        },
        fuzzy = {
            frecency = { enabled = false },
            use_proximity = false,
            sorts = function()
                if vim.bo.filetype == "rust" then
                    return {
                        "score",
                        function(a, b)
                            local a_bucket, b_bucket = item_bucket(a), item_bucket(b)
                            if a_bucket ~= b_bucket then
                                return a_bucket < b_bucket
                            end
                        end,
                        "label",
                    }
                end
                return { "score", "sort_text" }
            end,
        },
        completion = {
            list = {
                selection = { preselect = false },
            },
            documentation = { auto_show = false },
            menu = {
                draw = {
                    padding = 0,
                    gap = 0,
                    components = {
                        kind_icon = {
                            text = function(ctx)
                                local icon = ctx.kind_icon
                                if vim.bo.filetype == "gdscript" and ctx.kind == "Event" then
                                    icon = kind_icons.Signal
                                end
                                if ctx.kind == "Struct" and rust_builtin_types[ctx.label] then
                                    icon = kind_icons.Variable
                                end
                                if ctx.kind == "Value" and rust_override_variants[ctx.label] then
                                    icon = kind_icons.Variable
                                end
                                return " " .. icon .. ctx.icon_gap
                            end,
                            highlight = resolve_kind_hl,
                        },
                        label = {
                            highlight = resolve_kind_hl,
                        },
                    },
                },
            },
        },
        sources = {
            default = { "lsp", "path", "buffer" },
        },
    },
}
