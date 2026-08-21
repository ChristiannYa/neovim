local function hasLspFoldingSupport(bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	for _, client in ipairs(clients) do
		if client.server_capabilities.foldingRangeProvider then
			return true
		end
	end
	return false
end

local handler = function(virtText, lnum, endLnum, width, truncate)
	local newVirtText = {}
	local icon = " 󰁂 "
	local count = ("%d "):format(endLnum - lnum)
	local sufWidth = vim.fn.strdisplaywidth(icon .. count)
	local targetWidth = width - sufWidth
	local curWidth = 0
	local padding = ""

	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(newVirtText, chunk)
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			local hlGroup = chunk[2]
			table.insert(newVirtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if curWidth + chunkWidth < targetWidth then
				padding = (" "):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
	end

	if padding ~= "" then
		table.insert(newVirtText, { padding, "UfoFoldedFg" })
	end

	table.insert(newVirtText, { icon, "UfoFoldedIcon" })
	table.insert(newVirtText, { count, "UfoMoreMsg" })

	return newVirtText
end

local function save_view()
	if vim.bo.buftype == "" then
		vim.cmd("silent! mkview")
	end
end

_G.ufo_fold_icon = function()
	local lnum = vim.v.lnum
	local foldlevel = vim.fn.foldlevel(lnum)
	local prevFoldlevel = vim.fn.foldlevel(lnum - 1)

	if foldlevel <= prevFoldlevel then
		return " "
	end

	if vim.fn.foldclosed(lnum) ~= -1 then
		return "" -- (closed)
	else
		return "" -- (open)
	end
end

return {
	"kevinhwang91/nvim-ufo",
	dependencies = { "kevinhwang91/promise-async" },
	config = function()
		---------------------------------
		-- Fold settings recommend by ufo
		---------------------------------
		-- vim.o.foldcolumn = "1"
		vim.o.foldlevel = 99 -- ufo needs a high foldlevel
		vim.o.foldlevelstart = -1 -- leave fold level as is instead of resetting
		vim.o.foldenable = true

		vim.o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:"

		----------
		-- Keymaps
		----------
		vim.keymap.set("n", "za", function()
			vim.cmd("normal! za")
			save_view()
		end, { desc = "Toggle fold (persist)" })

		vim.keymap.set("n", "zc", function()
			vim.cmd("normal! zc")
			save_view()
		end, { desc = "Close fold (persist)" })

		vim.keymap.set("n", "zR", function()
			require("ufo").openAllFolds()
			save_view()
		end)

		vim.keymap.set("n", "zM", function()
			require("ufo").closeAllFolds()
			save_view()
		end)

		require("ufo").setup({
			provider_selector = function(bufnr, filetype, buftype)
				if filetype == "" or buftype == "nofile" or buftype == "terminal" then
					return ""
				end

				local winid = vim.fn.bufwinid(bufnr)
				if winid ~= -1 and vim.wo[winid].foldmethod == "marker" then
					return ""
				end

				if hasLspFoldingSupport(bufnr) then
					return { "lsp", "indent" }
				end
				return { "treesitter", "indent" }
			end,
			fold_virt_text_handler = handler,
		})
	end,
}
