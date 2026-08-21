local nerd_icon = ""

local count = 9

local active_id = nil
local last_id = nil

local names = {}
for i = 1, count do
	names[i] = i
end

local function get_new_terminal_id()
	for i = 1, count do
		local t = require("toggleterm.terminal").get(i)
		local exists = t and t.bufnr and vim.api.nvim_buf_is_valid(t.bufnr)
		if not exists then
			return i
		end
	end
	return nil
end

local function on_open()
	if vim.bo.buftype == "terminal" then
		vim.cmd("startinsert")
	end
end

local function on_toggle(n, direction)
	return function()
		local term = require("toggleterm.terminal").get(n)

		if term and term:is_open() then
			-- same direction, just unfocused: refocus it
			if term.direction == direction then
				local curr_win = vim.api.nvim_get_current_win()
				if curr_win == term.window then
					return
				end

				vim.api.nvim_set_current_win(term.window)
				vim.schedule(function()
					on_open()
					active_id = n
					vim.cmd("redrawstatus")
				end)
				return
			end

			-- different direction requested: switch it in place, same session
			term:close()
			vim.schedule(function()
				term:open(nil, direction)
				on_open()
				active_id = n
				vim.cmd("redrawstatus")
			end)
			return
		end

		-- not open: close any other visible terminal, then open this one
		local terms = require("toggleterm.terminal").get_all()
		for _, t in ipairs(terms) do
			if t.id ~= n and t:is_open() then
				t:close()
			end
		end

		vim.cmd(n .. "ToggleTerm direction=" .. direction)
		vim.schedule(function()
			on_open()

			local t = require("toggleterm.terminal").get(n)
			if t and t:is_open() then
				active_id = n
			elseif active_id == n then
				active_id = nil
			end

			vim.cmd("redrawstatus")
		end)
	end
end

local function open_or_switch(direction)
	return function()
		local target_id = active_id or last_id or get_new_terminal_id()
		if not target_id then
			vim.notify("No free terminal slots (max " .. count .. ")", vim.log.levels.WARN)
			return
		end
		on_toggle(target_id, direction)()
	end
end

local function cycle_terminal(step)
	return function()
		local terms = require("toggleterm.terminal").get_all()
		local active_ids = {}
		for _, t in ipairs(terms) do
			if t.bufnr and vim.api.nvim_buf_is_valid(t.bufnr) then
				table.insert(active_ids, t.id)
			end
		end
		table.sort(active_ids)
		if #active_ids == 0 then
			return
		end

		-- Determine the direction of whatever terminal we're currently in
		local current_term = active_id and require("toggleterm.terminal").get(active_id)
		local current_direction = (current_term and current_term.direction) or "horizontal"

		local idx = 1
		for i, id in ipairs(active_ids) do
			if id == active_id then
				idx = i
				break
			end
		end

		local next_idx = ((idx - 1 + step) % #active_ids) + 1
		local next_id = active_ids[next_idx]

		on_toggle(next_id, current_direction)()
	end
end

local function count_active()
	local terms = require("toggleterm.terminal").get_all()
	local lcount = 0
	for _, term in ipairs(terms) do
		if term.bufnr and vim.api.nvim_buf_is_valid(term.bufnr) then
			lcount = lcount + 1
		end
	end
	return lcount
end

_G.toggleterm_status = function()
	local active = count_active()
	if active == 0 then
		return ""
	end

	if not active_id then
		return nerd_icon .. " " .. active
	end

	local curr_name = names[active_id]
	local is_default = curr_name == active_id
	local name_disp = is_default and ("Terminal-" .. active_id) or curr_name
	return nerd_icon .. " " .. active .. " " .. name_disp
end

_G.toggleterm_winbar = function()
	local parts = {}
	for i = 1, count do
		local t = require("toggleterm.terminal").get(i)
		local exists = t and t.bufnr and vim.api.nvim_buf_is_valid(t.bufnr)

		local glyph, hl
		if i == active_id then
			glyph, hl = "●", "ToggleTermActive"
		elseif exists then
			glyph, hl = "○", "ToggleTermInactive"
		else
			glyph, hl = "⊗", "ToggleTermMissing"
		end

		table.insert(parts, string.format("%%#%s#%s%%*", hl, glyph))
	end
	return "%=" .. table.concat(parts, " ") .. "%="
end

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	keys = {
		-- Load the plugin the first time any of these keys is pressed
		"<leader>to",
		"<leader>tv",
		"<A-t>",
	},
	opts = {
		size = function(term)
			if term.direction == "horizontal" then
				return 15
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.4
			end
		end,
		shading_factor = 2,
		start_in_insert = true,
		insert_mappings = false,
		terminal_mappings = false,
	},
	config = function(_, opts)
		require("toggleterm").setup(opts)

		vim.keymap.set("t", "<a-w>", "<c-\\><c-n><c-w>p", {
			desc = "focus previous window",
		})

		vim.keymap.set("t", "<a-t>", function()
			local new_id = get_new_terminal_id()
			if not new_id then
				vim.notify("No free terminal slots (max " .. count .. ")", vim.log.levels.WARN)
				return
			end

			local current_term = active_id and require("toggleterm.terminal").get(active_id)
			local direction = (current_term and current_term.direction) or "horizontal"

			on_toggle(new_id, direction)()
		end, { desc = "Create new terminal" })

		vim.keymap.set("t", "<leader>qq", function()
			local n = vim.b.toggle_number
			if not n then
				return
			end

			local term = require("toggleterm.terminal").get(n)
			if term then
				term:close()
			end

			if active_id == n then
				last_id = n
				active_id = nil
			end

			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		end, { desc = "Exit current terminal" })

		vim.keymap.set("t", "<a-r>", function()
			local n = vim.b.toggle_number
			if not n then
				return
			end
			vim.cmd("stopinsert")
			vim.ui.input({ prompt = "rename terminal " .. n .. ": ", default = names[n] }, function(input)
				if input and input ~= "" then
					names[n] = input
					vim.cmd("redrawstatus")
				end
				vim.schedule(function()
					vim.cmd("startinsert")
				end)
			end)
		end, { desc = "Rename current terminal" })

		vim.keymap.set("t", "<a-d>", function()
			local n = vim.b.toggle_number
			if not n then
				return
			end

			local term = require("toggleterm.terminal").get(n)
			if term then
				term:shutdown()
			end

			names[n] = n
			if active_id == n then
				last_id = n
				active_id = nil
			end

			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		end, { desc = "delete current terminal" })

		vim.keymap.set({ "n", "t" }, "<leader>to", open_or_switch("horizontal"), {
			desc = "Open/switch terminal (horizontal)",
		})
		vim.keymap.set({ "n", "t" }, "<leader>tv", open_or_switch("vertical"), {
			desc = "Open/switch terminal (vertical)",
		})

		vim.api.nvim_create_autocmd("TermOpen", {
			group = vim.api.nvim_create_augroup("terminal-yank-insert", {
				clear = true,
			}),
			pattern = "term://*",
			callback = function(args)
				vim.keymap.set("v", "y", "y<cmd>startinsert<cr>", {
					buffer = args.buf,
					desc = "yank and return to insert mode",
				})
			end,
		})

		vim.api.nvim_create_autocmd("TermOpen", {
			group = vim.api.nvim_create_augroup("terminal-winbar", { clear = true }),
			pattern = "term://*",
			callback = function()
				vim.wo.winbar = "  %{%v:lua.toggleterm_winbar()%}"
			end,
		})

		vim.api.nvim_create_autocmd("WinEnter", {
			group = vim.api.nvim_create_augroup("terminal-clean-gutter", {
				clear = true,
			}),
			pattern = "*",
			callback = function()
				if vim.bo.buftype == "terminal" then
					vim.opt_local.number = false
					vim.opt_local.relativenumber = false
					vim.opt_local.signcolumn = "no"
					vim.opt_local.foldcolumn = "0"
				end
			end,
		})

		vim.api.nvim_create_autocmd("TermClose", {
			group = vim.api.nvim_create_augroup("terminal-count-redraw", {
				clear = true,
			}),
			pattern = "term://*",
			callback = function()
				vim.schedule(function()
					vim.cmd("redrawstatus")
				end)
			end,
		})

		vim.keymap.set("t", "<a-h>", cycle_terminal(-1), {
			desc = "previous terminal",
		})
		vim.keymap.set("t", "<a-l>", cycle_terminal(1), {
			desc = "next terminal",
		})

		vim.keymap.set("t", "<a-k>", "<up>", {
			desc = "terminal: previous command",
		})
		vim.keymap.set("t", "<a-j>", "<down>", {
			desc = "terminal: next command",
		})

		vim.keymap.set("t", "<a-n>", "<c-\\><c-n>", {
			desc = "terminal: enter normal mode",
		})
		vim.keymap.set("t", "<a-v>", "<c-\\><c-n>v", {
			desc = "terminal: enter visual mode",
		})

		vim.keymap.set("t", "<a-=>", "<c-\\><c-n><c-w>5+i", {
			desc = "terminal: increase height",
		})
		vim.keymap.set("t", "<a-->", "<c-\\><c-n><c-w>5-i", {
			desc = "terminal: decrease height",
		})
		vim.keymap.set("t", "<a-.>", "<c-\\><c-n><c-w>5>i", {
			desc = "terminal: increase width",
		})
		vim.keymap.set("t", "<a-,>", "<c-\\><c-n><c-w>5<i", {
			desc = "terminal: decrease width",
		})
	end,
}
