vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "min"

local theme = require("theme")

local def_group = {
	Normal = { fg = theme.foreground, bg = "NONE" },
	NormalFloat = { fg = theme.foreground, bg = theme.background },
	Normalnc = { fg = theme.foreground, bg = "NONE" },
	MatchParen = { fg = theme.accent, bg = "NONE", bold = true },
	SignColumn = { fg = theme.foreground, bg = "NONE" },
	EndOfBuffer = { fg = theme.background, bg = "NONE" },
	LineNr = { fg = theme.gray, bg = "NONE" },
	CursorLineNr = { fg = theme.accent, bg = "NONE", bold = true },
	CursorLine = { bg = "NONE" },
	Visual = { fg = theme.background, bg = theme.foreground },
	StatusLine = { fg = theme.foreground, bg = "NONE" },
	StatusLineNC = { fg = theme.foreground, bg = "NONE" },
	WinBar = { fg = theme.foreground, bg = "NONE" },
	WinBarNC = { fg = theme.foreground, bg = "NONE" },
	WinSeparator = { fg = theme.foreground, bg = "NONE" },
	VertSplit = { fg = theme.foreground, bg = theme.background },
	Pmenu = { fg = theme.foreground, bg = theme.foreground_fade },

	Comment = { fg = theme.gray, italic = false },
	Constant = { fg = theme.foreground },
	String = { fg = theme.gray },
	Identifier = { fg = theme.foreground },
	Function = { fg = theme.yellow },
	Statement = { fg = theme.foreground },
	Keyword = { fg = theme.accent },
	PreProc = { fg = theme.foreground },
	Type = { fg = theme.foreground },
	Special = { fg = theme.accent },

	SnippetTabstopActive = { fg = theme.foreground, bg = "NONE" },
	SnippetTabstop = { fg = theme.foreground, bg = "NONE" },
}

local cursor_group = {
	Cursor = { bg = theme.accent }, -- normal mode block cursor
	lCursor = { bg = theme.accent }, -- cursor in Language-mapping mode
	CursorIM = { bg = theme.accent }, -- cursor during IME input
	TermCursor = { bg = theme.accent }, -- cursor inside :terminal buffers
}

local diagnostic_group = {
	DiagnosticLineHint = { bg = "NONE" },
	DiagnosticLineError = { bg = "NONE" },
	DiagnosticLineWarn = { bg = "NONE" },

	DiagnosticVirtualTextHint = { fg = theme.blue2, bg = "NONE" },
	DiagnosticVirtualTextError = { fg = theme.red, bg = "NONE" },
	DiagnosticVirtualTextWarn = { fg = theme.orange, bg = "NONE" },

	DiagnosticUnderlineHint = { undercurl = true, sp = theme.blue2 },
	DiagnosticUnderlineError = { undercurl = true, sp = theme.red },
	DiagnosticUnderlineWarn = { undercurl = true, sp = theme.orange },
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

local blinkcmpmenu_group = {
	BlinkCmpMenuBorder = { fg = theme.background },
}

local treesitter_group = {
	["@boolean"] = { fg = theme.accent },
	["@number"] = { fg = theme.foreground },
	["@operator"] = { fg = theme.foreground },
	["@property"] = { fg = theme.foreground, italic = true },
	["@punctuation.bracket"] = { fg = theme.foreground },
	["@punctuation.delimiter"] = { fg = theme.foreground },
	["@variable"] = { fg = theme.foreground },
	["@variable.parameter"] = { fg = theme.foreground },
	["@variable.parameter.builtin"] = { fg = theme.foreground },
	-- ["@nospell"] = { fg = theme.foreground },
}

local semantic_tokens_group = {
	["@lsp.type.class"] = { fg = theme.foreground },
	["@lsp.type.method"] = { fg = theme.foreground, italic = true },
}

local lua_group = {
	["@constructor.lua"] = { fg = theme.foreground },
}

local jsts_group = {
	["@variable.builtin.typescript"] = { fg = theme.accent },
	["@constructor.typescript"] = { fg = theme.accent },
	["@lsp.type.type.typescript"] = { fg = theme.foreground },
	["@type.builtin.typescript"] = { fg = theme.foreground },
	["@lsp.type.typeParameter.typescript"] = { fg = theme.foreground },
	["@lsp.type.interface.typescript"] = { fg = theme.foreground, italic = false },
	["@constant.builtin.typescript"] = { fg = theme.accent },
}

local vue_group = {
	["@tag.vue"] = { fg = theme.accent },
	["@tag.attribute.vue"] = { fg = theme.foreground },
	["@variable.member.vue"] = { fg = theme.foreground },
	["@lsp.type.type.vue"] = { fg = theme.foreground },
}

local rust_group = {
	["@lsp.mod.async.rust"] = { italic = true },
	["@lsp.mod.mutable.rust"] = { underline = false },
	["@lsp.type.enum.rust"] = { fg = theme.foreground },
	["@lsp.type.enumMember.rust"] = { fg = theme.foreground, bold = false },
	["@lsp.type.formatSpecifier.rust"] = { fg = theme.accent },
	["@lsp.type.selfKeyword.rust"] = { fg = theme.accent },
	["@lsp.type.method.rust"] = { italic = true },
	["@lsp.type.macro.rust"] = { fg = theme.foreground },
	["@lsp.type.selfTypeKeyword.rust"] = { fg = theme.accent },
	["@lsp.type.struct.rust"] = { fg = theme.foreground },
	["@lsp.type.builtinType.rust"] = { fg = theme.foreground },
	["@lsp.type.interface.rust"] = { fg = theme.foreground, italic = false },
	["@lsp.type.character.rust"] = { fg = theme.foreground },
	["@lsp.type.typeParameter.rust"] = { fg = theme.foreground },
	["@lsp.type.typeAlias.rust"] = { fg = theme.foreground },
	["@lsp.type.lifetime.rust"] = { fg = theme.accent },
	["@lsp.type.escapeSequence.rust"] = { fg = theme.accent },
	["@label.rust"] = { fg = theme.foreground, italic = false },
	["@character.rust"] = { fg = theme.foreground },
	["@lsp.mod.attribute.rust"] = { fg = theme.foreground },
	["@string.escape.rust"] = { fg = theme.foreground },
	["@character.special.rust"] = { fg = theme.accent },
	["@operator.rust"] = { italic = true },
	["@number.float.rust"] = { fg = theme.foreground },
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
	cursor_group,
	netrw_group,
	oil_group,
	diagnostic_group,
	blinkcmpmenu_group,
	treesitter_group,
	semantic_tokens_group,
	lua_group,
	jsts_group,
	vue_group,
	rust_group
)

for group, opts in pairs(groups) do
	vim.api.nvim_set_hl(0, group, opts)
end
