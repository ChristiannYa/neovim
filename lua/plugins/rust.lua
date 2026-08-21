-- The file is placed here because `rustaceanvim` manages its own LSP client
-- (it doesn't go through mason-lspconfig)
return {
	"mrcjkb/rustaceanvim",
	version = "^6",
	lazy = false,
	config = function()
		vim.g.rustaceanvim = {
			tools = {
				inlay_hints = {
					auto = true,
				},
			},
			server = {
				default_settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						checkOnSave = true,
						check = { command = "clippy" },
					},
				},
				on_new_config = function(config, _)
					config.cmd_env = config.cmd_env or {}
					config.cmd_env.RUST_BACKTRACE = "full"
				end,
			},
		}

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "rust",
			callback = function(args)
				local bufnr = args.buf
				local opts = { buffer = bufnr, silent = true }

				vim.keymap.set("n", "K", function()
					vim.cmd.RustLsp({ "hover", "actions" })
				end, vim.tbl_extend("force", opts, { desc = "Rust hover actions" }))
			end,
		})
	end,
}
