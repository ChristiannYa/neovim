require("bootstrap")
require("options")
require("keymaps")
require("diagnostics")

require("lazy").setup({
	{ import = "plugins" },
	{ import = "plugins.colorscheme" },
})

require("colorscheme")
