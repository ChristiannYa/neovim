return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			vue = { "prettier" },
			css = { "prettier" },
			html = { "prettier" },
			json = { "prettier" },
			markdown = { "prettier" },
			cpp = { "clang_format" },
			c = { "clang_format" },
			rust = { "rustfmt_nightly" },
		},
		formatters = {
			rustfmt_nightly = {
				command = "rustfmt",
				args = { "--edition", "2024" }, -- Year has to match Cargo.toml file
				env = {
					RUSTUP_TOOLCHAIN = "nightly",
				},
			},
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	},
}
