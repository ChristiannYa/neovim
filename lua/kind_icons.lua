-- Shared LSP-kind icon glyphs, used by both blink.cmp's completion popup
-- (lua/plugins/completion.lua) and nvim-navic's winbar breadcrumb
-- (lua/plugins/lualine.lua) so the same kind always renders the same
-- icon everywhere.
return {
	Text = "󰉿 ",
	Method = "󰆧 ",
	Function = "󰊕 ",
	Constructor = " ",
	Field = "󰜢 ",
	Variable = "󰂡 ",
	Class = "󰠱 ",
	Interface = " ",
	Module = "󰕳 ",
	Property = "󰜢 ",
	Unit = " ",
	Value = "󰎠 ",
	Enum = " ",
	Keyword = "󰌋 ",
	Snippet = " ",
	Color = "󰏘 ",
	File = "󰈙 ",
	Reference = " ",
	Folder = "󰉋 ",
	EnumMember = " ",
	Constant = "󰏿 ",
	Struct = " ",
	Event = " ",
	Operator = "󰆕 ",
	TypeParameter = "󰅲 ",
}
