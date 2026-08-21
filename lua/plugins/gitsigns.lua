return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		attach_to_untracked = true,
	},
	config = function(_, opts)
		require("gitsigns").setup(opts)

		vim.keymap.set("n", "<leader>gpi", ":Gitsigns preview_hunk_inline<CR>")
		vim.keymap.set("n", "<leader>gpp", ":Gitsigns preview_hunk<CR>")
		vim.keymap.set("n", "<leader>gs", ":Gitsigns stage_hunk<CR>")
		vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>")
	end,
}
