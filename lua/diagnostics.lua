local virtual_text_enabled = false
local virtual_text = {
	prefix = "󰝥",
	source = "if_many",
}

vim.diagnostic.config({
	virtual_text = virtual_text_enabled and virtual_text or false,
	-- signs = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticNumHlError",
			[vim.diagnostic.severity.WARN] = "DiagnosticNumHlWarn",
			[vim.diagnostic.severity.HINT] = "DiagnosticNumHlHint",
		},
		priority = 3,
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		source = "if_many",
	},
})

local function toggle_diagnostic_messages()
	virtual_text_enabled = not virtual_text_enabled
	vim.diagnostic.config({
		virtual_text = virtual_text_enabled and virtual_text or false,
	})
end

vim.keymap.set("n", "<leader>tm", toggle_diagnostic_messages, {
	desc = "Toggle diagnostic messages",
})

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.open_float(nil, { scope = "cursor" })
end, { desc = "Show diagnostic message under cursor" })
