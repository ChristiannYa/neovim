vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "mytheme"

local theme = require("theme")

local def_group = {
    Normal = { fg = theme.foreground, bg = "NONE" },
    NormalFloat = { fg = theme.foreground, bg = "NONE" },
    FloatBorder = { fg = theme.accent, bg = "NONE" },
    Pmenu = { fg = theme.foreground, bg = "NONE" },
    Normalnc = { fg = theme.foreground, bg = "NONE" },
    MatchParen = { fg = theme.accent, bold = true },
    SignColumn = { fg = theme.foreground, bg = "NONE" },
    EndOfBuffer = { fg = theme.background, bg = "NONE" },
    LineNr = { fg = theme.foreground_fade, bg = "NONE" },
    CursorLineNr = { fg = theme.accent, bg = "NONE", bold = true },
    CursorLine = { bg = "NONE" },
    Visual = { bg = theme.blend(theme.accent, 0.1) },
    StatusLine = { fg = theme.foreground, bg = "NONE" },
    StatusLineNC = { fg = theme.foreground, bg = "NONE" },
    WinBar = { fg = theme.foreground, bg = "NONE" },
    WinBarNC = { fg = theme.foreground, bg = "NONE" },
    WinSeparator = { fg = theme.accent, bg = "NONE" },
    VertSplit = { fg = theme.foreground, bg = "NONE" },

    Comment = { fg = theme.blend(theme.foreground, 0.2) },
    Constant = { fg = theme.foreground },
    String = { fg = theme.green },
    Identifier = { fg = theme.foreground },
    Function = { fg = theme.yellow },
    Statement = { fg = theme.foreground },
    Keyword = { fg = theme.accent },
    PreProc = { fg = theme.foreground },
    Type = { fg = theme.foreground },
    Special = { fg = theme.accent },

    SnippetTabstopActive = { fg = theme.foreground, bg = theme.blend(theme.accent, 0.25) },
    SnippetTabstop = { fg = theme.foreground, bg = theme.blend(theme.foreground, 0.1) },

    Folded = { bg = "NONE" },
    FoldColumn = { fg = theme.foreground_fade, bg = "NONE" },

    LspReferenceTarget = {},
}

local navic_group = {
    NavicText = { fg = theme.foreground },
    NavicSeparator = { fg = theme.foreground_fade },
    NavicIconsFile = { fg = theme.blue },
    NavicIconsModule = { fg = theme.accent },
    NavicIconsNamespace = { fg = theme.accent },
    NavicIconsPackage = { fg = theme.accent },
    NavicIconsClass = { fg = theme.accent },
    NavicIconsMethod = { fg = theme.yellow },
    NavicIconsProperty = { fg = theme.purple },
    NavicIconsField = { fg = theme.purple },
    NavicIconsConstructor = { fg = theme.accent },
    NavicIconsEnum = { fg = theme.purple },
    NavicIconsInterface = { fg = theme.pea },
    NavicIconsFunction = { fg = theme.yellow },
    NavicIconsVariable = { fg = theme.foreground },
    NavicIconsConstant = { fg = theme.foreground },
    NavicIconsString = { fg = theme.green },
    NavicIconsNumber = { fg = theme.blue },
    NavicIconsBoolean = { fg = theme.accent },
    NavicIconsArray = { fg = theme.accent },
    NavicIconsObject = { fg = theme.accent },
    NavicIconsKey = { fg = theme.purple },
    NavicIconsNull = { fg = theme.gray },
    NavicIconsEnumMember = { fg = theme.purple },
    NavicIconsStruct = { fg = theme.fuchsia },
    NavicIconsEvent = { fg = theme.orange },
    NavicIconsOperator = { fg = theme.foreground },
    NavicIconsTypeParameter = { fg = theme.fuchsia },
}

local blinkcmpkind_group = {
    BlinkCmpKind = { fg = theme.foreground },
    BlinkCmpKindText = { fg = theme.foreground },
    BlinkCmpKindBuiltinType = { fg = theme.accent },
    BlinkCmpKindMethod = { fg = theme.yellow, italic = true },
    BlinkCmpKindFunction = { fg = theme.yellow },
    BlinkCmpKindMacro = { fg = theme.grass },
    BlinkCmpKindConstructor = { fg = theme.accent },
    BlinkCmpKindField = { fg = theme.purple, italic = true },
    BlinkCmpKindVariable = { fg = theme.foreground },
    BlinkCmpKindClass = { fg = theme.accent },
    BlinkCmpKindInterface = { fg = theme.pea },
    BlinkCmpKindModule = { fg = theme.accent },
    BlinkCmpKindProperty = { fg = theme.purple, italic = true },
    BlinkCmpKindUnit = { fg = theme.foreground },
    BlinkCmpKindValue = { fg = theme.foreground },
    BlinkCmpKindEnum = { fg = theme.purple },
    BlinkCmpKindKeyword = { fg = theme.accent },
    BlinkCmpKindSnippet = { fg = theme.foreground },
    BlinkCmpKindColor = { fg = theme.foreground },
    BlinkCmpKindFile = { fg = theme.foreground },
    BlinkCmpKindReference = { fg = theme.foreground },
    BlinkCmpKindFolder = { fg = theme.accent },
    BlinkCmpKindEnumMember = { fg = theme.purple, bold = true },
    BlinkCmpKindConstant = { fg = theme.foreground },
    BlinkCmpKindStruct = { fg = theme.fuchsia },
    BlinkCmpKindEvent = { fg = theme.foreground },
    BlinkCmpKindOperator = { fg = theme.foreground },
    -- BlinkCmpKindTypeParameter = { fg = theme.fuchsia },
}

local blinkcmpmenu_group = {
    BlinkCmpMenuBorder = { fg = theme.accent },
}

local ufopreview_group = {
    -- UfoFoldedIcon = { fg = theme.foreground, bold = true },
    -- UfoMoreMsg = { fg = theme.foreground, bold = true },
}

local cursor_group = {
    Cursor = { bg = theme.accent },     -- normal mode block cursor
    lCursor = { bg = theme.accent },    -- cursor in Language-mapping mode
    CursorIM = { bg = theme.accent },   -- cursor during IME input
    TermCursor = { bg = theme.accent }, -- cursor inside :terminal buffers
}

local diagnostic_group = {
    DiagnosticLineHint = { bg = "NONE" },
    DiagnosticLineError = { bg = "NONE" },
    DiagnosticLineWarn = { bg = "NONE" },

    DiagnosticVirtualTextHint = { fg = theme.blue2, bg = "NONE" },
    DiagnosticVirtualTextError = { fg = theme.red, bg = "NONE" },
    DiagnosticVirtualTextWarn = { fg = theme.orange, bg = "NONE" },

    DiagnosticNumHlError = { fg = theme.blend(theme.red, 0.3), bg = "NONE" },
    DiagnosticNumHlWarn = { fg = theme.blend(theme.orange, 0.3), bg = "NONE" },
    DiagnosticNumHlHint = { fg = theme.blend(theme.blue2, 0.3), bg = "NONE" },

    DiagnosticUnderlineHint = { undercurl = true, sp = theme.blue2 },
    DiagnosticUnderlineError = { undercurl = true, sp = theme.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = theme.orange },

    DiagnosticUnnecessary = { fg = theme.gray },

    DiagnosticFloatingError = { fg = theme.red },
    DiagnosticFloatingHint = { fg = theme.blue2 },
}

local netrw_group = {
    netrwDir = { fg = theme.accent, bg = "NONE" },
    netrwClassify = { fg = theme.accent, bg = "NONE" },
    -- netrwExe      = { fg = white_acc, bg = black_acc },
    -- netrwSymLink  = { fg = white_acc, bg = black_acc },
    -- netrwMarkFile = { fg = black_acc, bg = white_acc },
}

local oil_group = {
    OilDir = { fg = theme.accent, bg = "NONE" },
    OilDirIcon = { fg = theme.accent, bg = "NONE" },
}

local telescope_group = {
    TelescopeNormal = { fg = theme.foreground, bg = "NONE" },
    TelescopeBorder = { fg = theme.accent, bg = "NONE" },
    TelescopePromptNormal = { fg = theme.foreground, bg = "NONE" },
    TelescopePromptBorder = { fg = theme.accent, bg = "NONE" },
    TelescopeResultsNormal = { fg = theme.foreground, bg = "NONE" },
    TelescopeResultsBorder = { fg = theme.accent, bg = "NONE" },
    TelescopePreviewNormal = { fg = theme.foreground, bg = "NONE" },
    TelescopePreviewBorder = { fg = theme.accent, bg = "NONE" },
    TelescopeSelection = { fg = theme.background, bg = theme.accent, bold = true },
    TelescopeSelectionCaret = { fg = theme.accent, bg = theme.accent },
}

local toggleterm_group = {
    ToggleTermActive = { fg = theme.accent },
    ToggleTermInactive = { fg = theme.accent },
    ToggleTermMissing = { fg = theme.blend(theme.accent, 0.1) },
}

local qf_group = {
    qfFileName = { fg = theme.foreground },
    qfLineNr = { fg = theme.foreground },
    QuickFixLine = { fg = theme.accent, bg = "NONE", bold = true },
}

local treesitter_group = {
    ["@boolean"] = { fg = theme.accent },
    ["@number"] = { fg = theme.blue },
    ["@operator"] = { fg = theme.foreground },
    ["@property"] = { fg = theme.purple, italic = true },
    ["@punctuation.bracket"] = { fg = theme.foreground },
    ["@punctuation.delimiter"] = { fg = theme.foreground },
    ["@punctuation.special"] = { fg = theme.accent },
    ["@variable"] = { fg = theme.foreground },
    ["@variable.parameter"] = { fg = theme.blue2 },
    ["@variable.parameter.builtin"] = { fg = theme.blue2 },
}

local semantic_tokens_group = {
    ["@lsp.type.class"] = { fg = theme.accent },
    ["@lsp.type.method"] = { fg = theme.yellow, italic = true },
}

local lua_group = {
    ["@constructor.lua"] = { fg = theme.foreground },
}

local jsts_group = {
    ["@variable.builtin.typescript"] = { fg = theme.accent },
    ["@constructor.typescript"] = { fg = theme.accent },
    ["@lsp.type.type.typescript"] = { fg = theme.fuchsia },
    ["@type.builtin.typescript"] = { fg = theme.fuchsia },
    ["@lsp.type.typeParameter.typescript"] = { fg = theme.fuchsia },
    ["@lsp.type.interface.typescript"] = { fg = theme.fuchsia, italic = true },
    ["@constant.builtin.typescript"] = { fg = theme.accent },
}

local vue_group = {
    ["@tag.vue"] = { fg = theme.accent },
    ["@tag.attribute.vue"] = { fg = theme.purple },
    ["@variable.member.vue"] = { fg = theme.purple },
    ["@lsp.type.type.vue"] = { fg = theme.fuchsia },
    ["@_template.vue"] = { fg = theme.accent },
    ["@tag.delimiter.vue"] = { fg = theme.foreground },
    ["@markup.heading.1.vue"] = { fg = theme.foreground },
}

local rust_group = {
    ["@lsp.mod.async.rust"] = { italic = true },
    ["@lsp.mod.mutable.rust"] = { underline = false },
    ["@lsp.type.enum.rust"] = { fg = theme.purple },
    ["@lsp.type.enumMember.rust"] = { fg = theme.purple, bold = true },
    ["@lsp.type.formatSpecifier.rust"] = { fg = theme.accent },
    ["@lsp.type.selfKeyword.rust"] = { fg = theme.accent },
    ["@lsp.type.method.rust"] = { italic = true },
    ["@lsp.type.macro.rust"] = { fg = theme.grass },
    ["@lsp.type.selfTypeKeyword.rust"] = { fg = theme.accent },
    ["@lsp.type.struct.rust"] = { fg = theme.fuchsia },
    ["@lsp.type.builtinType.rust"] = { fg = theme.accent },
    ["@lsp.type.interface.rust"] = { fg = theme.pea, italic = false },
    ["@lsp.type.character.rust"] = { fg = theme.green },
    ["@lsp.type.typeParameter.rust"] = { fg = theme.fuchsia },
    ["@lsp.type.typeAlias.rust"] = { fg = theme.fuchsia },
    ["@lsp.type.lifetime.rust"] = { fg = theme.accent },
    ["@lsp.type.escapeSequence.rust"] = { fg = theme.accent },
    ["@lsp.type.namespace.rust"] = { fg = theme.accent },
    ["@lsp.mod.documentation.rust"] = { fg = theme.gray, italic = false },
    ["@lsp.mod.callable.rust"] = { fg = theme.yellow, italic = false },
    ["@label.rust"] = { fg = theme.green, italic = true },
    ["@character.rust"] = { fg = theme.green },
    ["@lsp.mod.attribute.rust"] = { fg = theme.mustard },
    ["@string.escape.rust"] = { fg = theme.accent },
    ["@character.special.rust"] = { fg = theme.foreground },
    ["operator.rust"] = { italic = true },
    ["@number.float.rust"] = { fg = theme.blue },
}

local gds_group = {
    ["@constant.gdscript"] = { fg = theme.foreground, bold = true },
    ["@type.gdscript"] = { fg = theme.fuchsia },
    ["@attribute.gdscript"] = { fg = theme.mustard },
    ["@number.float.gdscript"] = { fg = theme.blue },
    ["@function.method.call.gdscript"] = { fg = theme.yellow, italic = true },
    ["@function.builtin.gdscript"] = { fg = theme.yellow },
    ["@string.special.url.gdscript"] = { fg = theme.grass, underline = true }
}

local godot_group = {
    GodotSignalIcon = { fg = theme.foreground_fade, italic = true },
}

local function extend(...)
    local groups = {}
    for _, tbl in ipairs({ ... }) do
        for k, v in pairs(tbl) do
            groups[k] = v
        end
    end
    return groups
end

local groups = extend(
    def_group,
    navic_group,
    blinkcmpkind_group,
    ufopreview_group,
    cursor_group,
    netrw_group,
    oil_group,
    toggleterm_group,
    diagnostic_group,
    blinkcmpmenu_group,
    treesitter_group,
    telescope_group,
    semantic_tokens_group,
    qf_group,
    lua_group,
    jsts_group,
    vue_group,
    rust_group,
    gds_group,
    godot_group
)

for group, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
end
