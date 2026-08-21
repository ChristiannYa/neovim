_G.custom_statuscolumn = function()
	if vim.bo.filetype == "oil" then
		return "   "
	end
	if vim.bo.buftype ~= "" then
		return ""
	end
	return "%s%=%{v:relnum ? v:relnum : v:lnum} %#FoldColumn#%{%v:lua.ufo_fold_icon()%}%* "
end

vim.o.winborder = "rounded"
vim.o.statuscolumn = "%{%v:lua.custom_statuscolumn()%}"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_banner = 0

vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.guicursor = "n-v-sm:block,c:ver25,i-ci-ve:ver25,r-cr-o:hor20,t:ver25"
vim.opt.ignorecase = true
vim.opt.inccommand = "split"
vim.opt.laststatus = 3
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 999
vim.opt.shiftwidth = 4
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.title = true
vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}@nvim"
vim.opt.wrap = false

vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	desc = "Yanking listener",
	callback = function()
		vim.hl.on_yank({ higroup = "Visual", timeout = 150 })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "oil",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	end,
})

-- avoid saving/restoring cwd, just folds/cursor
vim.opt.viewoptions:remove("curdir")

vim.opt.viewoptions:remove("cursor")

-- restore view once ufo's async fold computation has settled
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "?*",
	callback = function()
		local win = vim.api.nvim_get_current_win()

		vim.defer_fn(function()
			if not vim.api.nvim_win_is_valid(win) then
				return
			end
			-- snapshot cursor here, AFTER telescope's jump has already landed
			local pos_before = vim.api.nvim_win_get_cursor(win)
			vim.cmd("silent! loadview")
			pcall(vim.api.nvim_win_set_cursor, win, pos_before)
		end, 30)
	end,
})
