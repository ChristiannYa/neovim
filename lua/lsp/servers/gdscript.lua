return {
    cmd = vim.lsp.rpc.connect("127.0.0.1", tonumber(os.getenv("GDScript_Port")) or 6005),
    filetypes = { "gd", "gdscript", "gdscript3" },
    root_markers = { "project.godot", ".git" },
}
