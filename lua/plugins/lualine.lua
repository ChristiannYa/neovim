local theme = require("theme")

local diagnostic_severity_hl = {
	[vim.diagnostic.severity.ERROR] = "DiagnosticVirtualTextError",
	[vim.diagnostic.severity.WARN] = "DiagnosticVirtualTextWarn",
	[vim.diagnostic.severity.INFO] = "DiagnosticVirtualTextInfo",
	[vim.diagnostic.severity.HINT] = "DiagnosticVirtualTextHint",
}

local diagnostic_severity_sign = {
	[vim.diagnostic.severity.ERROR] = "E",
	[vim.diagnostic.severity.WARN] = "W",
	[vim.diagnostic.severity.INFO] = "I",
	[vim.diagnostic.severity.HINT] = "H",
}

-- Order matters: determines left-to-right display order and
-- which severity "wins" when picking the offscreen arrow's color.
local severity_order = {
	vim.diagnostic.severity.ERROR,
	vim.diagnostic.severity.WARN,
	vim.diagnostic.severity.INFO,
	vim.diagnostic.severity.HINT,
}

local function diagnostics_with_offscreen()
	local diagnostics = vim.diagnostic.get(0)
	if #diagnostics == 0 then
		return ""
	end

	local counts = {}
	local win_top = vim.fn.line("w0")
	local win_bottom = vim.fn.line("w$")
	local severity_above, severity_below

	for _, d in ipairs(diagnostics) do
		counts[d.severity] = (counts[d.severity] or 0) + 1

		local lnum = d.lnum + 1 -- diagnostic lnum is 0-indexed
		if lnum < win_top then
			if not severity_above or d.severity < severity_above then
				severity_above = d.severity
			end
		elseif lnum > win_bottom then
			if not severity_below or d.severity < severity_below then
				severity_below = d.severity
			end
		end
	end

	local parts = {}
	for _, sev in ipairs(severity_order) do
		if counts[sev] and counts[sev] > 0 then
			local hl = diagnostic_severity_hl[sev]
			local piece = string.format("%%#%s#%s:%d", hl, diagnostic_severity_sign[sev], counts[sev])
			if sev == severity_above then
				piece = piece .. "" .. ""
			end
			if sev == severity_below then
				piece = piece .. "" .. ""
			end
			piece = piece .. "%*"
			table.insert(parts, piece)
		end
	end

	return table.concat(parts, " ")
end

local function inFile()
	-- return vim.bo.filetype ~= "netrw" -- Used with default netrw
	return vim.bo.filetype ~= "oil"
end

local winbar_c_bgcolor = "NONE"
local winbar_c = {
	{
		"filetype",
		color = { bg = winbar_c_bgcolor },
		icon_only = true,
		cond = inFile,
	},
	{
		"filename",
		path = 1,
		color = { bg = winbar_c_bgcolor },
		cond = inFile,
	},
	{
		"filesize",
		color = { bg = winbar_c_bgcolor },
		cond = inFile,
	},
	{
		diagnostics_with_offscreen,
		cond = inFile,
	},
	{
		function()
			-- Previously used with default `netrw`
			-- return vim.fn.fnamemodify(vim.b.netrw_curdir or "", ":~:.")

			local ok, oil = pcall(require, "oil")
			if not ok then
				return ""
			end
			local dir = oil.get_current_dir()
			return dir and vim.fn.fnamemodify(dir, ":~:.") or ""
		end,
		color = { bg = winbar_c_bgcolor },
		cond = function()
			return inFile() == false
		end,
	},
}

local winbar_x = {
	-- {
	-- 	"lsp_status",
	-- 	icon = "\u{f013}", -- f013
	-- 	symbols = {
	-- 		-- Standard unicode symbols to cycle through for LSP progress:
	-- 		spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
	-- 		-- Standard unicode symbol for when LSP is done:
	-- 		done = "✓",
	-- 		-- Delimiter inserted between LSP names:
	-- 		separator = " ",
	-- 	},
	-- 	-- List of LSP names to ignore (e.g., `null-ls`):
	-- 	ignore_lsp = {},
	-- 	-- Display the LSP name
	-- 	show_name = true,
	-- },
	{
		function()
			return require("nvim-navic").get_location()
		end,
		cond = function()
			return inFile() and require("nvim-navic").is_available()
		end,
	},
}

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"SmiteshP/nvim-navic",
	},
	opts = {
		options = {
			theme = {
				normal = {
					a = { fg = theme.background, bg = theme.accent },
					b = { fg = theme.background, bg = theme.blue },
					c = { fg = theme.foreground, bg = "NONE" },
					x = { fg = theme.foreground, bg = "NONE" },
					y = { fg = theme.background, bg = theme.blue },
					z = { fg = theme.background, bg = theme.accent },
				},
			},
			always_divide_middle = true,
			always_show_tabline = true,
			icons_enabled = true,
			globalstatus = true,
			disabled_filetypes = {
				statusline = {},
				winbar = { "toggleterm" },
			},
			ignore_focus = {},
			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000,
			},
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				"branch",
			},
			lualine_c = {
				{
					"diff",
					colored = false,
				},
			},
			lualine_x = {
				function()
					return _G.toggleterm_status and _G.toggleterm_status() or ""
				end,
			},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {
				-- "filename"
			},
			lualine_x = {
				-- "location"
			},
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},
		winbar = {
			lualine_c = winbar_c,
			lualine_x = winbar_x,
		},
		inactive_winbar = {
			lualine_c = winbar_c,
			lualine_x = winbar_x,
		},
		extensions = {},
	},
	config = function(_, opts)
		local lualine = require("lualine")
		lualine.setup(opts)

		local navic = require("nvim-navic")
		navic.setup({
			icons = require("kind_icons"),
			highlight = true,
			separator = "  ",
			depth_limit = 0,
			depth_limit_indicator = "..",
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lualine_navic_attach", { clear = true }),
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client or not client:supports_method("textDocument/documentSymbol") then
					return
				end
				-- vtsls only sees the <script> block of a .vue file via its TS
				-- plugin, not the full SFC; let vue_ls own the breadcrumb instead,
				-- since navic only allows one client per buffer.
				if vim.bo[args.buf].filetype == "vue" and client.name ~= "vue_ls" then
					return
				end
				navic.attach(client, args.buf)
			end,
		})

		vim.api.nvim_create_autocmd({ "WinScrolled", "CursorMoved", "CursorMovedI", "DiagnosticChanged" }, {
			group = vim.api.nvim_create_augroup("lualine_diag_scroll_refresh", { clear = true }),
			callback = function()
				lualine.refresh({ place = { "winbar" } })
			end,
		})
	end,
}
